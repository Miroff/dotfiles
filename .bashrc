# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

###############################################################################
#
# Setup path
#
###############################################################################

# add local bin path
PATH=$HOME/.bin:$PATH

[[ -f $HOME/.bin/toolsenv ]] && source $HOME/.bin/toolsenv

###############################################################################
#
# Setup history
#
###############################################################################
# don't put duplicate lines in the history
export HISTCONTROL=$HISTCONTROL${HISTCONTROL+:}ignoreboth:erasedups

# set history length
export HISTFILESIZE=1000000000
export HISTSIZE=1000000

# append to the history file, don't overwrite it
shopt -s histappend
# save all lines of a multiple-line command in the same history entry (allows 
# easy re-editing of multi-line commands)
shopt -s cmdhist

# ignore non-informative commands
export HISTIGNORE="&:ls:bg:fg:exit"

PROMPT_COMMAND='history -a; history -n'

###############################################################################
#
# Other useful options
#
###############################################################################

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# correct minor errors in the spelling of a directory component in a cd command
shopt -s cdspell

###############################################################################
#
# Setup command line prompt
#
###############################################################################

# setup color variables
color_is_on=
color_red=
color_green=
color_yellow=
color_blue=
color_white=
color_gray=
color_bg_red=
color_off=
color_user=
if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
  color_is_on=true
  color_black="\[$(/usr/bin/tput setaf 0)\]"
  color_red="\[$(/usr/bin/tput setaf 1)\]"
  color_green="\[$(/usr/bin/tput setaf 2)\]"
  color_yellow="\[$(/usr/bin/tput setaf 3)\]"
  color_blue="\[$(/usr/bin/tput setaf 6)\]"
  color_white="\[$(/usr/bin/tput setaf 7)\]"
  color_gray="\[$(/usr/bin/tput setaf 8)\]"
  color_off="\[$(/usr/bin/tput sgr0)\]"

  color_error="$(/usr/bin/tput setab 1)$(/usr/bin/tput setaf 7)"
  color_error_off="$(/usr/bin/tput sgr0)"

  # set user color to red if root
  case `id -u` in
    0) color_user=$color_red ;;
    *) color_user=$color_green ;;
  esac
fi

# some kind of optimization - check if git installed only on config load
PS1_GIT_BIN=$(which git 2>/dev/null)

# Setup hostname
if [ -f ~/.hostname ]; then
  LOCAL_HOSTNAME=`cat ~/.hostname`
else
  LOCAL_HOSTNAME=$HOSTNAME
fi

function prompt_command {
  local PS1_GIT=
  local PS1_VENV=
  local GIT_BRANCH=
  local GIT_DIRTY=
  local PS1_SSH=

  local PWDNAME=$PWD

  # beautify working directory name
  if [[ "${HOME}" == "${PWD}" ]]; then
     PWDNAME="~"
  elif [[ "${HOME}" == "${PWD:0:${#HOME}}" ]]; then
     PWDNAME="~${PWD:${#HOME}}"
  fi
 
  # check is current session an SSH
  #if [ `echo $SSH_CLIENT | wc -c` -gt 1 ]; then 
  if [[ $(who am i) =~ \([-a-zA-Z0-9\.]+\)$ ]] ; then 
    PS1_SSH="${color_red}[SSH]${color_off} " 
  fi

  # parse git status and get git variables
  if [[ ! -z $PS1_GIT_BIN ]]; then
    # check we are in git repo
    local CUR_DIR=$PWD
                
    while [[ ! -d "${CUR_DIR}/.git" ]] && [[ ! "${CUR_DIR}" == "/" ]] && [[ ! "${CUR_DIR}" == "~" ]] && [[ ! "${CUR_DIR}" == "" ]]; do CUR_DIR=${CUR_DIR%/*}; done
      
    if [[ -d "${CUR_DIR}/.git" ]]; then
      # 'git repo for dotfiles' fix: show git status only in home dir and other git repos
      if [[ "${CUR_DIR}" != "${HOME}" ]] || [[ "${PWD}" == "${HOME}" ]]; then
        # get git branch
        GIT_BRANCH=$($PS1_GIT_BIN symbolic-ref HEAD 2>/dev/null)
        if [[ ! -z $GIT_BRANCH ]]; then
          GIT_BRANCH=${GIT_BRANCH#refs/heads/}

          # get git status
          local GIT_STATUS=$($PS1_GIT_BIN status --porcelain 2>/dev/null)
          [[ -n $GIT_STATUS ]] && GIT_DIRTY=1
        fi
      fi
    fi
  fi

  # build b/w prompt for git and virtual env
  [[ ! -z $GIT_BRANCH ]] && PS1_GIT=" (git: ${GIT_BRANCH})"
  [[ ! -z $VIRTUAL_ENV ]] && PS1_VENV=" (venv: ${VIRTUAL_ENV#$WORKON_HOME})"

  if $color_is_on; then
    # build git status for prompt
    if [[ ! -z $GIT_BRANCH ]]; then
      if [[ -z $GIT_DIRTY ]]; then
        PS1_GIT=" (git: ${color_green}${GIT_BRANCH}${color_off})"
      else
        PS1_GIT=" (git: ${color_red}${GIT_BRANCH}${color_off})"
      fi
    fi

    # build python venv status for prompt
    [[ ! -z $VIRTUAL_ENV ]] && PS1_VENV=" (venv: ${color_blue}${VIRTUAL_ENV#$WORKON_HOME}${color_off})"
  fi

  # set new color prompt
  PS1="${PS1_SSH}${color_user}${USER}${color_off}@${color_yellow}${LOCAL_HOSTNAME}${color_off}:${color_grey}${PWDNAME}${color_off}${PS1_GIT}${PS1_VENV} $ "

  # get cursor position and add new line if we're not in first column
  #echo -en "\033[6n" && read -sdR CURPOS
  #[[ ${CURPOS##*;} -gt 1 ]] && echo "${color_error}↵${color_error_off}"
  #Commented out since this code mess up with prompt

  # set title
  echo -ne "\033]0;${USER}@${LOCAL_HOSTNAME}:${PWDNAME}"; echo -ne "\007"
}

# set prompt command (title update and color prompt)
PROMPT_COMMAND="history -a; history -n; prompt_command"

# set new b/w prompt (will be overwritten in 'prompt_command' later for color prompt)
PS1='\u@${LOCAL_HOSTNAME}:\w\$ '

###############################################################################
#
# Setup options for 3-rd party tools
#
###############################################################################

# grep colorize
export GREP_OPTIONS="--color=auto"

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

###############################################################################
#
# Load other dotfiles
#
###############################################################################

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
  . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ]; then
  . /etc/bash_completion
fi


