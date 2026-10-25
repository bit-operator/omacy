#!/usr/bin/env bash
# omamac bootstrap — idempotent, safe to re-run.
#   ./install.sh                     macOS: packages, dotfiles, services, macOS defaults
#   ./install.sh --minimal           Linux server / Coder workspace (online): terminal stack only
#   ./install.sh --minimal --offline Linux without internet: uses the bundle shipped by `dot-push`
# Identity for git on remotes: OMAMAC_NAME / OMAMAC_EMAIL env vars (dot-push passes them).
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MINIMAL=0 OFFLINE=0
for arg in "$@"; do
  case $arg in
    --minimal) MINIMAL=1 ;;
    --offline) OFFLINE=1 ;;
    *) echo "unknown option: $arg" >&2; exit 2 ;;
  esac
done
[[ $(uname -s) == Darwin ]] || MINIMAL=1
log() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
BIN="$HOME/.local/bin"
mkdir -p "$BIN"
export PATH="$BIN:$PATH"

# ------------------------------------------------------------------------------ macOS
if ((!MINIMAL)); then
  command -v brew >/dev/null || { echo "Install Homebrew first: https://brew.sh" >&2; exit 1; }
  log "Packages (brew bundle)"
  brew bundle --file "$REPO/Brewfile" || log "Some packages failed (taps to trust / sudo needed?) — continuing"

  log "Dotfiles (chezmoi)"
  chezmoi init --source "$REPO" --apply

  log "Services: SketchyBar, JankyBorders"
  for svc in sketchybar borders; do
    command -v "$svc" >/dev/null && { brew services restart "$svc" >/dev/null && echo "  $svc running"; }
  done

  log "macOS defaults"
  "$REPO/scripts/macos-defaults.sh"
  log "Done. See README.md → 'First run' for the few manual steps (permissions, Raycast hotkey)."
  exit 0
fi

# ------------------------------------------------------------------------------ Linux / remote
if ((OFFLINE)); then
  BUNDLE="$HOME/.local/share/omamac-bundle"
  [[ -d $BUNDLE/bin ]] || { echo "No bundle at $BUNDLE — run 'dot-push <host>' from the Mac." >&2; exit 1; }
  log "Offline: installing bundled tools"
  cp -f "$BUNDLE"/bin/* "$BIN"/
  rm -rf "$HOME/.local/opt/nvim" && mkdir -p "$HOME/.local/opt" && cp -R "$BUNDLE/nvim" "$HOME/.local/opt/nvim"
  ln -sfn "$HOME/.local/opt/nvim/bin/nvim" "$BIN/nvim"
  for d in nvim/lazy zsh/plugins tmux/plugins; do
    mkdir -p "$HOME/.local/share/${d%/*}"
    rm -rf "$HOME/.local/share/$d" && cp -R "$BUNDLE/share/$d" "$HOME/.local/share/$d"
  done
  log "Dotfiles (chezmoi, externals from bundle)"
  chezmoi init --source "$REPO" --apply --promptDefaults --exclude externals
  mkdir -p "$HOME/.config/zsh/conf.d"
  printf 'export OMAMAC_OFFLINE=1   # written by install.sh --offline: no Mason / plugin downloads\n' \
    >"$HOME/.config/zsh/conf.d/00-omamac-offline.zsh"
else
  log "Online: chezmoi + mise"
  command -v chezmoi >/dev/null || sh -c "$(curl -fsLS https://get.chezmoi.io)" -- -b "$BIN"
  command -v mise >/dev/null || curl -fsSL https://mise.run | MISE_INSTALL_PATH="$BIN/mise" sh
  log "Terminal tools (mise, user-local)"
  mise use -g -y neovim fzf ripgrep fd zoxide starship lazygit tree-sitter eza bat delta
  log "Dotfiles (chezmoi)"
  chezmoi init --source "$REPO" --apply --promptDefaults
  rm -f "$HOME/.config/zsh/conf.d/00-omamac-offline.zsh"
fi

if [[ ${SHELL##*/} != zsh ]]; then
  if command -v zsh >/dev/null; then
    log "Login shell is ${SHELL##*/}. Switch with: chsh -s \"$(command -v zsh)\"  (or ask IT / set it in the Coder template)"
  else
    log "zsh not installed here — tmux + nvim are set up; the shell config needs zsh."
  fi
fi
log "Done on $(hostname -s)."
