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

https://github.com/user-attachments/assets/df9d17c9-f463-4fcc-a241-13e9a67860ab

### Splits, moving, swapping

`<leader>|` / `<leader>-` split, `<C-hjkl>` move, `<C-arrows>` resize,
`<leader>H/J/K/L` new edge buffer, `<leader>ws` swap mode, `<leader>x` close,
`<leader>z` close others.

https://github.com/user-attachments/assets/ab0dce13-4200-4c08-b231-35d9cbdfff00

### Terminal and sessions

`<leader>t` floating terminal that keeps running when hidden, `<leader>ss` save
session for the folder, `<leader>sr` restore it.

https://github.com/user-attachments/assets/ca5cdd4e-f19e-42b6-bb31-48136f4729c8

### Diagnostics, formatting, copy as image

`<leader>k` show diagnostic, `<leader>fm` format, `p` paste without losing the
clipboard, `Tab`/`S-Tab` indent in visual mode, `<leader>ci` copy selection as
SVG.

https://github.com/user-attachments/assets/db8d7d81-f632-4486-96a1-74f314fb3b15

### Live PDF and grammar review

`<leader>ll` live compile to Skim, `<leader>lr` grammar review (`a` accept, `n`
next), `<leader>fm` format and flatten `$$` blocks.

https://github.com/user-attachments/assets/dc11cf48-cc1e-4694-b562-364682ded338

### Inline math rendering

`<leader>lm` render `$$` formulas inline, re-renders on save.

https://github.com/user-attachments/assets/e0478efb-6f9d-451a-baf8-f97cd65b6829

### Live browser preview

`<leader>ll` live render HTML in the browser, reloads on save, again to stop.

https://github.com/user-attachments/assets/9bcd22ae-32d5-4327-81a2-cf8e66844df9

## License

[MIT](LICENSE) Do whatever you like.
