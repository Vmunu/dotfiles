# __        __
# \ \      / /
#  \ \    / /
#   \ \  / /            UmbralGoat[Vox]
#    \ \/ / _   _ __ _  https://www.github.com/v_munu
#     \  / | |_| |\ V/  https://umbralgoat.net
#      \/  |  _,/  \/   Discord: v_munu
#          |_|
# My .bashrc configuration, feel free to harvest some aliases.

### TTY AUTOLOGIN TO XORG ###
if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then
  startx
fi

### IGNORE CASE ###
bind "set completion-ignore-case on"

### List dir every cd & clear ###
function cd {
  builtin cd "$@"
  RET=$?
  clear && eza -lh --color=always --group-directories-first
  return $RET
}
alias clear='clear && eza -lh --color=always --group-directories-first'

### ARCHIVE EXTRACTION ###
ex() {
  if [ -f "$1" ]; then
    case $1 in
    *.tar.bz2) tar xjf $1 ;;
    *.tar.gz) tar xzf $1 ;;
    *.bz2) bunzip2 $1 ;;
    *.rar) unrar x $1 ;;
    *.gz) gunzip $1 ;;
    *.tar) tar xf $1 ;;
    *.tbz2) tar xjf $1 ;;
    *.tgz) tar xzf $1 ;;
    *.zip) unzip $1 ;;
    *.Z) uncompress $1 ;;
    *.7z) 7z x $1 ;;
    *.deb) ar x $1 ;;
    *.tar.xz) tar xf $1 ;;
    *.tar.zst) unzstd $1 ;;
    *) echo "'$1' cannot be extracted via ex()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

### STARTUP ###
#neofetch
pfetch
eza -lh --color=always --group-directories-first

## Prompt ##
export PS1='\[\e[0;32m\u@\h [\e[0m \w \e[0;32m] $\e[0m\] '

## Exports ##
export VISUAL=nvim
export EDITOR=nvim
export LFS=/mnt/scratch
export LFS_TGT=x86_64-lfs-linux-gnu
export JAVA_HOME=/opt/jdk-18.0.1.1/
export PAT=~/documents/pat
export QT_QPA_PLATFORMTHEME=qt5ct
export JUPYTERLAB_DIR=$HOME/.local/share/jupyter/lab

# PATH #
export PATH="$HOME/.config/emacs/bin/":$PATH
export PATH="$HOME/.local/bin/":$PATH
export PATH="/usr/lib64/qt5/bin/":$PATH
export PATH="$JAVA_HOME/bin":$PATH
export PATH="$HOME/.cabal/bin":$PATH
export PATH="$HOME/.local/bin":$PATH
export PATH="$HOME/.local/share/gem/ruby/3.0.0/bin":$PATH

### ADMINISTRATION ###
export SUPERUSER=sudo
#export SUPERUSER=doas

### ALIASES ###
## Superuser ##
alias root="$SUPERUSER su"

## Shortcuts ##
alias x="startx"
alias q="exit"
alias c="clear"
alias to="cd"
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias h="cd $HOME"
alias mkdir="mkdir -pv"
alias lsb="lsblk"
alias bid="$SUPERUSER blkid"
alias nfet="neofetch"
alias ptex="pdflatex"
alias iso="tree /media/hdd/ISOs/"
alias init-rebuild="$SUPERUSER mkinitcpio -p linux && $SUPERUSER grub-mkconfig -o /boot/grub/grub.cfg"

## Jupyter ##
alias jup="cd $HOME/jupyter && jupyter lab"

## Git ##
alias dots="./.scripts/dots.sh"
alias pat="cat $PAT ; echo"

