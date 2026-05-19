return {
	"nvimdev/dashboard-nvim",
	event = "VimEnter",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		require("dashboard").setup({
			theme = "doom",
			config = {
				header = { "", "" },
				-- 2. CENTER
				center = {
					{ icon = "   ", desc = "SPC ff  Find files       C-n  Next result    ", action = "Telescope find_files", key = "f", key_hl = "Number", icon_hl = "Title", desc_hl = "Comment" },
					{ icon = "   ", desc = "SPC fg  Live grep        C-p  Prev result    ", action = "Telescope live_grep", key = "g", key_hl = "Number", icon_hl = "Title", desc_hl = "Comment" },
					{ icon = "   ", desc = "SPC fb  Buffers          C-x  Open in split  ", action = "Telescope buffers", key = "b", key_hl = "Number", icon_hl = "Title", desc_hl = "Comment" },
					{ icon = "   ", desc = "SPC e   File explorer    C-v  Open in vsplit ", action = "Neotree toggle", key = "e", key_hl = "Number", icon_hl = "Title", desc_hl = "Comment" },
					{ icon = "   ", desc = "SPC fk  All keybindings                     ", action = "Telescope keymaps", key = "k", key_hl = "Number", icon_hl = "Title", desc_hl = "Comment" },
					{ icon = "   ", desc = "New file                                     ", action = "enew", key = "n", key_hl = "Number", icon_hl = "Title", desc_hl = "String" },
					{ icon = "   ", desc = "Config                                       ", action = "edit ~/.config/nvim/init.lua", key = "c", key_hl = "Number", icon_hl = "Title", desc_hl = "String" },
					{ icon = "󰩈  ", desc = "Quit                                         ", action = "qa", key = "q", key_hl = "Number", icon_hl = "Title", desc_hl = "String" },
				},
				footer = {},
			},
		})
	end,
}
