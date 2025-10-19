# MyGawa Neovim Configuration

A custom Neovim configuration featuring the MyGawa theme (inspired by Kanagawa Wave) with transparent backgrounds and carefully crafted color schemes.

## Features

- **Custom MyGawa Theme**: A custom colorscheme based on Kanagawa Wave VSCode theme with full transparency
- **Session Management**: Advanced session management with slot-based navigation
- **LSP Integration**: Full LSP support with Mason for automatic server installation
- **Telescope**: Fuzzy finder for files, grep, and more
- **Harpoon**: Quick file navigation
- **GitUI Integration**: Matching theme for GitUI
- **Treesitter**: Advanced syntax highlighting
- **Completion**: nvim-cmp with snippet support
- **Formatting & Linting**: Conform.nvim and nvim-lint
- **File Explorer**: Oil.nvim for buffer-like file editing

## Requirements

- Neovim >= 0.9.0
- Git
- ripgrep
- A Nerd Font (optional, but recommended)
- Node.js (for certain LSP servers)

## Installation

### Linux & Mac
```bash
git clone https://github.com/sebastians-codes/nvim.git "${XDG_CONFIG_HOME:-$HOME/.config}"/nvim
```

### Windows PowerShell
```powershell
git clone https://github.com/sebastians-codes/nvim.git "${env:LOCALAPPDATA}\nvim"
```

### Windows CMD
```cmd
git clone https://github.com/sebastians-codes/nvim.git "%localappdata%\nvim"
```

### Post Installation
Start Neovim:
```bash
nvim
```

Lazy.nvim will automatically install all plugins on first launch.

## Theme

The configuration uses a custom MyGawa theme with:
- Transparent backgrounds throughout
- Kanagawa Wave-inspired colors
- Matching GitUI theme in `~/.config/gitui/theme.ron`

### Colors

- Background: Transparent
- Foreground: `#DCD7BA`
- Comments: `#727169`
- Strings: `#98BB6C`
- Functions: `#7E9CD8`
- Keywords: `#957FB8`
- Numbers: `#D27E99`
- Constants: `#FFA066`

## Key Plugins

- **lazy.nvim**: Plugin manager
- **telescope.nvim**: Fuzzy finder
- **nvim-lspconfig**: LSP configuration
- **nvim-treesitter**: Syntax parsing
- **harpoon**: File navigation
- **oil.nvim**: File explorer
- **mini.nvim**: Collection of minimal modules (sessions, statusline, etc.)
- **gitsigns.nvim**: Git integration

## Key Bindings

### General
- `<leader>w`: Save file

### Session Management
- `ss`: Open session manager
- `se`: Assign session to slot
- `s1-s9, s0`: Load session from slot (s0 = slot 10)
- `sq`: Save session and quit

### Tab Management
- `tn`: Open new tab with parent directory
- `tx`: Close current tab
- `tt`: Open new tab with terminal
- `t1-t9`: Go to tab 1-9

### Window Navigation
- `<C-h>`: Move to left window
- `<C-l>`: Move to right window
- `<C-j>`: Move to lower window
- `<C-k>`: Move to upper window

### File Management
- `<leader>pv`: Open parent directory
- `<leader>nf`: Create new file
- `<leader>nd`: Create new directory

### Diagnostics
- `<leader>qq`: Open quickfix list with diagnostics
- `<leader>qe`: Show diagnostic error in float
- `<leader>qa`: Show all diagnostics (Telescope)
- `<leader>qr`: Run project-wide diagnostics

### Editing
- `Alt+j`: Move line/selection down
- `Alt+k`: Move line/selection up
- `<leader>cc`: Comment/uncomment line or selection
- Auto-closing brackets: `(`, `[`, `{`, `"`, `'`

### Terminal
- `<Esc><Esc>`: Exit terminal mode

### Telescope (Fuzzy Finder)
- `<leader>sh`: Search help
- `<leader>sk`: Search keymaps
- `<leader>sf`: Search files
- `<leader>ss`: Search select Telescope
- `<leader>sw`: Search current word
- `<leader>sg`: Search by grep
- `<leader>sd`: Search diagnostics
- `<leader>sr`: Resume last search
- `<leader>s.`: Search recent files
- `<leader><leader>`: Find existing buffers
- `<leader>/`: Fuzzy search in current buffer
- `<leader>s/`: Search in open files
- `<leader>sn`: Search Neovim config files

### Harpoon (File Navigation)
- `<leader>A`: Add file to harpoon
- `<leader>a`: Open harpoon menu
- `<leader>1-5`: Select harpoon file 1-5
- `<leader>z`: Open harpoon in telescope
- `<C-S-P>`: Previous harpoon file
- `<C-S-N>`: Next harpoon file

### LSP
- `gd`: Go to definition
- `gr`: Go to references
- `gI`: Go to implementation
- `gD`: Go to declaration
- `<leader>D`: Type definition
- `<leader>ds`: Document symbols
- `<leader>ws`: Workspace symbols
- `<leader>rn`: Rename symbol
- `<leader>ca`: Code action
- `<leader>th`: Toggle inlay hints
- `K`: Hover documentation

### Formatting
- `<leader>f`: Format buffer
- `<leader>cf`: Run codespell on current file

## Configuration Structure

```
~/.config/nvim/
├── init.lua                 # Entry point
├── lua/
│   ├── config/              # Core configuration
│   │   ├── autocmds.lua
│   │   ├── keymaps.lua
│   │   ├── options.lua
│   │   └── session_manager.lua
│   ├── plugins/             # Plugin configurations
│   │   ├── mygawa.lua       # Custom theme
│   │   ├── lsp.lua
│   │   ├── telescope.lua
│   │   └── ...
│   └── snippets/            # Custom snippets
└── README.md
```

## License

MIT
