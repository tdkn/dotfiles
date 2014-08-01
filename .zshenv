typeset -U PATH

if which brew > /dev/null; then
  PATH="$(brew --prefix coreutils)/libexec/gnubin:$PATH"
fi
PATH="/usr/local/bin:$PATH"
PATH="$HOME/bin:$PATH"
PATH="$HOME/.rbenv/bin:$PATH"
PATH="$HOME/.rbenv/shims:$PATH"
PATH="/usr/local/heroku/bin:$PATH"
PATH="$HOME/Projects/scripts:$PATH"
export PATH

export LANG=ja_JP.UTF-8
export EDITOR="vim"
export LESS='-R'

# command-history settings
export HISTFILE=~/.zsh_history
export HISTSIZE=6000000
export SAVEHIST=6000000

