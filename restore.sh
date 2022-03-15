#!/bin/sh

### Setting Option Defaults
v_opt=0 # Verbose mode
i_opt=0 # Interactive mode

opt=0                    # Option exists
recycle_directory="$PWD" # Location of recycling bin

error=0 # Error handling

### Set Functions
# Updates Recycling Info in Hidden Restoration File
updateRecycle() {
  grep -v $1 "$recycle_directory"/.restore.info >"$recycle_directory"/.tempStore
  mv "$recycle_directory"/.tempStore "$recycle_directory"/.restore.info
}

# Automating Response Messages
response() {
  if [[ v_opt -eq 1 ]]; then
    case $1 in
    0) echo "File $(basename "$2") has been restored and overwritten." ;;
    1) echo "Restoration of file $(basename "$2") has been cancelled." ;;
    2) echo "File $(basename "$2") has been restored." ;;
    esac
  fi
}

# Automating Error Messages
sendError() {
  case $1 in
  1)
    echo "Error: No file provided." >&2
    exit $1
    ;;
  2) echo "Error: File does not exist." >&2 ;;
  esac
  error=$1
}

# Print when verbose mode is active
v_optActive() {
  if [[ v_opt -eq 1 ]]; then
    echo $@
  fi
}

### Start of Restore Script
# Checking for Options
for i in $@; do
  if [[ $1 == "-"* ]]; then
    opt=1
    if [[ $1 == *"i"* ]]; then
      i_opt=1
    fi
    if [[ $1 == *"v"* ]]; then
      v_opt=1
    fi
    shift
  fi
done

# Restore Arguments
for i in $@; do

  # Error – No File Given
  if [ $# -eq 0 ]; then #If an input isn't provided
    sendError 1 $i

  # Error – File Doesn't Exist
  elif [ ! -e "$recycle_directory"/recyclebin/$i ]; then
    sendError 2 $i
    continue
  fi

  # If Interactive Mode Is On
  if [ $i_opt -eq 1 ]; then
    read -p "Restore file $(basename "$i")? y/N: " choice
    case $choice in
    y* | Y*) ;;
    *) continue ;;
    esac
  fi

  # File Restore Process with Hidden File from Recycle
  extractDir=$(grep $i "$recycle_directory"/.restore.info | cut -d":" -f2)
  fileDir=$(dirname $extractDir)
  mkdir -p $fileDir

  # Checking if File Already Exists
  if [ -e $extractDir ]; then
    read -p "Do you want to overwrite? y/n" answer
    case $answer in
    y* | Y*)
      mv "$recycle_directory"/recyclebin/$i $fileDir
      updateRecycle $i
      response 0 $i
      ;;
    *)
      response 1 $i
      ;;
    esac
  else
    mv "$recycle_directory"/recyclebin/$i $fileDir
    updateRecycle $i
    response 2 $i
  fi
done

exit $error
