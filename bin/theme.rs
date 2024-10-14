#!/usr/bin/env scriptisto
 
// scriptisto-begin
// script_src: src/main.rs
// build_cmd: cargo build --release && strip ./target/release/script
// target_bin: ./target/release/script
// files:
//  - path: Cargo.toml
//    content: |
//      package = { name = "script", version = "0.1.0", edition = "2018"}
//      [dependencies]
//      clap={version="4", features=["derive"]}
//      anyhow="*"
//      cmd_lib = "1.9.5"
// scriptisto-end


use anyhow::{Context, Result};
use cmd_lib::*;
use std::env;
use std::fs::File;
use std::io::{BufRead, BufReader, BufWriter, Write};
use clap::{Parser, Subcommand};

#[derive(Debug, Parser)]
#[command(
    name = "theme.rs",
    about = "A quite specific and opionated dark/light theme changer utility"
)]
struct Opt {
    #[command(subcommand)]
    mode: Option<ThemeMode>,
}

#[derive(Debug, Clone, Copy, Subcommand)]
enum ThemeMode {
    Dark,
    Light,
    Toggle,
}

trait ThemeChanger {
    fn apply(&self, theme_mode: ThemeMode) -> Result<()>;
}

struct MarkerLineChanger {
    filepaths: Vec<String>,
}

impl MarkerLineChanger {
    pub fn new(filepaths: Vec<String>) -> Self {
        Self { filepaths }
    }
}

impl ThemeChanger for MarkerLineChanger {
    fn apply(&self, theme_mode: ThemeMode) -> Result<()> {
        let marker = "AUTO CHANGE MARKER: LIGHT/DARK";

        for filepath in self.filepaths.iter() {
            let reader =
                BufReader::new(File::open(filepath).context(format!("Open file {}", filepath))?);

            let mut lines = reader.lines();
            let mut new_lines = vec![];
            while let Some(Ok(line)) = lines.next() {
                if line.contains(marker) {
                    new_lines.push(line);
                    if let Some(Ok(mut next_line)) = lines.next() {
                        match theme_mode {
                            ThemeMode::Dark => {
                                if next_line.contains("light") {
                                    next_line = next_line.replace("light", "dark");
                                }
                            }
                            ThemeMode::Light => {
                                if next_line.contains("dark") {
                                    next_line = next_line.replace("dark", "light");
                                }
                            }
                            ThemeMode::Toggle => {
                                if next_line.contains("dark") {
                                    next_line = next_line.replace("dark", "light");
                                } else {
                                    next_line = next_line.replace("light", "dark");
                                }
                            }
                        }
                        new_lines.push(next_line);
                    }
                } else {
                    new_lines.push(line);
                }
            }

            let mut writer = BufWriter::new(
                File::create(filepath).context(format!("Open file for writing {}", filepath))?,
            );

            for line in new_lines {
                writer.write_all(line.as_bytes()).context("Write line")?;
                writer
                    .write_all(b"\n")
                    .context("Writing newline character")?;
            }
        }
        Ok(())
    }
}

struct TmuxThemeChanger {
    filepath: String,
    marker_changer: MarkerLineChanger,
}

impl TmuxThemeChanger {
    pub fn new(filepath: String) -> Self {
        Self {
            filepath: filepath.clone(),
            marker_changer: MarkerLineChanger::new(vec![filepath]),
        }
    }
}

impl ThemeChanger for TmuxThemeChanger {
    fn apply(&self, theme_mode: ThemeMode) -> Result<()> {
        self.marker_changer.apply(theme_mode)?;
        let filepath = &self.filepath;
        run_cmd!(
            tmux source "$filepath"
        )
        .context("Calling tmux to source new configuration")?;
        Ok(())
    }
}

fn main() -> Result<()> {
    let opt = Opt::parse();

    let mode = if opt.mode.is_some() {
        opt.mode.unwrap()
    } else {
        // Allow for linking the executable to different names to set the theme_mode
        match env::current_exe()?.file_name().unwrap().to_str().unwrap() {
            "dark" => ThemeMode::Dark,
            "light" => ThemeMode::Light,
            _ => ThemeMode::Toggle,
        }
    };

    let home = env::var("HOME").context("Read HOME environment variable")?;

    let changers: Vec<Box<dyn ThemeChanger>> = vec![
        Box::new(MarkerLineChanger::new(vec![
            format!("{}/.config/alacritty/alacritty.toml", home),
            format!("{}/.config/nvim/lua/config/options.lua", home),
        ])),
        Box::new(TmuxThemeChanger::new(format!("{}/.tmux.conf", home))),
    ];

    for changer in changers {
        changer.apply(mode)?
    }

    Ok(())
}
