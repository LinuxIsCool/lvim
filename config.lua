--[[
lvim is the global options object

Linters should be
filled in as strings with either
a global executable or a path to
an executable
]]
-- THESE ARE EXAMPLE CONFIGS FEEL FREE TO CHANGE TO WHATEVER YOU WANT

-- general
lvim.log.level = "warn"
-- lvim.format_on_save.enabled = true
lvim.format_on_save = true
lvim.colorscheme = "lunar"
lvim.transparent_window = true

-- keymappings [view all the defaults by pressing <leader>Lk]
lvim.leader = ","

-- add your own keymapping

-- map leader f and j to start and end of line
lvim.builtin.which_key.mappings["j"] = {}
lvim.keys.normal_mode["<leader>j"] = "$"
lvim.keys.visual_mode["<leader>j"] = "$"

lvim.builtin.which_key.mappings["f"] = {}
lvim.keys.normal_mode["<leader>f"] = "0"
lvim.keys.visual_mode["<leader>f"] = "0"

-- map NvimTreeToggle
lvim.keys.normal_mode["<C-n>"] = ":NvimTreeToggle<cr>"

-- lvim.keys.normal_mode["<S-l>"] = ":BufferLineCycleNext<CR>"
-- lvim.keys.normal_mode["<S-h>"] = ":BufferLineCyclePrev<CR>"
--
-- Commenting txt files.
-- local ft = require('Comment.ft')
-- Metatable magic
-- ft.txt = '//%s'

-- Change Telescope navigation to use j and k for navigation and n and p for history in both input and normal mode.
-- we use protected-mode (pcall) just in case the plugin wasn't loaded yet.
local _, actions = pcall(require, "telescope.actions")
lvim.builtin.telescope.defaults.mappings = {
	-- for input mode
	i = {
		["<C-j>"] = actions.move_selection_next,
		["<C-k>"] = actions.move_selection_previous,
		["<C-n>"] = actions.cycle_history_next,
		["<C-p>"] = actions.cycle_history_prev,
	},
	-- for normal mode
	n = {
		["<C-j>"] = actions.move_selection_next,
		["<C-k>"] = actions.move_selection_previous,
	},
}

-- Use which-key to add extra bindings with the leader-key prefix
lvim.builtin.which_key.mappings["P"] = { "<cmd>Telescope projects<CR>", "Projects" }
lvim.builtin.which_key.mappings["t"] = {
	name = "+Trouble",
	r = { "<cmd>Trouble lsp_references<cr>", "References" },
	f = { "<cmd>Trouble lsp_definitions<cr>", "Definitions" },
	d = { "<cmd>Trouble document_diagnostics<cr>", "Diagnostics" },
	q = { "<cmd>Trouble quickfix<cr>", "QuickFix" },
	l = { "<cmd>Trouble loclist<cr>", "LocationList" },
	w = { "<cmd>Trouble workspace_diagnostics<cr>", "Workspace Diagnostics" },
	-- v = { "<cmd>lua require('lsp_lines').toggle()<cr>", "Virtual Text" },
}
lvim.lsp.diagnostics.virtual_text = false

-- TODO: User Config for predefined plugins
-- After changing plugin config exit and reopen LunarVim, Run :PackerInstall :PackerCompile
lvim.builtin.alpha.active = true
lvim.builtin.alpha.mode = "dashboard"
lvim.builtin.terminal.active = true
lvim.builtin.nvimtree.setup.view.side = "left"
lvim.builtin.nvimtree.setup.renderer.icons.show.git = true

-- if you don't want all the parsers change this to a table of the ones you want
lvim.builtin.treesitter.ensure_installed = {
	"bash",
	"c",
	"javascript",
	"json",
	"lua",
	"python",
	"typescript",
	"tsx",
	"css",
	"rust",
	"java",
	"yaml",
}
lvim.builtin.treesitter.highlight.enable = true

