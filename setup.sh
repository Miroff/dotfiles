#!/bin/bash

MY_PATH="`dirname \"$0\"`"              # relative
MY_PATH="`( cd \"$MY_PATH\" && pwd )`"  # absolutized and normalized
if [ -z "$MY_PATH" ] ; then
  # error; for some reason, the path is not accessible
  # to the script (e.g. permissions re-evaled after suid)
  exit 1  # fail
fi

if [ -f $HOME/.bash_aliases ]; then
  rm $HOME/.bash_aliases
fi

ln -s $MY_PATH/.bash_aliases $HOME/.bash_aliases
