-- This file can be loaded by, {}) , {})calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd([[packadd packer.nvim]])
vim.cmd([[ let g:neo_tree_remove_legacy_commands = 1 ]])

return require("packer").startup(function(use)
	-- Packer can manage itself
	use("wbthomason/packer.nvim")

	use({
		"nvim-telescope/telescope.nvim",
		tag = "0.1.1",
		-- or                            , branch = '0.1.x',
		requires = { { "nvim-lua/plenary.nvim" } },
	})

	use({
		"folke/tokyonight.nvim",
		config = function()
			vim.cmd("colorscheme tokyonight-night")
		end,
	})

	use("jose-elias-alvarez/null-ls.nvim") -- Use Neovim as a language server to inject LSP diagnostics, code actions, and more via Lua

	use("nvim-treesitter/nvim-treesitter", { run = ":TSUpdate" })

	use("nvim-treesitter/playground")

	use("ThePrimeagen/harpoon")

	use("mbbill/undotree")

	use("tpope/vim-fugitive")

	use("simrat39/rust-tools.nvim")

	use("folke/which-key.nvim")

	use("arkav/lualine-lsp-progress")

	use("mrjones2014/smart-splits.nvim")

	use("dense-analysis/ale")

	use("windwp/nvim-autopairs")

	use("nvim-tree/nvim-web-devicons")

	use("rhysd/git-messenger.vim")

	use({
		"numToStr/Comment.nvim",
		config = function()
			local numStatus, comments = pcall(require, "Comment")
			if not numStatus then
				return
			end

			comments.setup()
		end,
	})

	use({
		"nvim-lualine/lualine.nvim",
		requires = { "nvim-tree/nvim-web-devicons", opt = true },
	})

	use({
		"VonHeikemen/lsp-zero.nvim",
		branch = "v1.x",
		requires = {
			-- LSP Support
			{ "neovim/nvim-lspconfig" }, -- Required
			{ "williamboman/mason.nvim" }, -- Optional
			{ "williamboman/mason-lspconfig.nvim" }, -- Optional

			-- Autocompletion
			{ "hrsh7th/nvim-cmp" }, -- Required
			{ "hrsh7th/cmp-nvim-lsp" }, -- Required
			{ "hrsh7th/cmp-buffer" }, -- Optional
			{ "hrsh7th/cmp-path" }, -- Optional
			{ "saadparwaiz1/cmp_luasnip" }, -- Optional
			{ "hrsh7th/cmp-nvim-lua" }, -- Optional

			-- Snippets
			{ "L3MON4D3/LuaSnip" }, -- Required
			{ "rafamadriz/friendly-snippets" }, -- Optional
		},
	})

	use({
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v2.x",
		requires = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
			"MunifTanjim/nui.nvim",
		},
	})
end)