-- Illuminate
lvim.autocommands = {
	{
		"ColorScheme",
		{
			callback = function()
				vim.api.nvim_set_hl(0, "IlluminatedWordRead", { fg = "#aaaaaa" })
			end,
		},
	},
}

-- lvim.builtin.illuminate.options.under_cursor = true

local null_ls_status_ok, null_ls = pcall(require, "null-ls")
if not null_ls_status_ok then
	return
end

-- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/formatting
local formatting = null_ls.builtins.formatting
-- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/diagnostics
local diagnostics = null_ls.builtins.diagnostics

local completion = null_ls.builtins.completion

null_ls.setup({
	debug = false,
	sources = {
		formatting.prettier.with({ extra_args = { "--no-semi", "--single-quote", "--jsx-single-quote" } }),
		formatting.black.with({ extra_args = { "--fast", "--line-length", "79", "--experimental-string-processing" } }),
		-- formatting.yapf,
		formatting.stylua,
		formatting.trim_whitespace,
		-- formatting.autopep8,
		formatting.isort,
		-- diagnostics.flake8,
		-- diagnostics.mypy,
		-- completion.tags,
		-- completion.vsnip,
	},
})

-- -- set a formatter, this will override the language server formatting capabilities (if it exists)
local formatters = require("lvim.lsp.null-ls.formatters")
formatters.setup({
	{ command = "black", filetypes = { "python" } },
	{ command = "isort", filetypes = { "python" } },
	-- { command = "yapf", filetypes = { "python" } },
	{
		-- each formatter accepts a list of options identical to https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md#Configuration
		command = "prettier",
		---@usage arguments to pass to the formatter
		-- these cannot contain whitespaces, options such as `--line-width 80` become either `{'--line-width', '80'}` or `{'--line-width=80'}`
		extra_args = { "--print-with", "100" },
		---@usage specify which filetypes to enable. By default a providers will attach to all the filetypes it supports.
		filetypes = { "typescript", "typescriptreact" },
	},
})

-- -- set additional linters
local linters = require("lvim.lsp.null-ls.linters")
linters.setup({
	{ command = "flake8", filetypes = { "python" } },
	{
		-- each linter accepts a list of options identical to https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md#Configuration
		command = "shellcheck",
		---@usage arguments to pass to the formatter
		-- these cannot contain whitespaces, options such as `--line-width 80` become either `{'--line-width', '80'}` or `{'--line-width=80'}`
		extra_args = { "--severity", "warning" },
	},
	{
		command = "codespell",
		---@usage specify which filetypes to enable. By default a providers will attach to all the filetypes it supports.
		filetypes = { "javascript", "python" },
	},
})

-- Additional Plugins
lvim.plugins = {
	{
		-- "RRethy/vim-illuminate",
		"andymass/vim-matchup",
		event = "CursorMoved",
		config = function()
			vim.g.matchup_matchparen_offscreen = { method = "popup" }
		end,
	},
	-- {
	--   "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
	--   config = function()
	--     require("lsp_lines").setup()
	--   end,
	-- },
	{ "karb94/neoscroll.nvim" },
	{ "junegunn/goyo.vim" },
	{ "gosukiwi/vim-atom-dark" },
	{ "gregsexton/Atom" },
	{ "savq/melange" },
	{ "nvim-treesitter/playground", events = "BufEnter" },
	{ "joshdick/onedark.vim" },
	{ "lunarvim/colorschemes" },
	{
		cmd = "TroubleToggle",
		"folke/trouble.nvim",
	},
	{
		"norcalli/nvim-colorizer.lua",
		config = function()
			require("colorizer").setup({ "css", "scss", "html", "javascript" }, {
				RGB = true, -- #RGB hex codes
				RRGGBB = true, -- #RRGGBB hex codes
				RRGGBBAA = true, -- #RRGGBBAA hex codes
				rgb_fn = true, -- CSS rgb() and rgba() functions
				hsl_fn = true, -- CSS hsl() and hsla() functions
				css = true, -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
				css_fn = true, -- Enable all CSS *functions*: rgb_fn, hsl_fn
			})
		end,
	},
}

