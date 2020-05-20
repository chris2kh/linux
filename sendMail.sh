#!/bin/bash

# variable NAUTILUS_SCRIPT_SELECTED_FILE_PATHS extracts the location of
# the file we want to upload. However, it doesnt work if there are spaces in
# name of the location. To fix this, we can temporarily the state of
# the IFS variable.

IFS_BAK=$IFS
IFS="
"

file=$NAUTILUS_SCRIPT_SELECTED_FILE_PATHS
subject=${file##*/}

email=$(zenity --entry --text="email address" --width=400 --height=50) || exit

echo " "|mail -s $subject -A $NAUTILUS_SCRIPT_SELECTED_FILE_PATHS $email

zenity --info --text="email was sent!" --width=250 --height=50

IFS=$IFS_BAK
