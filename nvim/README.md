# Neovim Configuration

Personal Neovim configuration files.

## Installation

### macOS/Linux

```bash
# Backup existing config (if any)
mv ~/.config/nvim ~/.config/nvim.backup

# Clone and copy
git clone https://github.com/lenliu3/dev_env
cp -r dev_env/nvim ~/.config/
```

### Windows

```powershell
# Backup existing config (if any)
Move-Item $env:LOCALAPPDATA\nvim $env:LOCALAPPDATA\nvim.backup

# Clone and copy
git clone https://github.com/lenliu3/dev_env
Copy-Item -Recurse dev_env\nvim $env:LOCALAPPDATA\
```

## Tmux Configuration

### macOS/Linux

```bash
# Backup existing config (if any)
mv ~/.tmux.conf ~/.tmux.conf.backup

# Clone and copy
git clone https://github.com/lenliu3/dev_env
cp dev_env/tmux.conf ~/.tmux.conf
```

### Windows

```powershell
# Backup existing config (if any)
Move-Item $env:USERPROFILE\.tmux.conf $env:USERPROFILE\.tmux.conf.backup

# Clone and copy
git clone https://github.com/lenliu3/dev_env
Copy-Item dev_env\tmux.conf $env:USERPROFILE\.tmux.conf
```

## Usage

Launch Neovim:
```bash
nvim
```
