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
echo "a) Add, push and commit dotfiles"
echo "b) Update current dotfiles"
echo "c) Edit this script"

read ANSWER_1

case $ANSWER_1 in

a)
  cd ~/.dotfiles
  git add --all
  git commit
  git push
  exec sh "$0" "$@"
  ;;

b)
  rm -rf ~/.dotfiles/config/*
  cp -r ~/.config/xmonad ~/.dotfiles/config/
  cp -r ~/.config/bspwm ~/.dotfiles/config/
  cp -r ~/.config/polybar ~/.dotfiles/config/
  cp -r ~/.config/alacritty ~/.dotfiles/config/
  cp -r ~/.config/flameshot ~/.dotfiles/config/
  cp -r ~/.config/picom.conf ~/.dotfiles/config/
  cp -r ~/.config/rofi ~/.dotfiles/config/
  cp -r ~/.config/polybar ~/.dotfiles/config/
  cp -r ~/.config/doom ~/.dotfiles/config/
  cp -r ~/.config/dunst ~/.dotfiles/config/
  cp -r ~/.config/nvim ~/.dotfiles/config/

  cp -r ~/.bashrc ~/.dotfiles/
  cp -r ~/LICENSE ~/.dotfiles/
  cp -r ~/.scripts ~/.dotfiles
  exec sh "$0" "$@"
  ;;

c) nvim ~/.scripts/dots.sh && clear && exec sh "$0" "$@" ;;

q) clear && echo Goodbye! ;;
*) echo Not one of the choices && sleep 2 && clear && exec sh "$0" "$@" ;;
esac
