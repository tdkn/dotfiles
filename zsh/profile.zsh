if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

if [ -r "${HOME}/.orbstack/shell/init.zsh" ]; then
  source "${HOME}/.orbstack/shell/init.zsh"
fi
