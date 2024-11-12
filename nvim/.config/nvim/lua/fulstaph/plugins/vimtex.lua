return {
	"lervag/vimtex",
	lazy = false, -- we don't want to lazy load VimTeX
	-- tag = "v2.15", -- uncomment to pin to a specific release
	init = function()
		vim.api.nvim_create_augroup("FileType", {
			group = vim.api.nvim_create_augroup("lazyvim_vimtex_conceal", { clear = true }),
			pattern = { "bib", "tex" },
			callback = function()
				vim.wo.conceallevel = 0
			end,
		})
		-- VimTeX configuration goes here, e.g.
		vim.g.vimtex_mapping_disable = { ["n"] = { "K" } }
		vim.g.vimtext_quickfix_method = vim.fn.executable("pplatex") == 1 and "pplatex" or "latexlog"

		vim.g.vimtex_view_method = "zathura"
		vim.g.vimtex_compiler_latexmk = {
			aux_dir = "./aux",
			out_dir = "./out",
		}
	end,
}
