# Load order matters: autosuggestions, then syntax highlighting last.
_zp="$XDG_DATA_HOME/zsh/plugins"

if [[ -r $_zp/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
  ZSH_AUTOSUGGEST_STRATEGY=(history completion)
  ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=40
  source "$_zp/zsh-autosuggestions/zsh-autosuggestions.zsh"
  bindkey -M viins '^F' autosuggest-accept     # Ctrl-F accepts the suggestion
fi

[[ -r $_zp/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh ]] &&
  source "$_zp/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"

unset _zp
