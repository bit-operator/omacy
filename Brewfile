# omacy — single source of truth for macOS packages.
# Apply with: brew bundle --file ~/Projects/MacOS-Personalization/Brewfile

tap "nikitabobko/tap"        # AeroSpace
tap "FelixKratz/formulae"    # SketchyBar, JankyBorders
tap "laishulu/homebrew"      # macism

# --- Dotfiles / shell -------------------------------------------------------
brew "chezmoi"
brew "git"
brew "starship"
brew "zoxide"
brew "fzf"
brew "atuin"                 # local history search only — sync stays disabled
brew "direnv"

# --- Modern CLI -------------------------------------------------------------
brew "eza"
brew "bat"
brew "fd"
brew "ripgrep"
brew "git-delta"
brew "lazygit"
brew "btop"
brew "yazi"
brew "jq"
brew "yq"
brew "tlrc"                  # tldr client
brew "gh"
brew "wget"

# --- Terminal workflow ------------------------------------------------------
brew "tmux"
brew "sesh"
brew "neovim"
brew "tree-sitter-cli"       # required by nvim-treesitter (main branch)
brew "macism"                # nvim: switch to English when leaving insert mode

# --- Runtimes / toolchains --------------------------------------------------
brew "mise"
brew "uv"
brew "node"

# Coder CLI is NOT installed from Homebrew: it must match your deployment's server version.
# Download it from your deployment (https://<coder-host>/bin/coder-darwin-arm64) into ~/.local/bin.

# --- Desktop ----------------------------------------------------------------
brew "FelixKratz/formulae/sketchybar"
brew "FelixKratz/formulae/borders"
cask "nikitabobko/tap/aerospace"
cask "karabiner-elements"    # needs admin (+ MDM approval on managed Macs) for its DriverKit extension
cask "ghostty"
cask "raycast"
cask "shortcat"              # keyboard "click hints" anywhere

# --- Fonts ------------------------------------------------------------------
cask "font-jetbrains-mono-nerd-font"
cask "font-sketchybar-app-font"
