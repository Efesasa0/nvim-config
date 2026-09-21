# nvim-config

Motivation: I have started making a switch to nvim as I increasingly found
myself using vim environments for accessing compute platforms and VS Code was
simply not rendering well with recurring issues. Sometimes the best fix is
migration to another method I guess. Why in this age of agentic tools with
optimized workflows? Idk, just testing it and like the ownership aspect of it.

## Setup

For setup instructions please see [SETUP.md](SETUP.md)

## Features

The current config is based on [lazy.nvim](https://github.com/folke/lazy.nvim).
`<leader>` is `<space>`.

### Search and file tree

`<leader>ff` find files, `<leader>fg` grep, `<leader>e` file tree, `/` search
with centered `n`/`N`, `<leader>a` select all, `<leader><space>` copy path.

https://github.com/Efesasa0/nvim-config/blob/main/content/01.mp4

### Splits, moving, swapping

`<leader>|` / `<leader>-` split, `<C-hjkl>` move, `<C-arrows>` resize,
`<leader>H/J/K/L` new edge buffer, `<leader>ws` swap mode, `<leader>x` close,
`<leader>z` close others.

https://github.com/Efesasa0/nvim-config/blob/main/content/02.mp4

### Terminal and sessions

`<leader>t` floating terminal that keeps running when hidden, `<leader>ss` save
session for the folder, `<leader>sr` restore it.

https://github.com/Efesasa0/nvim-config/blob/main/content/03.mp4

### Diagnostics, formatting, copy as image

`<leader>k` show diagnostic, `<leader>fm` format, `p` paste without losing the
clipboard, `Tab`/`S-Tab` indent in visual mode, `<leader>ci` copy selection as
SVG.

https://github.com/Efesasa0/nvim-config/blob/main/content/04.mp4

### Live PDF and grammar review

`<leader>ll` live compile to Skim, `<leader>lr` grammar review (`a` accept, `n`
next), `<leader>fm` format and flatten `$$` blocks.

https://github.com/Efesasa0/nvim-config/blob/main/content/05.mp4

### Inline math rendering

`<leader>lm` render `$$` formulas inline, re-renders on save.

https://github.com/Efesasa0/nvim-config/blob/main/content/06.mp4

### Live browser preview

`<leader>ll` live render HTML in the browser, reloads on save, again to stop.

https://github.com/Efesasa0/nvim-config/blob/main/content/07.mp4
