# Created by newuser for 4.3.10

autoload -U compinit
compinit

export PATH="$HOME/local/bin:$PATH"
export LANG=ja_JP.UTF-8
export EDITOR=/usr/bin/vim

case ${UID} in
  0)
  PROMPT="%{[32m%}%n%%%{[m%} "
  RPROMPT="[%~]"
  PROMPT2="%B%{[32m%}%_#%{[m%}%b "
  SPROMPT="%B%{[32m%}%r is correct? [n,y,a,e]:%{[m%}%b "
  [ -n "${REMOTEHOST}${SSH_CONNECTION}" ] && 
  PROMPT="%{[37m%}${HOST%%.*} ${PROMPT}"
  ;;
  *)
  PROMPT="%{[32m%}%n%%%{[m%} "
  RPROMPT="[%~]"
  PROMPT2="%{[32m%}%_%%%{[m%} "
  SPROMPT="%{[32m%}%r is correct? [n,y,a,e]:%{[m%} "
  [ -n "${REMOTEHOST}${SSH_CONNECTION}" ] && 
  PROMPT="%{[37m%}${HOST%%.*} ${PROMPT}"
  ;;
esac

alias ls='ls --color=auto'
alias la='ls -a'
alias ll='ls -al'
alias rm='rm -i'

# command-history settings
HISTFILE=~/.zsh_history
HISTSIZE=6000000
SAVEHIST=6000000
setopt hist_ignore_dups
setopt share_history

# command-history search settings
autoload history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end

setopt auto_cd
setopt auto_pushd
setopt correct
setopt list_packed
setopt nolistbeep

# key bind
bindkey -e
bindkey "^[[3~" delete-char
bindkey "^P" history-beginning-search-backward-end
bindkey "^N" history-beginning-search-forward-end
