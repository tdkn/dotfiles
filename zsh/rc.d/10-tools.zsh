if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
fi

if [ -d "${HOMEBREW_PREFIX:-/opt/homebrew}/opt/curl/bin" ]; then
  export PATH="${HOMEBREW_PREFIX:-/opt/homebrew}/opt/curl/bin:${PATH}"
fi

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

if command -v fzf >/dev/null 2>&1; then
  source <(fzf --zsh)
fi
