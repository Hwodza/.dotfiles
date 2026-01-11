vim.lsp.config['luals'] = {
	-- Command and arguments to start the server.
	cmd = { 'lua-language-server' },
	-- Filetypes to automatically attach to.
	filetypes = { 'lua' },
	-- Sets the "workspace" to the directory where any of these files is found.
	-- Files that share a root directory will reuse the LSP server connection.
	-- Nested lists indicate equal priority, see |vim.lsp.Config|.
	root_markers = { { '.luarc.json', '.luarc.jsonc' }, '.git' },
	-- Specific settings to send to the server. The schema is server-defined.
	-- Example: https://raw.githubusercontent.com/LuaLS/vscode-lua/master/setting/schema.json
	settings = {
		Lua = {
			runtime = {
				version = 'LuaJIT',
			},
			diagnostics = {
				globals = { "vim" }, -- This is the magic line
			},
		}
	}
}
vim.lsp.config['gopls'] = {
	-- Command and arguments to start the server.
	cmd = { 'gopls' },
	-- Filetypes to automatically attach to.
	filetypes = { "go", "gomod", "gowork", "gotmpl" },
}
vim.lsp.config('rust_analyzer', {
  settings = {
    ['rust-analyzer'] = {
    }
  }
})
vim.lsp.config['nil_ls'] = {
	cmd = { 'nil_ls' },
	filetypes = { 'nix' },
	root_markers = { 'flake.nix', 'git' },
}
vim.lsp.config['jsonls'] = {
	cmd = { 'vscode-json-language-server', '--stdio' },
	filetypes = { 'json', 'jsonc' },
	init_options = {
		provideFormatter = true,
	},
	root_markers = { '.git' },
}
vim.lsp.config['bashls'] = {
	cmd = { 'bash-language-server', 'start' },
	settings = {
		bashIde = {
			-- Glob pattern for finding and parsing shell script files in the workspace.
			-- Used by the background analysis features across files.

			-- Prevent recursive scanning which will cause issues when opening a file
			-- directly in the home directory (e.g. ~/foo.sh).
			--
			-- Default upstream pattern is "**/*@(.sh|.inc|.bash|.command)".
			globPattern = vim.env.GLOB_PATTERN or '*@(.sh|.inc|.bash|.command)',
		},
	},
	filetypes = { 'bash', 'sh' },
	root_markers = { '.git' },
}
vim.lsp.config['clangd'] = {
	cmd = { "clangd" },
	filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },

}
