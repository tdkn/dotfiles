# rbenv
if [ -d ${HOME}/.rbenv ]; then
  export PATH="$HOME/.rbenv/bin:$PATH"
  eval "$(rbenv init -)"
  source $HOME/.rbenv/completions/rbenv.zsh
fi
