alias v=nvim vi=nvim vim=nvim
alias g=git lg=lazygit
alias ..='cd ..' ...='cd ../..'
alias reload='exec zsh'
alias path='print -l $path'

if (( $+commands[eza] )); then
  alias ls='eza --group-directories-first --icons=auto'
  alias ll='eza -l --git --group-directories-first --icons=auto --time-style=relative'
  alias la='ll -a'
  alias lt='eza --tree --level=2 --icons=auto --git-ignore'
fi
(( $+commands[bat] )) && alias cat='bat --paging=never --style=plain'

# tmux / sesh
alias t=sesh-pick
alias ta='tmux new-session -A -s main'

# dotfiles
alias dots='cd "$(chezmoi source-path)/.."'
alias dotup='chezmoi update --apply'
