# yazi: quit with q and the shell follows into the last directory.
y() {
  local tmp="$(mktemp -t yazi-cwd.XXXXXX)" cwd
  yazi "$@" --cwd-file="$tmp"
  cwd="$(<"$tmp")"
  [[ -n $cwd && $cwd != $PWD ]] && builtin cd -- "$cwd"
  rm -f -- "$tmp"
}

# mkdir + cd
mcd() { mkdir -p -- "$1" && builtin cd -- "$1"; }

# --- Long-command notifications ----------------------------------------------
# Any command running ≥ OMACHY_NOTIFY_AFTER seconds sends a desktop notification
# (OSC 9, handled by Ghostty) + a bell. Works over SSH and through tmux, so a
# remote build that finishes while you're in Slack still taps you on the shoulder.
: ${OMACHY_NOTIFY_AFTER:=30}
zmodload zsh/datetime

_omachy_notify_preexec() { _omachy_cmd=$1; _omachy_start=$EPOCHREALTIME; }
_omachy_notify_precmd() {
  local rc=$? elapsed
  [[ -n $_omachy_start ]] || return
  elapsed=$(( EPOCHREALTIME - _omachy_start ))
  unset _omachy_start
  (( elapsed >= OMACHY_NOTIFY_AFTER )) || return
  case ${_omachy_cmd%% *} in nvim|vim|vi|ssh|tmux|lazygit|yazi|btop|less|man|y|t|ta) return ;; esac
  local mark=$([[ $rc == 0 ]] && print ✓ || print "✗ ($rc)")
  local msg="$mark ${_omachy_cmd[1,60]} — ${HOST%%.*} — $(printf '%.0f' $elapsed)s"
  if [[ -n $TMUX ]]; then
    printf '\ePtmux;\e\e]9;%s\a\e\\' "$msg"
  else
    printf '\e]9;%s\a' "$msg"
  fi
  printf '\a'
}
autoload -Uz add-zsh-hook
add-zsh-hook preexec _omachy_notify_preexec
precmd_functions=(_omachy_notify_precmd $precmd_functions)   # first, so $? is the command's
