dotfiles
========

Useage
------
Install dependencies.

```bash
sudo aptitude install git vim
```

Clone the repository.

```bash
cd
mkdir Projects && cd Projects
git clone https://github.com/tdkn/dotfiles.git
```

Make as a symlink.

```bash
cd
ln -s ~/Projects/dotfiles ~/.dotfiles
```

Execute bootstrap.sh to setup.

```bash
cd .dotfiles
source bootstrap.sh
```
