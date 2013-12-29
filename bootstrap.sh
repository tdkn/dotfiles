#!/usr/bin/env bash

echo "home directory -> $HOME"
echo ""
echo "init dotfiles ..."
echo ""

rsync -av --no-perms \
      --exclude ".git/" \
      --exclude "README.md" \
      --exclude "bootstrap.sh" . $HOME

echo ""
echo "init vim ..."
echo ""

# VIM BUNDLE PATH
VBP="$HOME/.vim/bundle"

[ ! -d $VBP ] && mkdir -p $VBP && \
  git clone github:Shougo/neobundle.vim $VBP/neobundle.vim && \
  source $VBP/neobundle.vim/bin/neoinstall

echo ""
echo "complete!"
echo ""

