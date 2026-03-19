# nvim-config

My Neovim config. I love it over VSCode.

Pure black theme, lazy-loaded plugins, and keybindings that make sense. Fast startup, no bloat.

## Prerequisites

- macOS (tested on macOS 15+)
- [iTerm2](https://iterm2.com/) or any terminal with true color support
- [Homebrew](https://brew.sh/)

## Setup from scratch (iTerm2 + macOS)

Follow every step in order. Do not skip anything.

### 1. Install Homebrew (if you don't have it)

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

After it finishes, follow the instructions it prints to add `brew` to your PATH. Then restart your terminal.

### 2. Install Neovim and dependencies

```bash
brew install neovim ripgrep fd node
```

- `neovim` — the editor (requires >= 0.10)
- `ripgrep` — needed by Telescope live grep
- `fd` — needed by Telescope find files
- `node` — needed by some LSP servers (pyright)

Verify Neovim version:

```bash
nvim --version
```

You should see `NVIM v0.10.x` or higher.

### 3. Install a Nerd Font

Icons will look broken without this.

```bash
brew install --cask font-jetbrains-mono-nerd-font
```

### 4. Configure iTerm2 to use the Nerd Font

1. Open **iTerm2**
2. Go to **iTerm2 → Settings** (or press `Cmd + ,`)
3. Go to **Profiles → Text**
4. Under **Font**, click the dropdown and select **JetBrainsMono Nerd Font**
5. Set size to **14** (or whatever you prefer)
6. Make sure **Use ligatures** is checked (optional but nice)

### 5. Set iTerm2 colors for pure black background

1. Still in **iTerm2 → Settings → Profiles**
2. Go to the **Colors** tab
3. Set **Background** color to `#000000` (pure black)
4. Under **Basic Colors**, set **Foreground** to `#ffffff`

This is optional — the Neovim colorscheme handles its own colors, but matching iTerm makes the edges seamless.

### 6. Clone this config

```bash
# Back up existing config if you have one
[ -d ~/.config/nvim ] && mv ~/.config/nvim ~/.config/nvim.bak

# Back up existing plugin/cache data
[ -d ~/.local/share/nvim ] && mv ~/.local/share/nvim ~/.local/share/nvim.bak
[ -d ~/.local/state/nvim ] && mv ~/.local/state/nvim ~/.local/state/nvim.bak
[ -d ~/.cache/nvim ] && mv ~/.cache/nvim ~/.cache/nvim.bak

# Clone
git clone https://github.com/Efesasa0/nvim-config.git ~/.config/nvim
```

### 7. Launch Neovim

```bash
nvim
```

On first launch:
- **lazy.nvim** will automatically install all plugins (wait for it to finish)
- **Mason** will install LSP servers (`pyright`, `lua_ls`) and linters
- **Treesitter** will compile parsers

You'll see install progress in the bottom of the screen. Wait until everything settles, then **quit and reopen**:

```
:qa
nvim
```

You should now see the dashboard with the logo.

### 8. (Optional) Python setup

If you work with Python, make sure you have a working Python with `pip`:

```bash
brew install python
pip install black isort flake8 mypy pylint
```

Or if you use conda/virtualenvs, the config auto-detects the active environment.

### 9. (Optional) LaTeX setup

```bash
brew install --cask mactex-no-gui skim
```

## Troubleshooting

**Icons look like squares or question marks:**
You didn't set the Nerd Font in iTerm2. Go back to step 4.

**"command not found: nvim":**
Run `brew install neovim` and make sure Homebrew's bin is in your PATH.

**Telescope grep doesn't work:**
Run `brew install ripgrep`.

**LSP not working for Python:**
Run `:Mason` inside Neovim and make sure `pyright` shows as installed. If not, press `i` next to it.

**Colors look wrong / not pure black:**
Make sure your terminal supports true color. In iTerm2 this works by default. If using another terminal, add to your shell profile:
```bash
export TERM=xterm-256color
```

**Plugin errors on first launch:**
Quit and reopen Neovim. Some plugins need a restart after initial install.

## Structure

```
init.lua                  -- Entry point, bootstraps lazy.nvim
lua/config/options.lua    -- Editor settings (tabs, search, clipboard, etc.)
lua/config/keymaps.lua    -- All keybindings
lua/config/autocmds.lua   -- Autocommands
lua/config/terminal.lua   -- Floating terminal (Space t)
lua/plugins/init.lua      -- Plugin specs (lazy.nvim)
lua/plugins/dashboard.lua -- Start screen
colors/pureblack.lua      -- Colorscheme
lazy-lock.json            -- Pinned plugin versions
```

## Keybindings

Leader key is `Space`.

### General

| Key | Action |
|-----|--------|
| `Space a` | Select entire file |
| `Y` | Yank to end of line |
| `Space p` | Paste without yanking (visual) |
| `Space pa` | Copy full file path |
| `n` / `N` | Next/prev search result (centered) |

### Buffers & Windows

| Key | Action |
|-----|--------|
| `Tab` / `Shift-Tab` | Next/prev buffer |
| `Space x` | Close buffer |
| `Ctrl-h/j/k/l` | Move between windows |
| `Space sv` | Vertical split |
| `Space sh` | Horizontal split |
| `Ctrl-Arrow` | Resize splits |

### Search (Telescope)

| Key | Action |
|-----|--------|
| `Space ff` | Find files |
| `Space fg` | Live grep |
| `Space fb` | Buffers |
| `Space fh` | Help tags |
| `Space fk` | All keybindings |
| `Esc` | Close Telescope |

### File Explorer (Neo-tree)

| Key | Action |
|-----|--------|
| `Space e` | Toggle file tree (right side) |
| `Esc` | Close file tree |

### Terminal

| Key | Action |
|-----|--------|
| `Space t` | Toggle floating terminal |
| `Esc` | Close floating terminal |

### LSP (active when a language server is attached)

| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gr` | Go to references |
| `K` | Hover docs |
| `Space rn` | Rename symbol |
| `Space ca` | Code action |
| `Space d` | Generate docstring |

### Jupyter (Molten)

| Key | Action |
|-----|--------|
| `Space mi` | Initialize Molten |
| `Space ml` | Evaluate line |
| `Space mr` | Re-evaluate cell |
| `Space mv` | Evaluate visual selection |
| `Space mc` | Hide output |
| `Space md` | Delete cell |

### Completion

| Key | Action |
|-----|--------|
| `Tab` / `Shift-Tab` | Navigate completion menu |
| `Enter` | Confirm selection |
| `Ctrl-Space` | Trigger completion |
| `Ctrl-a` | Accept Supermaven AI suggestion |

## Plugins

- **lazy.nvim** — plugin manager
- **bufferline.nvim** — tab bar
- **neo-tree.nvim** — file explorer
- **telescope.nvim** — fuzzy finder
- **nvim-treesitter** — syntax highlighting
- **nvim-lspconfig + mason.nvim** — LSP (pyright, lua_ls)
- **nvim-cmp** — completion
- **supermaven-nvim** — AI code completion
- **conform.nvim** — auto-formatting (black, isort, stylua)
- **nvim-lint** — linting (flake8, mypy, pylint)
- **neogen** — docstring generator
- **molten-nvim** — Jupyter notebook support
- **vimtex** — LaTeX
- **neoscroll.nvim** — smooth scrolling
- **nvim-autopairs** — auto-close brackets
- **markview.nvim** — Markdown rendering
- **dashboard-nvim** — start screen

## Uninstall

To completely remove this config and all Neovim data:

```bash
# Remove the config
rm -rf ~/.config/nvim

# Remove plugins, LSP servers, and Mason installs
rm -rf ~/.local/share/nvim

# Remove state (shada, log files)
rm -rf ~/.local/state/nvim

# Remove cache (lazy.nvim cache, etc.)
rm -rf ~/.cache/nvim
```

To restore a backup you made during install:

```bash
mv ~/.config/nvim.bak ~/.config/nvim
mv ~/.local/share/nvim.bak ~/.local/share/nvim
mv ~/.local/state/nvim.bak ~/.local/state/nvim
mv ~/.cache/nvim.bak ~/.cache/nvim
```
