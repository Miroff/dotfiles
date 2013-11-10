#!/bin/bash

MY_PATH="`dirname \"$0\"`"              # relative
MY_PATH="`( cd \"$MY_PATH\" && pwd )`"  # absolutized and normalized
if [ -z "$MY_PATH" ] ; then
  # error; for some reason, the path is not accessible
  # to the script (e.g. permissions re-evaled after suid)
  exit 1  # fail
fi

dotfiles=(".bash_aliases" ".bash_profile" ".bashrc" ".gitconfig" ".screenrc")

for file in "${dotfiles[@]}"
do
  if [ -f $HOME/$file ]; then
    rm $HOME/$file
  fi

  ln -s $MY_PATH/$file $HOME/$file
done

