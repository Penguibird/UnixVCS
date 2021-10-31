#!/bin/bash

function menu (){
    echo "Welcome to the repository"
    echo "Please pick a choice"
    echo "1: Create the repo"
    echo "2: Add a file"
    echo "3: Check out a file"
    echo "4: Check in a file" 
    echo "5: Restore a file"
    echo "5: Archive"

    read input
    case $input in 
        "1") echo "Enter the name of repo you want to create: "
          read dirName
          createReposit $dirName
            ;;
        "2") addFile $dirName
             ;;
        "3") checkOutFile
             ;;
        "4") restoreFile
             ;;
        "5") archive
             ;;
        *) echo "Unrecognized command"
        menu ;;
    esac
}


function createReposit () {
     if [ -d "$1" ]; then
          ### Take action if $dirName exists ###
          echo "Directory already exists"
          createReposit
     else
          ### Else if it doesn't ###
          mkdir $1
          echo "created Reposit"
     fi
     mkdir $1/Logs
     touch $1/Logs/repo.log
     menu
}


function addFile () {
     echo "What is the name of the directory you wish to add a file to: "
     read dirName
     if [ -d "$dirName" ]; then
          ### Take action if $dirName exists ###
          echo "Enter the name of the file you wanna create: "
          read fileName
          touch $dirName/$fileName.txt
          echo $fileName, "accessed by:" $(whoami), $(date +"%Y-%m-%d_%H-%M-%S") >> $dirName/Logs/repo.log
     else
          ### Else if it doesn't ###
          echo "This repository doesn't exist, please re-enter a correct name"
          addFile
     fi
}


menu