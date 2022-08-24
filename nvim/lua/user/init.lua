local config = {
	-- Set colorscheme
	colorscheme = "nord",

	default_theme = {
		diagnostics_style = "italic",
	},

	lsp = {
		skip_setup = { "tsserver", "rust_analyzer" }, -- will be set up by rust-tools
	},

	-- Configure plugins
	plugins = {
		-- Add plugins, the packer syntax without the "use"
		init = {
			-- You can disable default plugins as follows:
			-- ["goolord/alpha-nvim"] = { disable = true },
			-- You can also add new plugins here as well:
			-- { "andweeb/presence.nvim" },
			-- {
			--   "ray-x/lsp_signature.nvim",
			--   event = "BufRead",
			--   config = function()
			--     require("lsp_signature").setup()
			--   end,
			-- },
			-- colorscheme
			{ "arcticicestudio/nord-vim" },
			-- Tsserver
			{
				"jose-elias-alvarez/typescript.nvim",
				after = "mason-lspconfig.nvim",
				config = function()
					require("typescript").setup({
						server = astronvim.lsp.server_settings("tsserver"),
					})
				end,
			},
			-- Go support,
			{ "fatih/vim-go" },
			-- Rust support
			{
				"simrat39/rust-tools.nvim",
				after = { "nvim-lspconfig", "mason-lspconfig.nvim" },
				-- Is configured via the server_registration_override installed below!
				config = function()
					-- local extension_path = vim.fn.stdpath "data" .. "/dapinstall/codelldb/extension"
					-- local codelldb_path = extension_path .. "/adapter/codelldb"
					-- local liblldb_path = extension_path .. "/lldb/lib/liblldb.so"

					local rt = require("rust-tools")

					rt.setup({
						-- server = astronvim.lsp.server_settings "rust_analyzer",
						server = {
							cargo = {
								loadOutDirsFromCheck = true,
							},
							checkOnSave = {
								command = "clippy",
							},
							experimental = {
								procAttrMacros = true,
							},
							workspace = {
								symbol = {
									search = {
										kind = "all_symbols",
									},
								},
							},
							-- on_attach is a callback called when the language server attachs to the buffer
							on_attach = function(_, bufnr)
								-- Hover actions
								vim.keymap.set("n", "<C-space>", rt.hover_actions.hover_actions, { buffer = bufnr })
								-- Code action groups
								vim.keymap.set(
									"n",
									"<Leader>a",
									rt.code_action_group.code_action_group,
									{ buffer = bufnr }
								)
							end,
							settings = {
								-- to enable rust-analyzer settings visit:
								-- https://github.com/rust-analyzer/rust-analyzer/blob/master/docs/user/generated_config.adoc
								["rust-analyzer"] = {
									-- enable clippy on save
									checkOnSave = {
										command = "clippy",
									},
								},
							},
						},
						-- dap = {
						--   adapter = require("rust-tools.dap").get_codelldb_adapter(codelldb_path, liblldb_path),
						-- },
						tools = { -- rust-tools options
							autoSetHints = true,
							inlay_hints = {
								show_parameter_hints = false,
								parameter_hints_prefix = "",
								other_hints_prefix = "",
							},
						},
					})
				end,
			},
		},
		-- All other entries override the setup() call for default plugins
		["null-ls"] = function(config)
			local null_ls = require("null-ls")
			-- Check supported formatters and linters
			-- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/formatting
			-- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/diagnostics
			config.sources = {
				null_ls.builtins.diagnostics.eslint_d,
				null_ls.builtins.code_actions.eslint_d,
				null_ls.builtins.formatting.prettier,
				null_ls.builtins.diagnostics.stylelint,
				null_ls.builtins.formatting.stylua,
				-- Set a formatter
				null_ls.builtins.formatting.rufo,
				-- Set a linter
				null_ls.builtins.diagnostics.rubocop,
			}
			-- set up null-ls's on_attach function
			config.on_attach = function(client, bufnr)
				local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
				-- if client.resolved_capabilities.document_formatting then
				if client.supports_method("textDocument/formatting") then
					vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
					vim.api.nvim_create_autocmd("BufWritePre", {
						desc = "Auto format before save",
						buffer = bufnr,
						group = augroup,
						-- pattern = "<buffer>",
						-- callback = vim.lsp.buf.formatting_sync,
						callback = function()
							vim.lsp.buf.formatting_sync()
						end,
					})
				end
			end
			return config -- return final config table
		end,
		treesitter = {
			ensure_installed = { "lua", "tsx", "json", "yaml", "html", "scss", "go", "rust" },
		},
		["mason-lspconfig"] = {
			ensure_installed = { "sumneko_lua", "tsserver", "rust_analyzer" },
		},
		packer = {
			compile_path = vim.fn.stdpath("data") .. "/packer_compiled.lua",
		},
		cmp = function(config)
			local cmp = require("cmp")
			-- Enable LSP snippets
			config.snippet = {
				expand = function(args)
					vim.fn["vsnip#anonymous"](args.body)
				end,
			}

			config.mapping = {
				["<C-p>"] = cmp.mapping.select_prev_item(),
				["<C-n>"] = cmp.mapping.select_next_item(),
				-- Add tab support
				["<S-Tab>"] = cmp.mapping.select_prev_item(),
				["<Tab>"] = cmp.mapping.select_next_item(),
				["<C-d>"] = cmp.mapping.scroll_docs(-4),
				["<C-f>"] = cmp.mapping.scroll_docs(4),
				["<C-Space>"] = cmp.mapping.complete(),
				["<C-e>"] = cmp.mapping.close(),
				["<CR>"] = cmp.mapping.confirm({
					behavior = cmp.ConfirmBehavior.Insert,
					select = true,
				}),
			}

			-- Installed sources
			config.sources = {
				{ name = "nvim_lsp" },
				{ name = "vsnip" },
				{ name = "path" },
				{ name = "buffer" },
			}

			config.source_priority = {
				nvim_lsp = 1000,
				luasnip = 750,
				buffer = 500,
				path = 250,
			}
			return config
		end,
	},

	-- LuaSnip Options
	luasnip = {
		-- Add paths for including more VS Code style snippets in luasnip
		vscode_snippet_paths = {},
		-- Extend filetypes
		filetype_extend = {
			javascript = { "javascriptreact" },
		},
	},
	-- Modify which-key registration
	["which-key"] = {
		-- Add bindings
		register_mappings = {
			-- first key is the mode, n == normal mode
			n = {
				-- second key is the prefix, <leader> prefixes
				["<leader>"] = {
					-- which-key registration table for normal mode, leader prefix
					-- ["N"] = { "<cmd>tabnew<cr>", "New Buffer" },
				},
			},
		},
	},
	-- CMP Source Priorities
	-- modify here the priorities of default cmp sources
	-- higher value == higher priority
	-- The value can also be set to a boolean for disabling default sources:
	-- false == disabled
	-- true == 1000
	-- cmp = {
	--   source_priority = {
	--     nvim_lsp = 1000,
	--     luasnip = 750,
	--     buffer = 500,
	--     path = 250,
	--   },
	-- },
	--
	-- Diagnostics configuration (for vim.diagnostics.config({}))
	diagnostics = {
		virtual_text = true,
		underline = true,
	},
	mappings = {
		-- first key is the mode
		n = {
			-- second key is the lefthand side of the map
			["<C-s>"] = { ":w!<cr>", desc = "Save File" },
		},
		t = {
			-- setting a mapping to false will disable it
			-- ["<esc>"] = false,
		},
	},
	-- This function is run last
	-- good place to configuring augroups/autocommands and custom filetypes
	polish = function()
		-- Set key binding
		-- Set autocommands
		vim.api.nvim_create_augroup("packer_conf", { clear = true })
		vim.api.nvim_create_autocmd("BufWritePost", {
			desc = "Sync packer after modifying plugins.lua",
			group = "packer_conf",
			pattern = "plugins.lua",
			command = "source <afile> | PackerSync",
		})
		-- Set up custom filetypes
		-- vim.filetype.add {
		--   extension = {
		--     foo = "fooscript",
		--   },
		--   filename = {
		--     ["Foofile"] = "fooscript",
		--   },
		--   pattern = {
		--     ["~/%.config/foo/.*"] = "fooscript",
		--   },
		-- }
	end,
}
return config
