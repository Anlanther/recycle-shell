#!/bin/sh

### Setting Option Defaults
i_opt=0 # Interactive mode
v_opt=0 # Verbose mode
r_opt=0 # Recursive remove mode

opt=0   # Option exists
error=0 # Error handling

recycle_directory="$HOME" # Location of recycling bin

### Setting Functions
# Automating Error Messages
sendError() {
  case $1 in
  1)
    echo "Error: Recycle. At least one file required." >&2
    exit $1
    ;;
  2) echo "Error: Recycle - $(basename $2). File does not exist." >&2 ;;
  3) echo "Error: Recycle - $(basename $2). A directory cannot be deleted." >&2 ;;
  4) echo "Attempting to delete recycle – operation aborted" >&2 ;;
  esac
  error=$1
}

# Print when verbose mode is active
v_optActive() {
  if [[ v_opt -eq 1 ]]; then
    echo $@
  fi
}

### Creates Recycle Bin Within Desired Directory
if [ ! -d "$recycle_directory"/recyclebin ]; then
  mkdir "$recycle_directory"/recyclebin
fi

### Start of Recycle Script
# Checking for Options
for i in !@; do
  if [[ $1 == "-"* ]]; then
    opt=1
    if [[ $1 == *"i"* ]]; then
      i_opt=1
    fi
    if [[ $1 == *"v"* ]]; then
      v_opt=1
    fi
    if [[ $1 == *"r"* ]]; then
      r_opt=1
    fi
    shift
  fi
done

# Error – No File Given
if [ $# -eq 0 ]; then
  sendError 1 !@
fi

# Moving File for Recycling
for i in $@; do

  # Error – File Doesn't Exist
  if [ ! -e $i ]; then
    sendError 2 $i
    continue

  # If File is Directory
  elif [ -d $i ]; then
    # Check if -r is used
    if [[ $r_opt -eq 1 ]]; then
      for file in $(readlink -f $i)'/'*; do
        bash $0 $file
      done
      rm -r $i
      v_optActive "Files in $(readlink $i) have been recycled."
    else
      # Error – Cannot delete directory
      sendError 3 $i
    fi

  # Error – Deleting Recycle Bin
  elif echo $i | grep -q "$(basename $0)"; then
    sendError 4 $i

  # Recycle Arguments
  else
    inode=$(ls -i $i | cut -d" " -f1)
    fileName=$(basename $i)
    fileName_inode=$fileName"_"$inode
    originPath=$(readlink -f $i)

    # If Interactive Mode Is On
    if [ $i_opt -eq 1 ]; then
      read -p "Are you sure you want to remove file $i? y/N: " answer
      case $answer in
      y* | Y*) ;;
      *) continue ;;
      esac
    fi

    mv $i "$recycle_directory"/recyclebin/$fileName_inode
    v_optActive "File $(basename $i) has been recycled."

    # Input Recycling Information to Hidden File for Restoration
    echo $fileName_inode":"$originPath >>"$recycle_directory"/.restore.info
  fi
done

exit $error
