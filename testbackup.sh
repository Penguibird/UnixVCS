#!/bin/bash

function mybackup {
	local backupdir=".backup/$(date +%F)"
	mkdir  -p $backupdir

	local action=true 
	for item in "$@" ; do 
		if [ $action = true ]; then 
			action=false
			continue
		fi
		cp $item $backupdir 
	done
}

action=$1
case $action in
	backup)
		mybackup $@
		;;
	*)
		echo "Unkown action"
		;;
esac
	
	

	




