-- lua/plugins/mini.lua
return {
	{
		'echasnovski/mini.pairs',
		version = false,
		config = function()
			require('mini.pairs').setup()
		end
	},
	{
		'echasnovski/mini.pick',
		version = false,
		config = function()
			require('mini.pick').setup()
		end
	},
	{
		'echasnovski/mini.nvim',
		config = function()
			local statusline = require 'mini.statusline'
			statusline.setup { use_icons = true }
		end
	},
	{
		'echasnovski/mini.surround',
		version = false,
		config = function()
			require('mini.surround').setup()
		end
	}
}
