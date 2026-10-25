# --- History -----------------------------------------------------------------
HISTFILE="$XDG_STATE_HOME/zsh/history"
[[ -d ${HISTFILE:h} ]] || mkdir -p "${HISTFILE:h}"
HISTSIZE=100000
SAVEHIST=100000
setopt extended_history hist_ignore_all_dups hist_ignore_space hist_reduce_blanks share_history inc_append_history

# --- General -----------------------------------------------------------------
setopt auto_cd auto_pushd pushd_ignore_dups pushd_silent
setopt interactive_comments no_beep extended_glob glob_dots
WORDCHARS=${WORDCHARS//[\/.-]}   # ^W stops at / . -

# --- Vi mode -----------------------------------------------------------------
bindkey -v
KEYTIMEOUT=1

# Keep the handy emacs keys in insert mode.
bindkey -M viins '^A' beginning-of-line '^E' end-of-line '^K' kill-line \
                 '^U' backward-kill-line '^W' backward-kill-word '^?' backward-delete-char \
                 '^H' backward-delete-char '^P' up-line-or-history '^N' down-line-or-history

# Edit the current command in nvim: Esc then v.
autoload -Uz edit-command-line && zle -N edit-command-line
bindkey -M vicmd 'v' edit-command-line

# Beam cursor in insert mode, block in normal mode.
_omachy_cursor() { [[ $KEYMAP == vicmd ]] && printf '\e[2 q' || printf '\e[6 q'; }
zle-keymap-select() { _omachy_cursor; }
zle-line-init() { _omachy_cursor; }
zle -N zle-keymap-select
zle -N zle-line-init
