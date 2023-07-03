local ssStatus, ss = pcall(require, "smart-splits")

if not ssStatus then
	vim.keymap.set("n", "<C-h>", "<C-w>h")
	vim.keymap.set("n", "<C-j>", "<C-w>j")
	vim.keymap.set("n", "<C-k>", "<C-w>k")
	vim.keymap.set("n", "<C-l>", "<C-w>l")
	vim.keymap.set("n", "<C-Up>", "<cmd>resize -2<CR>")
	vim.keymap.set("n", "<C-Down>", "<cmd>resize +2<CR>")
	vim.keymap.set("n", "<C-Left>", "<cmd>vertical resize -2<CR>")
	vim.keymap.set("n", "<C-Right>", "<cmd>vertical resize +2<CR>")
else
	ss.setup({
		ignored_filetypes = {
			"nofile",
			"quickfix",
			"qf",
			"prompt",
		},
		ignored_buftypes = { "nofile" },
	})
	-- Better window navigation
	vim.keymap.set("n", "<C-h>", ss.move_cursor_left)
	vim.keymap.set("n", "<C-j>", ss.move_cursor_down)
	vim.keymap.set("n", "<C-k>", ss.move_cursor_up)
	vim.keymap.set("n", "<C-l>", ss.move_cursor_right)

	-- Resize with arrows
	vim.keymap.set("n", "<C-Up>", ss.resize_up)
	vim.keymap.set("n", "<C-Down>", ss.resize_down)
	vim.keymap.set("n", "<C-Left>", ss.resize_left)
	vim.keymap.set("n", "<C-Right>", ss.resize_right)
end
