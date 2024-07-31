#!/bin/sh
# __        __
# \ \      / /
#  \ \    / /
#   \ \  / /            UmbralGoat[Vox]
#    \ \/ / _   _ __ _  https://www.github.com/v_munu
#     \  / | |_| |\ V/  https://umbralgoat.net
#      \/  |  _,/  \/   Discord: v_munu
#          |_|
# A script to be placed in /etc/profile.d/ primarily to source the user's .bashrc file.

# Fix .bashrc
source ~/.bashrc

# Anything else
export __GL_SHADER_DISK_CACHE_PATH=$XDG_CACHE_HOME
