local naughty = require("naughty")

naughty.notify({
	preset = naughty.config.presets.info,
	title = "Hello, World!",
})
