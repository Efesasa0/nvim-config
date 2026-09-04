# Logs

- 2026-07-18 - Added `<leader>ll` for HTML files to live render in Safari via `live-server` (port 5500), mirroring the LaTeX/Skim workflow.
- 2026-07-18 - Made HTML live render a toggle - second `<leader>ll` stops the live-server process.
- 2026-07-18 - HTML live render browser now configurable via `vim.g.html_preview_browser` (defaults to Safari).
- 2026-07-18 - LaTeX files now auto-wrap at 80 chars with a visual `colorcolumn` guide, matching the markdown behavior.
- 2026-07-18 - Wired `latexindent` into conform.nvim so `.tex` files are auto-formatted on save.
- 2026-07-18 - Added `latexindent.yaml` with `textWrapOptions.columns: 80` and passed `-m -l <config>` via conform so long lines actually re-wrap on save.
- 2026-07-18 - Broadened latexindent `blocksFollow.other` regex to include `\begin{...}` so text immediately after environment openings also gets wrapped.
- 2026-07-18 - Removed the 80-col `colorcolumn` guide from tex files.
- 2026-07-18 - Configured latexindent `specialBeginEnd` for `$$...$$` so display-math blocks collapse to a single line on their own row; excluded `$$` from text-wrap block boundaries so long equations stay unwrapped.
- 2026-07-18 - Added `tex_flatten_dispmath` custom conform formatter (perl one-liner) chained after latexindent to flatten multi-line `$$...$$` bodies whose internal newlines latexindent leaves intact.
- 2026-07-18 - Scoped latexindent's `specialBeginEnd` poly-switches to `displayMathTeX` and `displayMath` only, so inline `$...$` no longer gets bumped to its own line (previous global config was also matching latexindent's built-in `inlineMath` entry). Removed the redundant custom `displayMathDoubleDollar` definition since `displayMathTeX` already ships in defaults.
- 2026-07-18 - Enabled `ltex_plus` LSP via Mason for LaTeX/Markdown grammar/style/spell checking (picky rules on).
- 2026-07-18 - Added custom grammar review mode (`lua/grammar_mode.lua`) bound to `<leader>lr`. Debugger-style loop with bottom-right status bar showing bucketed counts (typosC/shortenC/passiveC/punctC/otherC) and a cursor-adjacent popup that lists suggestions + inline key hints (a=accept top, 1-5=pick, s=skip, d=dict, i=ignore rule, n/p=nav, Esc=quit).
- 2026-07-18 - Added `lua/ltex_handlers.lua` with client-side handlers for `_ltex.addToDictionary`, `_ltex.hideFalsePositives`, `_ltex.disableRules`. Words/rules persist to `~/.config/nvim/ltex-cache/*.json` and are reloaded into ltex settings on startup. Fixes "command may require a client extension" error.
- 2026-07-18 - Fixed grammar mode skip-ahead bug: was re-fetching the async LTeX diagnostic list on every navigation, which shifted the index. Now snapshots issues once at mode start and splices them out on a/d/i so the same index naturally advances to the next issue without skipping.
- 2026-07-18 - Hid the `~` end-of-buffer markers by setting `fillchars.eob = ' '`.
