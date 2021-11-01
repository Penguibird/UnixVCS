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
    echo "6: Read all logs"
    
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
        "4") checkInFile
        ;;
        "5") archive
        ;;
        "6") printLog
        ;;
        *) echo "Unrecognized command"
        menu ;;
    esac
}



# Replaces all linebreaks in a file with new line placeholder characters
# Allows us to store multi-line info on a single line
function singleLinify () {
    echo $(echo $1 | sed -z 's/\n/NNNN/g' | sed -z 's/\r/RRRR/g')
}

# Replaces line break placeholder with actual linebreaks
function multiLinify () {
    echo -e "$(echo $1 | sed -z 's/NNNN/\n/g' | sed -z 's/RRRR/\n/g')"
    #     printf \n
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
    echo "REPOCRT" $1, "Repository created by:" $(whoami), $(date +"%Y-%m-%d_%H-%M-%S") >> $dirName/Logs/repo.log
    menu
}


function addFile () {
    echo "What is the name of the directory you wish to add a file to: "
    read dirName
    if [ -d "$dirName" ]; then
        ### Take action if $dirName exists ###
        echo "Enter the name of the file you wanna create: "
        read fileName
        if [ -f "$dirName/$fileName" ]; then
            echo "This file already exists. You can check it out, modify it and check it back."
            echo "Would you like to do that?"
            read -p "(y - go to menu | n - choose a different file)" option
            if [ $option = y ]; then
                checkOutFile
            else
                addFile
            fi
        else
            touch $dirName/$fileName
            echo "FILEADD" $fileName, "added by:" $(whoami), $(date +"%Y-%m-%d_%H-%M-%S") "Changes: NNNN" $(singleLinify "$(<$fileName)" ) >> $dirName/Logs/repo.log
            menu
        fi
    else
        ### Else if it doesn't ###
        echo "This repository doesn't exist, please re-enter a correct name"
        addFile
    fi
}


function checkOutFile () {
    echo "Select working repository"
    read dirName
    if [ -d "$dirName" ]; then
        ### Take action if $dirName exists ###
        echo "The current file in your directory will be overwritten."
        PS3="Choose which file you want to checkout "
        select fileName in $(ls -p $dirName | grep -v /)
        do
            echo "FCHKOUT" $fileName, "added by:" $(whoami), $(date +"%Y-%m-%d_%H-%M-%S") >> $dirName/Logs/repo.log
            echo "Checking out " $fileName
            #   https://stackoverflow.com/questions/8488253/how-to-force-cp-to-overwrite-without-confirmation
            yes | cp -rf $dirName/$fileName $fileName
            menu
        done
    else
        ### Else if it doesn't ###
        echo "This repository doesn't exist, please re-enter a correct name"
        checkOutFile
    fi
}

function checkInFile () {
    echo "Select working repository"
    read dirName
    if [ -d "$dirName" ]; then
        ### Take action if $dirName exists ###
        echo "Choose which file you want to check in "
        read fileName
        if [ -f "$dirName/$fileName" ]; then
            echo "This file hasnt been added to the repository."
            echo "Would you like to add it?"
            read -p "(y - add file | n - choose a different file or repo)" option
            if [ $option = y ]; then
                addFile
            else
                checkInFile
            fi
        fi
        if [ -f "$fileName" ]; then
            echo "No such file exists."
            checkInFile
        else
            echo "FCHKIN " $fileName, "added by:" $(whoami), $(date +"%Y-%m-%d_%H-%M-%S") "Changes: NNNN" $(singleLinify "$(diff $fileName $dirName/$fileName)" ) >> $dirName/Logs/repo.log
            echo "Checking in " $fileName
            mv $dirName/$fileName $dirName/backup/$fileName/$fileName_old_$(date +"%Y-%m-%d_%H-%M-%S")
            mv $fileName $dirName/$fileName
        fi
    else
        ### Else if it doesn't ###
        echo "This repository doesn't exist, please re-enter a correct name"
        checkOutFile
    fi
}



function printLog () {
    echo "Select which repository's logs you want to print"
    read dirName
    if [ -d "$dirName" ]; then
        ### Take action if $dirName exists ###
        # echo "$(multiLinify "$(<$dirName/Logs/repo.log)")"
        echo "Logs for the repo" $dirName
        multiLinify "$(<$dirName/Logs/repo.log)"
        menu
    else
        ### Else if it doesn't ###
        echo "This repository doesn't exist, please re-enter a correct name"
        addFile
    fi
}


menu