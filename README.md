# Recycle & Restore Bash Command

Since deleting files on terminal is irreversible and immediate, this shell command is meant to simulate a recycling bin where you can send your files/directories into a recycle bin and restore them if ever you need them again.

 <br/>

## Recycle Script Details
When a file/directory is sent to the recycle bin, it will be renamed to the following to remove potential duplicity:  
`[file_name]_[inode_number]`

You can select where to have your recycle bin directory with the `recycle_directory` variable. Just make sure to update this for the Restore Script too.

A hidden file `.restore.info`, containing the former location of the recycled file, will be created at the end of the script.

### Available Options
- `-v` : Verbose mode
- `-r` : Recursive remove mode (for directories)
- `-i` : Interactive mode

### Recycling Example
```bash recycle.sh -iv [file1] [file2] [directory3]```

 <br/>

## Restore Script Details
Only files within the `recyclebin` can be restored. It will obtain the location the file once was in the hidden `.restore.info` created by the recycle command.

Remember to make sure the `recycle_directory` variable is the same as what was inputted for the recycle command.

### Available Options
- `-v` : Verbose mode
- `-i` : Interactive mode

### Restore Example
```bash restore.sh -iv [file1]_[inode] [file2]_[inode] [directory3]_[inode]```

 <br/>

## Limitations
- Options must be stated before any of the files/directories are given
- There is no error handling if a file with the same inode number and name is recycled, as these values are expected to be unique
