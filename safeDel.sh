#! /bin/bash
USAGE="usage: $0 <fill in correct usage>" 

	echo "***************************************"
	echo "***************************************"
	echo "**                                   **"
	echo "**   Name: Azeite Chaleca            **"
	echo "**   Student ID: S1719009            **"
	echo "**   Assignment: Monitor Script      **"
	echo "**   Module: Systems Programming     **"
	echo "**                                   **"	
	echo "***************************************"
	echo "***************************************"

trap trapCtrlC SIGINT
trap trapEndScript EXIT

function trapCtrlC()
{
	local file_counter
		echo -e "\r\nYOU HIT *** Ctrl-C ***"
		echo "EXITING THE APPLICATION"
		if find $HOME/.TrashCan -mindepth 1 -print -quit 2>/dev/null | grep -q .; then
			for var in $HOME/.TrashCan/*; 
				do file_counter=$(($file_counter+1))
			done 
				echo -e "\r\nTHIS DIRECTORY CONTAINS $file_counter FILES..."
		else 
			echo "This directory is empty"
    		fi
	exit 130
}

function trapEndScript()
{
    echo -e "\r\nSCRIPT TERMINATED!"
}


function main() 
{
  trashCan_checker 
  disk_usage_checker
  while getopts :lr:dtmk args #options
   do
   case $args in
     l) list_dir;;
     r) file_recover $OPTARG;;
     d) remove_trash;; 
     t) disk_usage;; 
     m) monitor;; 
     k) kill_monitor;;     
     :) echo "data missing, option -$OPTARG";;
    \?) echo "$USAGE";;
   esac
  done

 ((pos = OPTIND - 1))
 shift $pos

 PS3='option> '
	if (( $# == 0 ))
		then if (( $OPTIND == 1 ))
		
		then select menu_list in list recover delete total monitor kill exit
		do case $menu_list in
			"list") list_dir;;
			"recover") 
			echo "Enter the file name to recover: "
			read ans
			if [[ -z "$ans" ]]; then
			echo "Please enter a file name"
			else  
			file_recover $ans
			fi;;
			"delete") remove_trash;;
			"total") disk_usage;;
			"monitor") monitor;;
			"kill") kill_monitor;;
			"exit") exit 0;;
			*) echo "unknown option";;
		esac
		
	done
	fi
	else
	remove_files "$@"
	fi
 }

function remove_files()
{
	for file_name in "$@"; do
	    if [[ -e $file_name ]]; then
	      echo -e "\r\nDo you wish to remove this $file_name (Y/n): "
	      read ans  
	      case $ans in
		 n | N)
		  echo -e "\r\n$file_name not removed"
		 ;;
		  Y | *)
		  if [[ -e $HOME/.TrashCan/$file_name ]]; then
		     rename=$file_name
		     while [[ -e $HOME/.TrashCan/$rename ]]; do
		     	echo -e "\r\nThe file $file_name already exists, rename the file: "
		        read rename
		     done   
		     mv $file_name $rename
		     mv $rename $HOME/.TrashCan 
		  	echo -e "\r\nFile $rename has been removed"  
		 else
		  	mv $file_name $HOME/.TrashCan
		  	echo -e "\r\nThe file $file_name has been removed"
		 fi
		;;
	        esac
	      else
	      	echo -e "\r\nNo such file exist in this directory."	
	      fi
	   done
}

function monitor()
{
 	source ./monitor.sh
 	monitor 
}

function kill_monitor()
{
	source ./monitor.sh
	trapEndMonitor $(pgrep safeDel.sh)
}

function trashCan_checker() 
{
	if [ ! -d $HOME/.TrashCan ]; then
		echo "*******************************************************"
		echo "************* WELCOME TO safeDel FUNCTION *************"
		echo "*******************************************************"		
    		mkdir -p $HOME/.TrashCan
  	else
   		 echo -e "\r\n*******************************************************"
    		 echo "*                                                     *"	
   		 echo "**********    WELCOME TO safeDel FUNCTION    **********"
    		 echo "*                                                     *"    
    		 echo "*******************************************************"
    		 echo "                                                       "   
  	fi
}

function list_dir() 
{
	local fileName
	local fileSize
	local fileType
	
	if find $HOME/.TrashCan -mindepth 1 -print -quit 2>/dev/null | grep -q .; then
	for var in $HOME/.TrashCan/*; do
   		fileName="$(basename $var)"
   		fileSize=$(wc -c <"$var")
   		fileType=$(echo $fileName |awk -F . '{if (NF>1) {print $NF}}')
		#while IFS="/" read -r fileName name; do
   		echo "fileName: $fileName Size: $fileSize bytes Type: $fileType"
  	done
 	else
   		echo "Empty directory!"
 	fi
}

function file_recover() 
{
	if [[ -e $HOME/.TrashCan/$1 ]]; then
		if [[ -e $1 ]]; then
		
			echo "The file $1 already exists in this directory"
		else
			chmod 755 $HOME/.TrashCan/$1
			mv $HOME/.TrashCan/$1 .
			echo "File recovered"
     		fi
	else
     		echo "The file $1 does not exist in the directory"
	fi  
}

function remove_trash() 
{
	if find $HOME/.TrashCan -mindepth 1 -print -quit 2>/dev/null | grep -q .; then
		for var in $HOME/.TrashCan/*; do
			echo "Do you wish to remove this file $var (y/N):"
			read ans
			case $ans in
     			y | Y) rm $var
        		echo "File $var deleted";;
     			N | *) echo "File $var not deleted";;  
     			esac 
   		done
	else
		echo "Empty directory"
	fi
}

function disk_usage() 
{
	local kb
	local disk_usage=0
	local size
	
	if find $HOME/.TrashCan -mindepth 1 -print -quit 2>/dev/null | grep -q .; then
	  	for var in $HOME/.TrashCan/*; do
	 		name="$var"
	 	size=$(wc -c <"$var")
		disk_usage=$(($disk_usage+$size))
		done 
 			echo "Total $disk_usage bytes of disk usage ."
	else
   		echo "0 disk usage ."
 	fi
}

function disk_usage_checker() 
{
	local kb
	local disk_usage=0
	local size
	
	if find $HOME/.TrashCan -mindepth 1 -print -quit 2>/dev/null | grep -q .; then
		for var in $HOME/.TrashCan/*; do
			name="$var"
   			size=$(wc -c <"$var")
   			disk_usage=$(($disk_usage+$size))
  		done 
  		if [[ $disk_usage -gt 1024 ]]; then
   			zenity --warning --text=" Disk usage has exceeded the limit of 1 kilobyte of memory with $disk_usage bytes  " 
  		fi
	fi
}

main "$@"
