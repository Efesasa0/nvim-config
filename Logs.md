# Logs

- 2026-07-18 - Added `<leader>ll` for HTML files to live render in Safari via `live-server` (port 5500), mirroring the LaTeX/Skim workflow.
- 2026-07-18 - Made HTML live render a toggle - second `<leader>ll` stops the live-server process.
- 2026-07-18 - HTML live render browser now configurable via `vim.g.html_preview_browser` (defaults to Safari).
- 2026-07-18 - LaTeX files now auto-wrap at 80 chars with a visual `colorcolumn` guide, matching the markdown behavior.
- 2026-07-18 - Wired `latexindent` into conform.nvim so `.tex` files are auto-formatted on save.
