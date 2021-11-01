#!/bin/bash

function menu (){
    echo "Welcome to the repository"
    echo "Please pick a choice"
    echo "1: Create the repo"
    echo "2: Add a file"
    echo "3: Check out a file"
    echo "4: Check in a file"
    echo "5: Restore a file"
    echo "6: Archive"
    echo "7: Read all logs"
    echo "8: Get the logs for a specific file"
    echo "9: Use external tools in the repository"
    echo "10: Edit a file directily in the repository"
    
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
        "5") restore
        ;;
        "6") archive
        ;;
        "7") printLog
        ;;
        "8") filterLog
        ;;
        "9") otherTools
        ;;
        "10") editFile
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
    echo -e "$(echo -e $1 | sed -z 's/NNNN/\n/g' | sed -z 's/RRRR/\n/g' | sed -z 's/CARRIAGERETURN/\r/g') "
    echo " "
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
    mkdir $1/backup
    touch $1/Logs/repo.log
    echo "REPOCRT" $1, "Repository created by:" $(whoami), $(date +"%Y-%m-%d_%H-%M-%S") "NNNN" >> $dirName/Logs/repo.log
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
            echo "FILADD" $fileName, "added by:" $(whoami), $(date +"%Y-%m-%d_%H-%M-%S") "NNNN     Changes: NNNN" $(singleLinify "$(<$fileName)") "NNNN CARRIAGERETURN" >> $dirName/Logs/repo.log
            cp $fileName $dirName/$fileName
            echo "Added file $fileName"
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
        echo "CAUTION! The current file with the same name in your directory will be overwritten."
        PS3="Choose which file you want to checkout "
        select fileName in $(ls -p $dirName | grep -v /)
        do
            echo "FCHKOUT" $fileName, "added by:" $(whoami), $(date +"%Y-%m-%d_%H-%M-%S") "NNNN" >> $dirName/Logs/repo.log
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
        if [ ! -f "$dirName/$fileName" ]; then
            echo "This file hasnt been added to the repository."
            echo "Would you like to add it?"
            read -p "(y - add file | n - choose a different file or repo)" option
            if [ $option = y ]; then
                addFile
            else
                checkInFile
            fi
        fi
        if [ ! -f "$fileName" ]; then
            echo "No such file exists."
            checkInFile
        else
            read -p "Add a message describing your changes" message
            echo "FCHKIN " $fileName, "File checked in by:" $(whoami), $(date +"%Y-%m-%d_%H-%M-%S") "message: $message" "NNNN \t Changes: NNNN" $(singleLinify "$(diff $fileName $dirName/$fileName)") "NNNN CARRIAGERETURN" >> $dirName/Logs/repo.log
            echo "Checking in " $fileName
            if [ ! -d $dirName/backup/$fileName ]; then
                mkdir -p $dirName/backup/$fileName
            fi
            mv $dirName/$fileName $dirName/backup/$fileName/$fileName"_old_$(date +"%Y-%m-%d_%H-%M-%S")"
            mv $fileName $dirName/$fileName
        fi
        menu
    else
        ### Else if it doesn't ###
        echo "This repository doesn't exist, please re-enter a correct name"
        checkOutFile
    fi
}


function filterLog () {
    echo "Select which repository's logs you want to search"
    read dirName
    if [ -d "$dirName" ]; then
        ### Take action if $dirName exists ###
        # echo "$(multiLinify "$(<$dirName/Logs/repo.log)")"
        echo "Look for all the logs for a specific file. Input the filename"
        read fileName
        
        echo "Logs for the repo" $dirName "regarding the file" $fileName
        echo "LGPRNT" "Logs printed by:" $(whoami), $(date +"%Y-%m-%d_%H-%M-%S") "NNNN" >> $dirName/Logs/repo.log
        #    echo "$(grep '[A-Z]\\{6,8\\}'$fileName $dirName/Logs/repo.log)"
        #    echo "$(echo '[A-Z]\\{6,8\\} $fileName' $dirName/Logs/repo.log)"
        multiLinify "$(grep "[A-Z]\\{6,8\\} $fileName" $dirName/Logs/repo.log)"
        menu
    else
        ### Else if it doesn't ###
        echo "This repository doesn't exist, please re-enter a correct name"
        filterLog
    fi
}

function printLog () {
    echo "Select which repository's logs you want to print"
    read dirName
    if [ -d "$dirName" ]; then
        ### Take action if $dirName exists ###
        # echo "$(multiLinify "$(<$dirName/Logs/repo.log)")"
        echo "Logs for the repo" $dirName
        echo "LGPRNT" "Logs printed by:" $(whoami), $(date +"%Y-%m-%d_%H-%M-%S") "NNNN" >> $dirName/Logs/repo.log
        multiLinify "$(<$dirName/Logs/repo.log)"
        menu
    else
        ### Else if it doesn't ###
        echo "This repository doesn't exist, please re-enter a correct name"
        printLog
    fi
}

function restore () {
    echo "Select working repository"
    read dirName
    if [ -d "$dirName" ]; then
        PS3="Choose which file you want to restore "
        local fileName=NULL
        select f in $(ls $dirName/backup )
        do
            fileName=$f
            break
        done
        PS3="Choose which version of the file you want to restore "
        select specificFileName in $(ls $dirName/backup/$fileName )
        do
            mv $dirName/$fileName $dirName/backup/$fileName/$fileName"_old_$(date +"%Y-%m-%d_%H-%M-%S")"
            mv $dirName/backup/$fileName/$specificFileName $dirName/$fileName
            echo "FILRST" $specificFileName, "File restored by:" $(whoami), $(date +"%Y-%m-%d_%H-%M-%S") >> $dirName/Logs/repo.log
            echo "File $fileName restored. Ready to be checked out."
            break
        done
        menu
    else
        ### Else if it doesn't ###
        echo "This repository doesn't exist, please re-enter a correct name"
        restore
    fi
}

function archive () {
    echo "Select working repository"
    read dirName
    if [ -d "$dirName" ]; then
        echo "Input the archive name without suffix"
        read archiveName
        tar -czvf "$archiveName.tar.gz" $dirName
        #    https://www.howtogeek.com/248780/how-to-compress-and-extract-files-using-the-tar-command-on-linux/
    else
        ### Else if it doesn't ###
        echo "This repository doesn't exist, please re-enter a correct name"
        archive
    fi
}

function otherTools () {
    echo "Select working repository"
    read dirName
    if [ -d "$dirName" ]; then
        PS3="Run one of the following external tools "
        select option in "Compile using Make" "ServeHTTP"
        do
            case $option in
                "ServeHTTP")
                    # https://unix.stackexchange.com/questions/32182/simple-command-line-http-server
                    if [ -f $dirName/index.html ]; then
                        while true ; do nc -l 80 <$dirName/index.html ; done
                    else
                        echo "No index.html found in the repository"
                    fi
                    break
                ;;
                "Compile using Make")
                    cd $dirName
                    make
                    break
                ;;
                *) echo "Unrecognized command"
                menu ;;
            esac
        done
    else
        ### Else if it doesn't ###
        echo "This repository doesn't exist, please re-enter a correct name"
        otherTools
    fi
}

# function mybackup () {
#     local backupdir=".backup/$(date +%F)"
#     mkdir  -p $backupdir
    
#     local action=true
#     for item in "$@" ; do
#         if [ $action = true ]; then
#             action=false
#             continue
#         fi
#         cp $item $backupdir
#     done
# }

function editFile () {
    read -p 'Enter file name to append' fileName
    if [ -e "$fileName" ]; then
        nano $fileName
    else
        echo "invalid file"
    fi
}

menu