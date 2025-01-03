#!/usr/bin/env sh

clear
echo "░▒▓███████▓▒░ ░▒▓██████▓▒░▒▓████████▓▒░▒▓████████▓▒░▒▓█▓▒░▒▓█▓▒░      ░▒▓████████▓▒░░▒▓███████▓▒░ "
echo "░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ ░▒▓█▓▒░   ░▒▓█▓▒░      ░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░      ░▒▓█▓▒░        "
echo "░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ ░▒▓█▓▒░   ░▒▓█▓▒░      ░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░      ░▒▓█▓▒░        "
echo "░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ ░▒▓█▓▒░   ░▒▓██████▓▒░ ░▒▓█▓▒░▒▓█▓▒░      ░▒▓██████▓▒░  ░▒▓██████▓▒░  "
echo "░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ ░▒▓█▓▒░   ░▒▓█▓▒░      ░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░             ░▒▓█▓▒░ "
echo "░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ ░▒▓█▓▒░   ░▒▓█▓▒░      ░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░             ░▒▓█▓▒░ "
echo "░▒▓███████▓▒░ ░▒▓██████▓▒░  ░▒▓█▓▒░   ░▒▓█▓▒░      ░▒▓█▓▒░▒▓████████▓▒░▒▓████████▓▒░▒▓███████▓▒░  "
echo "A simple script based on GitHub user thecaprisun's dotfile script."
echo
echo Welcome $USER.
echo "1) Add, push and commit dotfiles"
echo "2) Update current dotfiles"
echo "3) Edit this script"
echo "q) Quit"

read ANSWER
case $ANSWER in

1)
  cd ~/.dotfiles
  git add --all
  git commit
  git push
  exec sh "$0" "$@"
  ;;

2)
  # Wipe directories clean
  rm -rf ~/.dotfiles/config/*
  rm -rf ~/.dotfiles/scripts/*
  rm -rf ~/.dotfiles/sys/*
  rm -rf ~/.dotfiles/templates/*

  # Config files
  cp ~/.config/user-dirs.dirs ~/.dotfiles/config/
  cp ~/.config/README.org ~/.dotfiles/config/
  cp -r ~/.config/xmonad ~/.dotfiles/config/
  cp -r ~/.config/bspwm ~/.dotfiles/config/
  cp -r ~/.config/polybar ~/.dotfiles/config/
  cp -r ~/.config/kitty ~/.dotfiles/config/
  cp -r ~/.config/flameshot ~/.dotfiles/config/
  cp -r ~/.config/rofi ~/.dotfiles/config/
  cp -r ~/.config/picom ~/.dotfiles/config/
  cp -r ~/.config/doom ~/.dotfiles/config/
  cp -r ~/.config/dunst ~/.dotfiles/config/
  cp -r ~/.config/zathura ~/.dotfiles/config/
  cp -r ~/.config/nvim ~/.dotfiles/config/

  # Scripts
  cp -r ~/.scripts/* ~/.dotfiles/scripts/

  # System files
  cp -r ~/.sys/* ~/.dotfiles/sys/

  # Extra files
  cp -r ~/LICENSE ~/.dotfiles/LICENSE
  cp -r ~/.bashrc ~/.dotfiles/bashrc

  # Templates
  cp -r ~/templates/* ~/.dotfiles/templates/
  exec sh "$0" "$@"
  ;;

3) nvim ~/.scripts/dots.sh && clear && exec sh "$0" "$@" ;;

q) clear && echo Goodbye! ;;

*) echo Not one of the choices && sleep 2 && clear && exec sh "$0" "$@" ;;
esac
