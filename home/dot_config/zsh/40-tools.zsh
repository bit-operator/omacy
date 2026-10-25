# Every tool is optional: remotes may only have a subset installed.

# fzf — colors use ANSI names so they follow the terminal theme (local and over SSH).
if (( $+commands[fzf] )); then
  export FZF_DEFAULT_OPTS="--height=40% --layout=reverse --border=rounded --info=inline-right \
--prompt='❯ ' --pointer='▌' --marker='┃' --separator='─' --scrollbar='│' \
--color=fg:-1,bg:-1,hl:blue,fg+:bright-white,bg+:black,hl+:bright-blue,info:magenta \
--color=prompt:cyan,pointer:magenta,marker:green,spinner:magenta,header:bright-black,border:bright-black,gutter:-1 \
--bind=ctrl-d:half-page-down,ctrl-u:half-page-up,ctrl-/:toggle-preview"
  if (( $+commands[fd] )); then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND=$FZF_DEFAULT_COMMAND
    export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
  fi
  export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:300 {} 2>/dev/null'"
  export FZF_ALT_C_OPTS="--preview 'eza --tree --level=2 --color=always --icons {} 2>/dev/null'"
  fzf --zsh &>/dev/null && source <(fzf --zsh)    # needs fzf ≥ 0.48 (old distro fzf: skip)
fi

# Atuin — local fuzzy history on Ctrl-R. Sync is disabled in its config; never `atuin login`.
(( $+commands[atuin] )) && eval "$(atuin init zsh --disable-up-arrow)"

(( $+commands[zoxide] )) && eval "$(zoxide init zsh --cmd cd)"
(( $+commands[direnv] )) && eval "$(direnv hook zsh)"
(( $+commands[mise] ))   && eval "$(mise activate zsh)"
(( $+commands[starship] )) && eval "$(starship init zsh)"

export BAT_THEME=ansi           # follow terminal palette
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
(( $+commands[bat] )) || unset MANPAGER
