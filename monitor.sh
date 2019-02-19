#!/bin/bash
Listen_Trash(){
while true
do
find $HOME/.TrashCan -type f -print0 | xargs -0 md5sum > sum.md5
sleep 15
find $HOME/.TrashCan -type f -print0 | xargs -0 md5sum > sum1.md5
while IFS=" " read -r oldhash name; do
 if [[ ! -e "$name" ]]; then
  zenity --info --text="$(date +"%F %R") The file $name has been deleted or recovered from the TrashCan"
 else
 while IFS=" " read -r oldhash1 name1; do
 if [[ "$name" == "$name1" ]]; then
  if [[ "$oldhash" != "$oldhash1" ]]; then
    zenity --info --text= "$(date +"%F %R") The file $name has been modified"
  fi
 fi
 done <sum1.md5
 fi
done <sum.md5
while IFS=" " read -r oldhash2 name2; do
if ! grep -q "$name2" sum.md5; then
  zenity --info --text="$(date +"%F %R") The file $name2 has been added recently to TrashCan"
fi
done <sum1.md5

rm sum.md5
rm sum1.md5
done
}

Listen_Trash&
