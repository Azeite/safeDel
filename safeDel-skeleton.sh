#! /bin/bash
USAGE="usage: $0 <fill in correct usage>"

trap trapCtrlC SIGINT
trap trapEndScript EXIT

function trapCtrlC(){
   echo -e "\r\nYou hit Ctrl-C. You are going to leave the application!"
   exit 130
}

function trapEndScript(){
   echo -e "\r\nFinishing the program $NAME!"
}


function main() {
 Check_TrashCan
 while getopts :lr:dtmk args #options
  do
  case $args in
    l) List_Trash;;
    r) File_Recover $OPTARG;;
    d) Delete_Trash;;
    t) Total_Usage;;
    w) echo "m option";;
    k) echo "k option";;
    :) echo "data missing, option -$OPTARG";;
   \?) echo "$USAGE";;
  esac
 done

((pos = OPTIND - 1))
shift $pos

PS3='option> '

if (( $# == 0 ))
 then if (( $OPTIND == 1 ))
   then select menu_list in list recover delete total watch kill exit
     do case $menu_list in
        "list") List_Trash;;
        "recover") echo "Enter the file name to recover: "
                read ans
                File_Recover $ans;;
        "delete") Delete_Trash;;
        "total") Total_Usage;;
        "monitor") echo "w";;
        "kill") echo "k";;
        "exit") exit 0;;
        *) echo "unknown option";;
        esac
     done
fi
else
 for name in "$@"; do
   if [[ -e $name ]]; then
     echo "Do you want to delete $name (Y/n): "
     read ans
     case $ans in
        n | N)
         echo "$name not deleted"
        ;;
         Y | *)
         if [[ -e $HOME/.TrashCan/$name ]]; then
            renam=$name
            while [[ -e $HOME/.TrashCan/$renam ]]; do
                echo "file with the same name $name already exists,please rename the file: "
               read renam
            done
         mv $name $renam

            mv $renam $HOME/.TrashCan

         else
         mv $name $HOME/.TrashCan
         fi
       ;;
     esac
    else
      echo "No such file exist in this directory."    

    fi
  done
fi
}

function Check_TrashCan() {
 if [ ! -d $HOME/.TrashCan ]; then
   echo "hello"
   mkdir -p $HOME/.TrashCan
 else
   echo "Welcome"
 fi
}

function List_Trash() {
 local name
 local size
 local typ
if find $HOME/.TrashCan -mindepth 1 -print -quit 2>/dev/null | grep -q .; then
 for var in $HOME/.TrashCan/*; do
  name="$var"
  size=$(wc -c <"$var")
  typ=$(file $var)
  echo "FileName: $name Size: $size bytes Type: $typ"
 done
else
  echo "TrashCan is Empty"
fi
}

function File_Recover() {
 if [[ -e $HOME/.TrashCan/$1 ]]; then
    if [[ -e $1 ]]; then
      echo "there is a file with the same name $1 exists in this directory"
    else
      chmod 755 $HOME/.TrashCan/$1
      mv $HOME/.TrashCan/$1 .
      echo "$1 file have been recovered"
    fi
 else
    echo "The file $1 does not exist in the TrashCan"
 fi
}

function Delete_Trash() {

 if find $HOME/.TrashCan -mindepth 1 -print -quit 2>/dev/null | grep -q .; then
  for var in $HOME/.TrashCan/*; do
    echo "Do you want to delete this file $var (y/N):"
    read ans
    case $ans in
    y) rm $var
       echo "file $var deleted";;
    N | *) echo "file $var is not deleted";;
    esac
  done
  else
  echo "TrashCan is empty"
  fi
}

function Total_Usage() {
local kb
local disk_usage=0
local size
 if find $HOME/.TrashCan -mindepth 1 -print -quit 2>/dev/null | grep -q .; then
 for var in $HOME/.TrashCan/*; do
  name="$var"
  size=$(wc -c <"$var")
  disk_usage=$(($disk_usage+$size))
 done
  echo "The disk usage of the TrashCan is $disk_usage bytes."
else
  echo "The disk usage of the TrashCan is 0 bytes."
fi
}

#creation
#change 
#delection
#man -l fileName
main "$@"
