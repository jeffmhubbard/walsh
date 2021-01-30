#!/usr/bin/env zsh

# walsh - Wallpaper Shuffler
# Jeff M. Hubbard 2019-2021

# script name
SH_NAME=${ZSH_ARGZERO:t:r}

# paths
CONF_DIR="$XDG_CONFIG_HOME/$SH_NAME"
CACHE_DIR="$XDG_CACHE_HOME/$SH_NAME"
WALL_DIR="$HOME/Wallpapers"
RC_PATH="$CONF_DIR/${SH_NAME}.rc"

# defaults
INTERVAL=10     # interval in minutes
MODE="fill"     # background mode
SPAN=false      # span multiple displays

# create directories
[[ -d $CACHE_DIR ]] || mkdir -p $CACHE_DIR 2>/dev/null
[[ -d $WALL_DIR ]]  || WALL_DIR=/usr/share/backgrounds

function main() {
  # set background mode
  case $MODE in
    center) mode="--bg-center";;
    fill)   mode="--bg-fill";;
    max)    mode="--bg-max";;
    scale)  mode="--bg-scale";;
    tile)   mode="--bg-tile";;
  esac

  # make image span multiple displays
  declare spanning
  if $SPAN
  then
    spanning="--no-xinerama"
  fi

  # begin loop
  while true
  do
    if set_wallpaper
    then
      if [ $INTERVAL -gt 0 ]
      then
        # wait for interval
        sleep $((INTERVAL*60))
      else
        # no interval
        break
      fi
    else
      # set_wallpaper failed
      exit 1
    fi
  done
}

# set wallpaper
function set_wallpaper() {
  # create temp file
  local list
  list=$(mktemp $CACHE_DIR/$SH_NAME.XXXXXX)

  # write image list
  get_image_list $WALL_DIR $list

  # call feh, trap errors
  local output
  output=$(feh -zq $mode $spanning -f $list 2>&1)

  # clean up temp file
  [[ -f $list ]] && rm $list

  # stop script if feh errors
  if [ ! $output = "" ]
  then
    echo "${output[@]}"
    return 1
  fi
}

# write list of supported images to temp file
function get_image_list() {
  local dir=$1      # path to search
  local list=$2     # file to write

  # search for supported files
  find $dir -regextype posix-extended -regex '.*\.(jpg|jpeg|png)' >! $list

  if [ $(wc -l < $list) -lt 1 ]
  then
    echo "ERROR: '$dir' does not contain any supported images! (JPG, PNG)"
    exit 1
  fi
}

function usage() {
  echo "Usage: $SH_NAME [-d <PATH>] [-m <MODE>] [-t <MIN>] [-s]"
  echo
  echo "optional:"
  echo "  -C, --config      path to config file"
  echo "  -d, --dir         wallpaper directory"
  echo "  -m, --mode        background mode: center fill max scale tile"
  echo "  -t, --time        time to shuffle in minutes"
  echo "  -s, --span        span image across multiple displays"
  echo "  -h, --help        show this help message and exit"
  echo
  exit 0
}

# prevent multiple instances from running
function () {
  pid=$$
  pidfile=$CACHE_DIR/$SH_NAME.pid
  if [ -f $pidfile ]
  then
    oldpid=$(head -n 1 $pidfile)
    if [[ ! $pid == $oldpid ]]
    then
      kill -9 $oldpid 2>/dev/null
    fi
  fi
  echo $pid >! $pidfile
}

# parse arguments
for arg in $@
do
  case $arg in
    -C | --config)
      RC_PATH=$2
      shift 2;;
    -d | --dir)
      WALL_DIR=$2
      shift 2;;
    -t | --time)
      INTERVAL=$2
      shift 2;;
    -m | --mode)
      MODE=$2
      shift 2;;
    -s | --span)
      SPAN=true
      shift;;
    -h | --help)
      usage;;
  esac
done

# load config file
if [ -f $RC_PATH ]
then
  source $RC_PATH
fi

main

exit 0

# vim: ft=zsh ts=2 sw=2 et:
