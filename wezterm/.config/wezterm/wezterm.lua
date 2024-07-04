-- Pull in the wezterm API

local wezterm = require("wezterm")

-- This will hold the configuration.

local config = wezterm.config_builder()

-- This is where you actually apply your config choices

config.font = wezterm.font_with_fallback({
	"Jetbrains Mono",
})
config.font_size = 10.5
config.enable_tab_bar = false
config.window_background_opacity = 0.8

config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}

-- For example, changing the color scheme:

config.color_scheme = "Tokyo Night (Gogh)"

-- and finally, return the configuration to wezterm

return config
