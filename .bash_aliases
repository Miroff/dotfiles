#!/bin/bash

# Colorize standard commands
if [ -x /usr/bin/dircolors ]; then
    eval "`dircolors -b`"
    alias ls='ls --color=auto'

    alias diff='grc diff'
    alias gcc='grc gcc'
    alias netstat='grc netstat'
    alias wdiff='grc wdiff'
    alias ping='grc ping'
fi

# tree aliaces
alias tree='tree --dirsfirst'

# git aliaces
alias gtree='git log --graph --full-history --all --color --pretty=format:"%x1b[33m%h%x09%x09%x1b[32m%d%x1b[0m %x1b[34m%an%x1b[0m   %s" "$@"'

# mkdir
md() { mkdir -p "$@" && cd "$@"; }

# exit
alias q='exit'
alias :q='exit'
alias wq='exit'
alias :wq='exit'
alias sudo='sudo -E'

#print horizontal line with current time
div() {
  local time=`date`
  local columns=$(($(tput cols) - ${#time} - 6))
  local line=$(printf '%0.1s' "-"{1..500})
  printf "\e[01;31m---- ${time} ${line:0:${columns}}\e[0m\n"
}
