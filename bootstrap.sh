#!/usr/bin/env bash

DOTFILES_ROOT="`pwd`"

DOTFILES=`ls -A --ignore='[^.]*' --ignore='.git'`

TIME=`date +'~%Y-%m-%d-%H:%M:%S'`

BUNDLER="$HOME/.vim/bundle"

info () {
  printf "\n$1\n\n"
}

info 'Checking directory ...'

# Create directory `$HOME/.dotfiles' if not exist
if [ ! -d ~/.dotfiles ]; then
  echo "NG, directory '~/.dotfiles' not found"
  echo "Create symlink : ~/.dotfiles"
  echo -e "\t-> $DOTFILES_ROOT"
  ln -s . ~/.dotfiles
else
  echo "OK, directory '~/.dotfiles' found"
fi

info 'Symlinking dotfiles ...'

# Create symlinks
cd $HOME
for file in $DOTFILES
do
  echo "Create symlink : ~/$file"
  echo -e "\t-> ~/.dotfiles/$file"
  ln -sb --suffix=$TIME .dotfiles/$file ~/$file
done

info 'Installing Vim plugin manager ...'

# Setup Vim plugin manager
if [ ! -d $BUNDLER ]; then
  mkdir -p $BUNDLER
  git clone github:Shougo/neobundle.vim $BUNDLER/neobundle.vim
  source $BUNDLER/neobundle.vim/bin/neoinstall
else
  echo "Already installed."
fi

info 'Complete!'

unset DOTFILES_ROOT
unset DOTFILES
unset TIME
unset BUNDLER

