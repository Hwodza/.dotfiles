-- lua/plugins/mini.lua
return {
	{
		'nvim-mini/mini.pairs',
		version = false,
		config = function()
			require('mini.pairs').setup()
		end
	},
	-- {
	-- 	'echasnovski/mini.pick',
	-- 	version = false,
	-- 	config = function()
	-- 		require('mini.pick').setup()
	-- 	end
	-- },
	{
		'nvim-mini/mini.nvim',
		config = function()
			local statusline = require 'mini.statusline'
			statusline.setup { use_icons = true }
		end
	},
	{
		'nvim-mini/mini.surround',
		version = false,
		config = function()
			require('mini.surround').setup()
		end
	},
	{
		'nvim-mini/mini.nvim',
		version = false,
		config = function()
			require('mini.comment').setup(
				{
					mappings = {
						comment = "<C-_>",
						comment_line = "<C-_>",
						comment_visual = "<C-_>",
						textobject = "<C-_>",
					},
				}
			)
		end
	}
}
