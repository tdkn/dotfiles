if [ "$TERM" = "xterm" ]; then
  #TERM="xterm-256color"
  TERM="screen-256color"
fi

fpath=(/usr/local/share/zsh-completions $fpath)

autoload -U compinit
compinit

for file in ~/.{aliases,zsh_prompt}; do
  [ -r "$file" ] && [ -f "$file" ] && source "$file"
done
unset file

# command-history search settings
autoload history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end

setopt hist_ignore_dups
setopt share_history
setopt auto_cd
setopt auto_pushd
setopt correct
setopt list_packed
setopt nolistbeep
setopt ignoreeof

# key bind
bindkey -e
bindkey "^[[3~" delete-char
bindkey "^P" history-beginning-search-backward-end
bindkey "^N" history-beginning-search-forward-end

# rbenv
if which rbenv > /dev/null; then
  eval "$(rbenv init - zsh)"
fi
