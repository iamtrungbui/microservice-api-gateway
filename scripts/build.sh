# !/bin/sh
#

set -euo pipefail
trap "echo 'error: Script failed: see failed command above'" ERR

use_red_green_echo() {
  prefix="$1"
  red() {
    echo "$(tput bold)$(tput setaf 1)[$prefix] $*$(tput sgr0)";
  }
  
  green() {
    echo "$(tput bold)$(tput setaf 2)[$prefix] $*$(tput sgr0)";
  }
  
  yellow() {
    echo "$(tput bold)$(tput setaf 3)[$prefix] $*$(tput sgr0)";
  }
}
use_red_green_echo 'Build'


ALL_LIBS_BUILT_MARK_FILE='./all-libs-built.log'

_on_mac(){
  if [[ $(uname -a) == *Darwin* ]]; then
    yellow "[ON MAC] $@"
    "$@"
  fi
}

_on_linux(){
  if [[ $(uname -a) == Linux* ]]; then
    yellow "[ON LINUX] $@"
    "$@"
  fi
}

_markAllLibsAreBuilt(){
  touch $ALL_LIBS_BUILT_MARK_FILE
}

###### build all the C libs

# $1: LIB_OPTION
build_lfs(){
  cd lua/libs/lfs
  make PREFIX=$LUA_HOME LIB_OPTION="$1" && make test && make install && make clean
}

# ...

main(){
  if [[ -f $ALL_LIBS_BUILT_MARK_FILE ]]; then
    yellow 'All libs are built, no need to build...'
    return
  fi
  
  yellow 'Start building C libs...'
  
  local current=$PWD
  _on_mac build_lfs "-bundle -undefined dynamic_lookup"
  _on_linux build_lfs "-shared"
  cd $current
  _markAllLibsAreBuilt
}

main