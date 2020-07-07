#!/bin/bash

# Script to backup whole system
# You can use ENV_OPTS variable to customazie rsync options
#
# usage: full-system-backup.sh DEST_DIR

function print_usage() {
  echo "usage: full-system-backup.sh DEST_DIR"
}

if [ $# -ne 1 ]; then
  print_usage
  exit 101
fi

DEST=$1

RSYNC_OPTS="-aHAXxP $ENV_OPTS"

echo "Running with options: $RSYNC_OPTS"

mkdir -p $DEST || { echo "fail"; exit 102; }
# backup the system (EXCLUDE /home)
rsync  $RSYNC_OPTS --exclude={"/home/*","/dev/*","/proc/*","/sys/*","/tmp/*","/run/*","/mnt/*","/media/*","/lost+found"} / $DEST

# backup home directories excluding unnecessary stuff
for homedir in $(ls /home) ; do
  if [[ "$homedir" != "lost+found" ]] ; then
    mkdir -p $DEST/home/$homedir
    rsync $RSYNC_OPTS --exclude-from=rsync-homedir-excludes.txt /home/$homedir/ $DEST/home/$homedir/
  fi
done
