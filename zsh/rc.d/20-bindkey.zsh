# Keep ZLE in emacs mode even when EDITOR/VISUAL point to vi-like editors.
bindkey -e

bindkey '^W' backward-kill-word
bindkey '^[^H' backward-kill-word
bindkey '^[^?' backward-kill-word
