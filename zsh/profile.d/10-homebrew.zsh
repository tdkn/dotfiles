if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -d /opt/homebrew/bin ]; then
  export PATH="/opt/homebrew/bin:${PATH}"
fi
