local status, null_ls = pcall(require, "null-ls")
if not status then
	return
end

local formatting = null_ls.builtins.formatting
local diagnostics = null_ls.builtins.diagnostics
local completion = null_ls.builtins.completion
local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
--TODO: Not working...
--[[ local function has_prettier_configured(utils)
	return utils.root_has_file({ ".prettierrc", ".prettierrc.json", ".prettierrc.js" })
end ]]

null_ls.setup({
	sources = {
		formatting.stylua,
		formatting.prettierd,
		--[[ formatting.prettier.with({
			condition = has_prettier_configured,
		}), ]]
		completion.spell,
		diagnostics.eslint_d,
		diagnostics.cfn_lint,
		--[[ 		code_actions.eslint_d, ]]
	},
	on_attach = function(client, bufnr)
		if client.supports_method("textDocument/formatting") then
			vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
			vim.api.nvim_create_autocmd("BufWritePre", {
				group = augroup,
				buffer = bufnr,
				callback = function()
					vim.lsp.buf.format({
						bufnr = bufnr,
						async = false,
						filter = function(client)
							return client.name == "null-ls"
						end,
					})
				end,
			})
		end
	end,
})
