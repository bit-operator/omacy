fpath=("$XDG_CONFIG_HOME/zsh/completions" $fpath)
[[ -d /opt/homebrew/share/zsh/site-functions ]] && fpath=(/opt/homebrew/share/zsh/site-functions $fpath)

# Rebuild the completion dump at most once a day.
autoload -Uz compinit
_zcomp="$XDG_CACHE_HOME/zsh/zcompdump"
[[ -d ${_zcomp:h} ]] || mkdir -p "${_zcomp:h}"
if [[ -n $_zcomp(#qN.mh+24) || ! -f $_zcomp ]]; then compinit -d "$_zcomp"; else compinit -C -d "$_zcomp"; fi
unset _zcomp

zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' menu no                       # fzf-tab draws the menu
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/zcompcache"

# fzf-tab (must load after compinit, before autosuggestions/highlighting).
_ftab="$XDG_DATA_HOME/zsh/plugins/fzf-tab/fzf-tab.plugin.zsh"
if [[ -r $_ftab ]] && (( $+commands[fzf] )); then
  source "$_ftab"
  zstyle ':fzf-tab:*' use-fzf-default-opts yes
  zstyle ':fzf-tab:*' switch-group '<' '>'
  zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always --icons $realpath 2>/dev/null || ls $realpath'
  zstyle ':fzf-tab:complete:(nvim|bat|cat):*' fzf-preview 'bat --color=always --style=numbers --line-range=:200 $realpath 2>/dev/null'
  (( $+TMUX )) && zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup
fi
unset _ftab
