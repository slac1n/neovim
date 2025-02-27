return {
	"zbirenbaum/copilot.lua",
	cmd = "Copilot",
	event = "InsertEnter",
	enabled = true,
	config = function()
		require("copilot").setup({
			suggestions = {
				enabled = false,
				-- auto_trigger = false,
				-- hide_during_completion = true,
			},
			panel = {
				enabled = false,
			},
		})
	end,
}
