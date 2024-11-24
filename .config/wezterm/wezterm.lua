local wezterm = require('wezterm')
local config = wezterm.config_builder()

-- Colorscheme
-- AUTO CHANGE MARKER: LIGHT/DARK
config.color_scheme = "Gruvbox Material Hard dark"

-- Font configuration
config.font = wezterm.font('JetBrainsMono Nerd Font', {weight = "DemiBold"})
config.font_size = 14
-- Ensure ligatures work.
config.font_shaper = "Harfbuzz"
config.harfbuzz_features = { 'calt=1', 'clig=1', 'liga=1' }

-- Make the window minimal, but visually appealing
config.enable_tab_bar = false
config.window_decorations = "RESIZE"
config.adjust_window_size_when_changing_font_size = false
config.window_padding = {
  left = 5,
  right = 5,
  top = 5,
  bottom = 5,
}
config.window_background_opacity = 0.92
config.macos_window_background_blur = 10

config.selection_word_boundary = " \t\n{[}]()\"'`,;:"

-- Keyboard shortcuts to make life easier on macos
config.keys = {
-- Change font size with CMD+/-
  {
    key = '+',
    mods = 'CMD',
    action = wezterm.action.IncreaseFontSize,
  },
  {
    key = '-',
    mods = 'CMD',
    action = wezterm.action.DecreaseFontSize,
  },
  {
    key = '0',
    mods = 'CMD',
    action = wezterm.action.ResetFontSize,
  },
  -- Alt + Left/Right for word-wise-navigation
  {
    key = 'LeftArrow',
    mods = 'OPT',
    action = wezterm.action.SendString('\x1bb'),
  },
  {
    key = 'RightArrow',
    mods = 'OPT',
    action = wezterm.action.SendString('\x1bf'),
  },
  -- CMD + Left/Right for Home/End
  {
    key = 'LeftArrow',
    mods = 'CMD',
    action = wezterm.action.SendString('\x1bOH'),
  },
  {
    key = 'RightArrow',
    mods = 'CMD',
    action = wezterm.action.SendString('\x1bOF'),
  },
  -- CMD + Backspace: Delete line
  {
    key = 'Backspace',
    mods = 'CMD',
    action = wezterm.action.SendString('\x15'),
  },
  -- Alt + Backspace: Delete a word
  {
    key = 'Backspace',
    mods = 'OPT',
    action = wezterm.action.SendString('\x1b\x7f'),
  }
}

-- Scrolling deactivated, as we are using tmux for that.
config.scrollback_lines = 0

-- Startup with env to enable tmux autostart
config.set_environment_variables = {
  ENABLE_TMUX_STARTUP = "true"
}

return config
