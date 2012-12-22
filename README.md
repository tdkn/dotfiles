dotfiles
========

使い方
------
何はともあれ git を入れます。

    $ sudo yum install git  

プロジェクトをクローンします。

    $ git clone https://github.com/tdkn/dotfiles.git

シンボリックリンクを貼ります。

    $ ln -s ~/dotfiles/.zshrc ~/.zshrc

いろいろ入れておきます。

    $ sudo yum install zsh vim gvim

Vim
---
Vundle を導入しておきます。

    $ git clone https://github.com/gmarik/vundle.git ~/.vim/bundle/vundle

Vimの初回起動でアレがない・コレがないと言われるので、以下を実行。

    :BundleInstall!

いろいろ入って、快適なVimライフ。