## Vencord ##
alias vencord="sh -c "$(curl -sS https://raw.githubusercontent.com/Vendicated/VencordInstaller/main/install.sh)""

## List ##
alias ls='eza -ahl --color=always --group-directories-first' # All files and dirs
alias la='eza -ahl --color=always --group-directories-first' # All files and dirs
alias ll='eza -lh --color=always --group-directories-first'  # Long format
alias lt='eza -aT --color=always --group-directories-first'  # Tree listing
alias l.='eza -a | egrep "^\."'                              # Lists dotfiles

## Youtube Downloading ##
alias yta-aac="youtube-dl --extract-audio --audio-format aac"
alias yta-best="youtube-dl --extract-audio --audio-format best"
alias yta-flac="youtube-dl --extract-audio --audio-format flac"
alias yta-m4a="youtube-dl --extract-audio --audio-format m4a"
alias yta-mp3="yt-dlp --extract-audio --audio-format mp3"
alias ytv="yt-dlp -f bestvideo+bestaudio"

## Vim and Emacs ##
alias v="vim"
alias nv="nvim"
alias sv="$SUPERUSER vim"
alias snv="$SUPERUSER nvim"
alias em="emacs"
alias sem="$SUPERUSER emacs"

## Safety-net ##
alias mv="mv -iv"
alias rm="rm -iv"
alias cp="cp -iv"

## Colorize Grep Output ##
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

## User Configs ##
alias snips="$EDITOR ~/.config/nvim/UltiSnips/all.snippets"
alias brc="$EDITOR ~/.bashrc"
alias xrc="$EDITOR ~/.xinitrc"
alias xmc="$EDITOR ~/.config/xmonad/xmonad.hs"
alias xbc="$EDITOR ~/.config/xmobar/xmobarrc.hs"
#alias dwme="$SUPERUSER $EDITOR /etc/portage/savedconfig/x11-wm/dwm-6.2.h"
#alias dwmb="$SUPERUSER emerge dwm"
#alias hlc="$EDITOR ~/.config/herbstluftwm/autostart"
#alias bsc="$EDITOR ~/.config/bspwm/bspwmrc"
#alias sxc="$EDITOR ~/.config/sxhkd/sxhkdrc"
alias pbc="$EDITOR ~/.config/polybar/config"
#alias pbl="$EDITOR ~/.config/polybar/launch.sh"
alias alac="$EDITOR ~/.config/alacritty/alacritty.yml"

## Rick Roll ##
alias rr='curl -s -L https://raw.githubusercontent.com/keroserene/rickrollrc/master/roll.sh | bash'

## Pacman ##
alias pmi="sudo pacman -S"
alias pmr="sudo pacman -Rscn"
alias pms="sudo pacman -Ss"
alias pmS="sudo pacman -Syyy"
alias pmU="sudo pacman -Syuu"
alias pri="paru -S"
alias prr="paru -Rscn"
alias prs="paru -Ss"
alias pU="paru -Syuu"

## Portage ##
#alias emi="time $SUPERUSER emerge -v"                                   # Emerge
#alias emr="$SUPERUSER emerge -c"                                        # Depclean
#alias emd="$SUPERUSER emerge --deselect"                                # Deselect from @world
#alias emS="time $SUPERUSER emerge --sync"                               # Sync
#alias ems="$SUPERUSER emerge -s"                                        # Search
#alias emu="$SUPERUSER emerge --sync && time $SUPERUSER emerge --update"  # Update single package
#alias emU="$SUPERUSER emerge --sync && time $SUPERUSER emerge -uvDN @world"   # Update @world
#alias emmod="$SUPERUSER emerge @module-rebuild"                         # Rebuild modules
#alias emt="$SUPERUSER qlop -H"                                          # Show time that a package took to compile
#alias pkg="qlist -I | wc -l"                                            # Package count
#alias news="$SUPERUSER eselect news read"                               # Show news

# Repos/Overlays #
#alias repen="$SUPERUSER eselect repository enable"    # Enable repository
#alias repds="$SUPERUSER eselect repository disable"   # Disable repository
#alias reprm="$SUPERUSER eselect repository remove"    # Remove repository

## Kernel ##
#alias kered="cd /usr/src/linux && $SUPERUSER make menuconfig"
#alias kerbuild="cd /usr/src/linux && time $SUPERUSER make -j14 && $SUPERUSER make modules_install && $SUPERUSER make install"
#alias gmk="$SUPERUSER grub-mkconfig -o /boot/grub/grub.cfg"

## Gentoo Services ##
#alias ruadd="$SUPERUSER rc-update add"
#alias rudel="$SUPERUSER rc-update del"

## Gentoo System Files ##
#alias mkc="$SUPERUSER $EDITOR /etc/portage/make.conf"
#alias fst="$SUPERUSER $EDITOR /etc/fstab"

## XBPS ##
#alias xbi="$SUPERUSER xbps-install -S"
#alias xbU="$SUPERUSER xbps-install -Su"
#alias xbr="$SUPERUSER xbps-remove"
#alias xbR="$SUPERUSER xbps-remove -R"
#alias xbq="$SUPERUSER xbps-query"
#alias xbqR="$SUPERUSER xbps-query -R"

## Apt ##
#alias api="$SUPERUSER apt install"
#alias apr="$SUPERUSER apt remove"
#alias apar="$SUPERUSER apt autoremove"
#alias apU="$SUPERUSER apt update && $SUPERUSER apt upgrade"

## Power Shortcuts ##
alias log="kill -9 -1"
alias reboot="$SUPERUSER reboot"
alias poweroff="$SUPERUSER poweroff"
