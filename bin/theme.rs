#!/usr/bin/env scriptisto

// scriptisto-begin
// script_src: src/main.rs
// build_cmd: cargo build --release && strip ./target/release/script
// target_bin: ./target/release/script
// files:
//  - path: Cargo.toml
//    content: |
//     package = { name = "script", version = "0.1.0", edition = "2018"}
//     [dependencies]
//     clap={version="4", features=["derive"]}
//     anyhow = "1"
//     cmd_lib = "1.9"
//     serde_json = "1"
//     json5 = "0.4"
// scriptisto-end

use anyhow::{Context, Result};
use cmd_lib::*;
use std::env;
use std::fs::File;
use std::io::{BufRead, BufReader, BufWriter, Read, Write};

use clap::{Parser, Subcommand};

#[derive(Debug, Parser)]
#[command(
    name = "theme",
    about = "A very specific and opnionated script to change between light and dark themes"
)]
struct Opt {
    /// Example input
    #[command(subcommand)]
    mode: Option<Mode>,
}

#[derive(Clone, Copy, Debug, Subcommand)]
enum Mode {
    Light,
    Dark,
    Toggle,
}

trait ThemeChanger {
    fn apply(&self, mode: Mode) -> Result<()>;
}

struct Marker {
    filepath: String,
}

impl Marker {
    pub fn new(filepath: String) -> Self {
        Self { filepath }
    }
}

impl ThemeChanger for Marker {
    fn apply(&self, mode: Mode) -> Result<()> {
        let marker = "AUTO CHANGE MARKER: LIGHT/DARK";

        // Open file
        let reader = BufReader::new(
            File::open(&self.filepath).context(format!("open {} for reading", self.filepath))?,
        );

        let mut new_lines = vec![];

        // Scan file line by line for marker
        let mut lines = reader.lines();
        while let Some(Ok(line)) = lines.next() {
            if line.contains(marker) {
                // Change lines AFTER marker
                new_lines.push(line);
                if let Some(Ok(theme_line)) = lines.next() {
                    let new_line = match mode {
                        Mode::Light => theme_line.replace("dark", "light"),
                        Mode::Dark => theme_line.replace("light", "dark"),
                        Mode::Toggle => {
                            if theme_line.contains("dark") {
                                theme_line.replace("dark", "light")
                            } else {
                                theme_line.replace("light", "dark")
                            }
                        }
                    };

                    new_lines.push(new_line);
                }
            } else {
                new_lines.push(line);
            }
        }
        // Write file with changed line(s)
        let mut writer = BufWriter::new(
            File::create(&self.filepath)
                .context(format!("truncate {} for replacing", self.filepath))?,
        );

        for line in new_lines {
            writer
                .write_all(line.as_bytes())
                .context("write line to replaced configuration")?;
            writer.write_all(b"\n").context("write newline character")?;
        }

        Ok(())
    }
}

struct TMux {
    filepath: String,
    marker: Marker,
}

impl TMux {
    pub fn new(filepath: String) -> Self {
        Self {
            filepath: filepath.clone(),
            marker: Marker::new(filepath),
        }
    }
}

impl ThemeChanger for TMux {
    fn apply(&self, mode: Mode) -> Result<()> {
        self.marker.apply(mode)?;
        let filepath = &self.filepath;
        run_cmd!(
            tmux source "${filepath}"
        )
        .context("Reload tmux configuration")?;
        Ok(())
    }
}

struct VSCode {
    filepath: String,
}

impl VSCode {
    pub fn new(filepath: String) -> Self {
        Self { filepath }
    }
}

impl ThemeChanger for VSCode {
    fn apply(&self, mode: Mode) -> Result<()> {
        let default_light_theme = "Default Light Modern";
        let default_dark_theme = "Default Dark Modern";

        // Open and deserialize settings.json
        let mut reader = BufReader::new(
            File::open(&self.filepath).context(format!("open {} for reading", self.filepath))?,
        );
        let mut data = String::new();
        reader
            .read_to_string(&mut data)
            .context("read settings.json")?;
        let mut document: serde_json::Value =
            json5::from_str(&data).context("deserialize settings.json")?;

        let current_theme = document.get("workbench.colorTheme");

        if current_theme.is_none() {
            // We can't change the theme if it's not set. We don't want to
            // destroy the config, therefore we skip this here.
            return Ok(());
        }

        let new_theme = match mode {
            Mode::Light => {
                if let Some(preferred_light_theme) =
                    document.get("workbench.preferredLightColorTheme")
                {
                    preferred_light_theme.as_str().unwrap()
                } else {
                    default_light_theme
                }
            }
            Mode::Dark => {
                if let Some(preferred_dark_theme) =
                    document.get("workbench.preferredDarkColorTheme")
                {
                    preferred_dark_theme.as_str().unwrap()
                } else {
                    default_dark_theme
                }
            }
            Mode::Toggle => {
                if current_theme
                    .unwrap()
                    .as_str()
                    .unwrap()
                    .to_lowercase()
                    .contains("dark")
                {
                    if let Some(preferred_light_theme) =
                        document.get("workbench.preferredLightColorTheme")
                    {
                        preferred_light_theme.as_str().unwrap()
                    } else {
                        default_light_theme
                    }
                } else {
                    if let Some(preferred_dark_theme) =
                        document.get("workbench.preferredDarkColorTheme")
                    {
                        preferred_dark_theme.as_str().unwrap()
                    } else {
                        default_dark_theme
                    }
                }
            }
        };

        document["workbench.colorTheme"] = serde_json::Value::String(new_theme.to_string());

        // Write settings.json
        let writer = BufWriter::new(
            File::create(&self.filepath)
                .context(format!("truncate {} for replacing", self.filepath))?,
        );
        serde_json::to_writer_pretty(writer, &document).context("serialize settings.json")?;

        Ok(())
    }
}

fn main() -> Result<()> {
    let opt = Opt::parse();
    let mode = opt.mode.unwrap_or(Mode::Toggle);

    let home = env::var("HOME").context("retrieve home directory using HOME env")?;
    let changers: Vec<Box<dyn ThemeChanger>> = vec![
        Box::new(Marker::new(format!(
            "{}/.config/alacritty/alacritty.toml",
            home
        ))),
        Box::new(Marker::new(format!(
            "{}/.config/wezterm/wezterm.lua",
            home
        ))),
        Box::new(Marker::new(format!(
            "{}/.config/nvim/lua/plugins/colorscheme.lua",
            home
        ))),
        Box::new(TMux::new(format!("{}/.tmux.conf", home))),
        Box::new(VSCode::new(format!(
            "{}/Library/Application Support/Code/User/settings.json",
            home
        ))),
    ];

    for changer in changers {
        changer.apply(mode)?;
    }

    Ok(())
}
