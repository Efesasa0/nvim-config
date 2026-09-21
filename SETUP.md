# Setup

## macOS

First, back up your existing config if you have one, then clone the repo.

```bash
mv ~/.config/nvim ~/.config/nvim.bak
git clone https://github.com/Efesasa0/nvim-config ~/.config/nvim
```

Then, install the dependencies via Homebrew. iTerm2 can be swapped with
[kitty](https://sw.kovidgoyal.net/kitty/) or [Ghostty](https://ghostty.org).
Skim is the PDF viewer used for live LaTeX rendering. ImageMagick is used by
`image.nvim` to draw inline math, and the Nerd Font provides the file icons (set
it as your terminal font afterwards).

```bash
brew install \
  neovim \
  git \
  ripgrep \
  fd \
  node \
  uv \
  tree-sitter-cli \
  imagemagick \
  tmux

brew install --cask \
  iterm2 \
  skim \
  font-jetbrains-mono-nerd-font
```

Tree-sitter parsers and some plugins are compiled natively, so Apple's compiler
tools are needed too.

```bash
xcode-select --install
```

For live HTML server (`<leader>ll`) and code snippet to SVG (`<leader>ci`):

```bash
npm install -g live-server svgo
brew install charmbracelet/tap/freeze
```

Then TeX. `latexmk` drives VimTeX compiles, `dvipng`, `standalone` and `preview`
are used by inline math rendering (`<leader>lm`). `latexindent` comes from
Homebrew since that build does not need extra Perl modules.

```bash
brew install --cask basictex
brew install latexindent
eval "$(/usr/libexec/path_helper)"
sudo tlmgr update --self
sudo tlmgr install latexmk dvipng standalone preview
```

Launch it in any project directory.

```bash
nvim
```

On first launch, let Lazy, Mason and Tree-sitter finish installing. Mason
installs the language servers and linters but not the formatters, so install
those once from inside Neovim:

```vim
:MasonInstall stylua prettier black isort
```

Restart Neovim and it is good to go.

## Linux / Ubuntu / Debian

Back up any existing config and clone the repo to `~/.config/nvim`. The
directory must be named `nvim`.

```bash
mv ~/.config/nvim ~/.config/nvim.bak
git clone https://github.com/Efesasa0/nvim-config ~/.config/nvim
```

Install the basic dependencies.

```bash
sudo apt update
sudo apt install -y \
  git \
  curl \
  unzip \
  build-essential \
  python3 \
  python3-pip \
  python3-venv \
  ripgrep \
  fd-find \
  imagemagick \
  tmux
```

Ubuntu names the `fd` binary `fdfind`, so link it as `fd`.

```bash
mkdir -p ~/.local/bin
ln -sf "$(which fdfind)" ~/.local/bin/fd
```

The `nodejs` package from apt is too old for prettier and pyright, so install
Node 22 from NodeSource instead.

```bash
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt install -y nodejs
```

Then install Neovim.

```bash
cd /tmp
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim
```

Install the Tree-sitter CLI into `~/.local/bin` and add it to `PATH`.

```bash
cd /tmp
curl -fLO https://github.com/tree-sitter/tree-sitter/releases/latest/download/tree-sitter-cli-linux-x64.zip
unzip -o tree-sitter-cli-linux-x64.zip
mv tree-sitter ~/.local/bin/tree-sitter
chmod +x ~/.local/bin/tree-sitter

echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
tree-sitter --version
```

Install the HTML live server and SVG tools. `freeze` is installed from its
GitHub release.

```bash
sudo npm install -g live-server svgo
cd /tmp
curl -fLO https://github.com/charmbracelet/freeze/releases/download/v0.2.2/freeze_0.2.2_Linux_x86_64.tar.gz
tar -xzf freeze_0.2.2_Linux_x86_64.tar.gz
mv freeze_0.2.2_Linux_x86_64/freeze ~/.local/bin/freeze
```

For LaTeX, install TeX Live with `latexmk`, `latexindent` and `dvipng`.

```bash
sudo apt install -y texlive-latex-extra texlive-extra-utils latexmk dvipng
```

Note that `<leader>ci` copies through `pbcopy` and the LaTeX viewer is Skim, so
both are macOS-only for now.

Launch nvim in any project directory, let Lazy, Mason and Tree-sitter finish,
then install the formatters.

```vim
:MasonInstall stylua prettier black isort
```
