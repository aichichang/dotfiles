function SetColor(color)
	-- Set the default scheme to tokyonight
	-- Otherwise set whatever color from the argument
	color = color or "tokyonight-night"
	vim.cmd.colorscheme(color)

	-- Set the background and the floating bg to transparent
	vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
	vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
end

SetColor()

