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
	"    <C-h/j/k/l>    Move windows        <leader>=      Equalize sizes",
	"    <C-arrows>     Resize splits",
	"                                       SESSIONS",
	"    TERMINAL                           <leader>ss     Save session",
	"    <leader>t      Toggle terminal     <leader>sr     Restore session",
	"",
	"    EDITING                            LATEX  /  HTML  /  MD",
	"    <leader>p      Paste no-yank       <leader>ll     Live render",
	"    <leader>fm     Format buffer       <leader>lr     Grammar review",
	"    <leader>ci     Copy as SVG (vis)   <leader>lm     Math render",
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
	local wo = vim.wo[0][0]
	wo.number = false
	wo.relativenumber = false
	wo.cursorline = false
	wo.signcolumn = "no"
	wo.list = false

	local function dismiss()
		vim.cmd("enew")
	end
	vim.keymap.set("n", "q", dismiss, { buffer = buf, nowait = true })
	vim.keymap.set("n", "<Esc>", dismiss, { buffer = buf, nowait = true })
end

return M