-- default configuration
-- require('illuminate').configure({
--   -- providers: provider used to get references in the buffer, ordered by priority
--   providers = {
--     'lsp',
--     'treesitter',
--     'regex',
--   },
--   delay = 20,
--   -- delay: delay in milliseconds
--   -- filetype_overrides: filetype specific overrides.
--   -- The keys are strings to represent the filetype while the values are tables that
--   -- supports the same keys passed to .configure except for filetypes_denylist and filetypes_allowlist
--   filetype_overrides = {},
--   -- filetypes_denylist: filetypes to not illuminate, this overrides filetypes_allowlist
--   filetypes_denylist = {
--     'dirvish',
--     'fugitive',
--   },
--   -- filetypes_allowlist: filetypes to illuminate, this is overriden by filetypes_denylist
--   filetypes_allowlist = {},
--   -- modes_denylist: modes to not illuminate, this overrides modes_allowlist
--   -- See `:help mode()` for possible values
--   modes_denylist = {},
--   -- modes_allowlist: modes to illuminate, this is overriden by modes_denylist
--   -- See `:help mode()` for possible values
--   modes_allowlist = {},
--   -- providers_regex_syntax_denylist: syntax to not illuminate, this overrides providers_regex_syntax_allowlist
--   -- Only applies to the 'regex' provider
--   -- Use :echom synIDattr(synIDtrans(synID(line('.'), col('.'), 1)), 'name')
--   providers_regex_syntax_denylist = {},
--   -- providers_regex_syntax_allowlist: syntax to illuminate, this is overriden by providers_regex_syntax_denylist
--   -- Only applies to the 'regex' provider
--   -- Use :echom synIDattr(synIDtrans(synID(line('.'), col('.'), 1)), 'name')
--   providers_regex_syntax_allowlist = {},
--   -- under_cursor: whether or not to illuminate under the cursor
--   under_cursor = true,
--   -- large_file_cutoff: number of lines at which to use large_file_config
--   -- The `under_cursor` option is disabled when this cutoff is hit
--   large_file_cutoff = nil,
--   -- large_file_config: config to use for large files (based on large_file_cutoff).
--   -- Supports the same keys passed to .configure
--   -- If nil, vim-illuminate will be disabled for large files.
--   large_file_overrides = nil,
--   -- min_count_to_highlight: minimum number of matches required to perform highlighting
--   min_count_to_highlight = 1,
-- })

local cmd = vim.cmd

-- Illuminate
cmd([[
  augroup illuminate_augroup
      autocmd!
      autocmd VimEnter * hi link illuminatedWord CursorLine
  augroup END
]])

cmd([[
  augroup illuminate_augroup
      autocmd!
      autocmd VimEnter * hi illuminatedWord cterm=underline gui=underline
  augroup END
]])

cmd([[
  augroup illuminate_augroup
      autocmd!
      autocmd VimEnter * hi illuminatedCurWord cterm=italic gui=italic
  augroup END
]])

require("neoscroll").setup({
	easing_function = "quadratic", -- Default easing function
	-- Set any other options as needed
})

-- Autocommands (https://neovim.io/doc/user/autocmd.html)
vim.api.nvim_create_autocmd("BufEnter", {
	pattern = { "*.json", "*.jsonc" },
	-- enable wrap mode for json files only
	command = "setlocal wrap",
})

-- Range formatting (doesn't work) from here: https://github.com/LunarVim/LunarVim/issues/2741#issuecomment-1192511242
lvim.lsp.on_attach_callback = function(_, bufnr)
	local function buf_set_option(...)
		vim.api.nvim_buf_set_option(bufnr, ...)
	end

	-- use gq for formatting
	buf_set_option("formatexpr", "v:lua.vim.lsp.formatexpr(#{timeout_ms:250})")
end
