dotfiles_root="${HOME}/.dotfiles"

for zprofile_file in "${dotfiles_root}"/zsh/profile.d/*.zsh(N); do
  source "$zprofile_file"
done
