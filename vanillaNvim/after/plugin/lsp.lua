local lspStatus, lsp = pcall(require, "lsp-zero")

if not lspStatus then
	return
end

lsp.preset("recommended")

-- Fix Undefined global 'vim'
lsp.configure("lua_ls", {
	cmd = { "lua-language-server" },
	settings = {
		Lua = {
			runtime = {
				version = "LuaJIT",
				path = vim.split(package.path, ";"),
			},
			diagnostics = {
				globals = { "vim" },
			},
			workspace = {
				library = {
					[vim.fn.expand("$VIMRUNTIME/lua")] = true,
					[vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true,
				},
			},
		},
	},
})

lsp.ensure_installed({
	"tsserver",
	"eslint",
	"cssls",
	"gopls",
	"jsonls",
	"rust_analyzer",
	"tflint",
	"yamlls",
})

local cmp = require("cmp")
local cmp_select = { behavior = cmp.SelectBehavior.Select }
local cmp_mappings = lsp.defaults.cmp_mappings({
	["<C-p>"] = cmp.mapping.select_prev_item(cmp_select),
	["<C-n>"] = cmp.mapping.select_next_item(cmp_select),
	["<C-y>"] = cmp.mapping.confirm({ select = true }),
	["<C-S-f>"] = cmp.mapping.scroll_docs(-4),
	["<C-f>"] = cmp.mapping.scroll_docs(4),
	["<C-Space>"] = cmp.mapping.complete(),
	["<C-e>"] = cmp.mapping.close(),
	["<CR>"] = cmp.mapping.confirm({
		behavior = cmp.ConfirmBehavior.Insert,
		select = true,
	}),
})

-- Remove tab mappings as this is override by Github Copilot
cmp_mappings["<Tab>"] = nil
cmp_mappings["<S-Tab>"] = nil

lsp.setup_nvim_cmp({
	mapping = cmp_mappings,
})

lsp.set_preferences({
	suggest_lsp_servers = false,
	sign_icons = {
		error = "E",
		warn = "W",
		hint = "H",
		info = "I",
	},
})

local null_ls = require("null-ls")

lsp.on_attach(function(client, bufnr)
	-- https://github.com/VonHeikemen/lsp-zero.nvim/issues/88
	--[[ if client.name == "eslint" then
    vim.cmd.LspStop "eslint"
    return
  end ]]
	lsp.default_keymaps({ buffer = bufnr })
	local bind = vim.keymap.set
	local opts = { buffer = bufnr, remap = false }
	local capabilities = client.server_capabilities
	local tbl_contains = vim.tbl_contains
	local tbl_isempty = vim.tbl_isempty

	bind("n", "gd", function()
		vim.lsp.buf.definition()
	end, opts)
	bind("n", "K", function()
		vim.lsp.buf.hover()
	end, opts)
	bind("n", "<leader>vws", function()
		vim.lsp.buf.workspace_symbol()
	end, opts)
	bind("n", "<leader>ld", function()
		vim.diagnostic.open_float()
	end, opts)
	bind("n", "[d", function()
		vim.diagnostic.goto_next()
	end, opts)
	bind("n", "]d", function()
		vim.diagnostic.goto_prev()
	end, opts)
	bind("n", "<leader>vca", function()
		vim.lsp.buf.code_action()
	end, opts)
	bind("n", "<leader>vrr", function()
		vim.lsp.buf.references()
	end, opts)
	bind("n", "<leader>vrn", function()
		vim.lsp.buf.rename()
	end, opts)
	bind("i", "<C-h>", function()
		vim.lsp.buf.signature_help()
	end, opts)

	-- Custom mapping
	if capabilities.documentFormattingProvider then
		bind("n", "<leader>lf", function()
			vim.lsp.buf.format({ name = "null-ls" })
		end, opts)

		vim.api.nvim_buf_create_user_command(bufnr, "Format", function()
			vim.lsp.buf.format({ name = "null-ls" })
		end, { desc = "Format file with LSP" })
		local autoformat = lsp.formatting.format_on_save
		local filetype = vim.api.nvim_buf_get_option(bufnr, "filetype")

		if
			autoformat.enabled
			and (tbl_isempty(autoformat.allow_filetypes or {}) or tbl_contains(autoformat.allow_filetypes, filetype))
			and (
				not tbl_isempty(autoformat.ignore_filetypes or {})
				or not tbl_contains(autoformat.ignore_filetypes, filetype)
			)
		then
			local autocmd_group = "auto_format_" .. bufnr
			vim.api.nvim_create_augroup(autocmd_group, { clear = true })
			vim.api.nvim_create_autocmd("BufWritePre", {
				group = autocmd_group,
				buffer = bufnr,
				desc = "Auto format buffer " .. bufnr .. " before save",
			})
			bind("n", "<leader>taf", function()
				vim.ui.toggle_autoformat()
			end, opts)
		end
	end
end)

lsp.skip_server_setup({ "rust_analyzer" })

local rust_lsp = lsp.build_options("rust_analyzer", {
	settings = {
		["rust-analyzer"] = {
			checkOnSave = {
				allFeatures = true,
				command = "clippy",
			},
		},
	},
})

lsp.setup()

require("rust-tools").setup({ server = rust_lsp })

vim.diagnostic.config({
	virtual_text = true,
	underline = true,
	float = {
		source = "always",
		border = "single",
	},
})
