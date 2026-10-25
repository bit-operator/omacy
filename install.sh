#!/usr/bin/env bash
# omacy bootstrap — idempotent, safe to re-run.
#   ./install.sh                     macOS: packages, dotfiles, services, macOS defaults
#   ./install.sh --minimal           Linux server / Coder workspace (online): terminal stack only
#   ./install.sh --minimal --offline Linux without internet: uses the bundle shipped by `dot-push`
# Identity for git on remotes: OMACY_NAME / OMACY_EMAIL env vars (dot-push passes them).
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
# Coder runs this on every workspace start (dotfiles URL). $HOME persists, the rest of the system resets,
# so everything lives under ~/.local and only missing pieces are downloaded. OMACY_UPDATE=1 refreshes tools.
source "$REPO/scripts/linux-tools.sh"

if ((OFFLINE)); then
  BUNDLE="$HOME/.local/share/omacy-bundle"
  [[ -d $BUNDLE/bin ]] || { echo "No bundle at $BUNDLE — run 'dot-push <host>' from the Mac." >&2; exit 1; }
  log "Offline: installing bundled tools"
  mkdir -p "$HOME/.local/opt"
  cp -Rf "$BUNDLE"/opt/. "$HOME/.local/opt/"
  cp -Pf "$BUNDLE"/bin/* "$BIN"/
  for d in nvim/lazy zsh/plugins tmux/plugins; do
    mkdir -p "$HOME/.local/share/${d%/*}"
    rm -rf "$HOME/.local/share/$d" && cp -R "$BUNDLE/share/$d" "$HOME/.local/share/$d"
  done
  log "Dotfiles (chezmoi, externals from bundle)"
  chezmoi init --source "$REPO" --apply --force --promptDefaults --exclude externals   # --force: no TTY at Coder start; repo wins
  mkdir -p "$HOME/.config/zsh/conf.d"
  printf 'export OMACY_OFFLINE=1   # written by install.sh --offline: no Mason / plugin downloads\n' \
    >"$HOME/.config/zsh/conf.d/00-omacy-offline.zsh"
else
  log "Tools → ~/.local (only what's missing)"
  omacy_linux_tools "$HOME/.local"
  log "Dotfiles (chezmoi)"
  chezmoi init --source "$REPO" --apply --force --promptDefaults   # --force: no TTY at Coder start; repo wins
  rm -f "$HOME/.config/zsh/conf.d/00-omacy-offline.zsh"
fi

# The login shell is reset with the system on Coder, so interactive bash hands over to zsh instead.
# The block is rewritten on every run, so fixes here reach existing machines.
log "~/.bashrc: interactive terminals switch to zsh"
touch "$HOME/.bashrc"
sed -i.omacy-bak '/^# >>> omacy >>>/,/^# <<< omacy <<</d' "$HOME/.bashrc" && rm -f "$HOME/.bashrc.omacy-bak"
cat >>"$HOME/.bashrc" <<'BASHRC'
# >>> omacy >>> (managed by omacy install.sh; set OMACY_NO_ZSH=1 to stay in bash)
# Only real terminal sessions: never `bash -c` / `bash -ic "cmd"` (IDEs, agents, scripts keep bash).
if [[ $- == *i* && -t 0 && -z ${BASH_EXECUTION_STRING:-} && -z ${ZSH_VERSION:-} && -z ${OMACY_NO_ZSH:-} ]]; then
  _omacy_zsh=$(command -v zsh 2>/dev/null || echo "$HOME/.local/bin/zsh")
  [[ -x $_omacy_zsh ]] && SHELL=$_omacy_zsh exec "$_omacy_zsh" -l
  unset _omacy_zsh
fi
# <<< omacy <<<
BASHRC
log "Done on $(hostname -s)."
