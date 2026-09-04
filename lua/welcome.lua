local M = {}

local lines = {
	"",
	"",
	"                            N V I M",
	"",
	"",
	"    FILES                              WINDOWS",
	"    <leader>e      File tree           <leader>|      Split vertical",
	"    <leader>k      Keymap help         <leader>-      Split horizontal",
	"                                       <leader>H      New left",
	"    SEARCH                             <leader>L      New right",
	"    n  /  N        Next/prev result    <leader>K      New top",
	"    <leader>a      Select all          <leader>J      New bottom",
	"    <leader>space  Clear search        <leader>x      Close window",
	"                                       <leader>z      Close others",
	"    NAVIGATION                         <leader>ws     Swap windows",
	"    <C-h/j/k/l>    Move windows",
	"    <C-arrows>     Resize splits       SESSIONS",
	"                                       <leader>ss     Save session",
	"    TERMINAL                           <leader>sr     Restore session",
	"    <leader>t      Toggle terminal",
	"                                       LATEX  /  HTML  /  MD",
	"    EDITING                            <leader>ll     Live render",
	"    <leader>p      Paste no-yank       <leader>lr     Grammar review",
	"    Tab / S-Tab    Indent (visual)",
	"",
	"",
	"                        press  q  or  <Esc>  to dismiss",
	"",
}

function M.show()
	local buf = vim.api.nvim_create_buf(false, true)
	vim.bo[buf].bufhidden = "wipe"
	vim.bo[buf].buftype = "nofile"
	vim.bo[buf].swapfile = false
	vim.bo[buf].filetype = "welcome"

	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.bo[buf].modifiable = false
	vim.bo[buf].modified = false

	vim.api.nvim_set_current_buf(buf)
	vim.wo.number = false
	vim.wo.relativenumber = false
	vim.wo.cursorline = false
	vim.wo.signcolumn = "no"
	vim.wo.list = false

	local function dismiss()
		vim.cmd("enew")
	end
	vim.keymap.set("n", "q", dismiss, { buffer = buf, nowait = true })
	vim.keymap.set("n", "<Esc>", dismiss, { buffer = buf, nowait = true })
end

return M
