#!/bin/bash

if [ $# -eq 0 ] ; then
    echo "Enter the git repository:"
    read gitRepo
else
    gitRepo=$1
fi

if [ ! $2 ] ; then
    echo "Enter destination path:"
    read destPath
#    destPath=$(readlink -m ${destPath})
else
    destPath=$2
fi

if [[ ! "$gitRepo" =~ [a-zA-Z0-9_\-]+@[a-zA-Z0-9_\-]+\.[a-zA-Z0-9_\-]+\:[a-zA-Z0-9_\-]+\/[a-zA-Z0-9_\-]+.git$ ]] ; then
    if [[ "$gitRepo" =~ .*[\/\.]([a-zA-Z0-9_\-]+\.[a-zA-Z0-9_\-]+)\/([a-zA-Z0-9_\-]+\/[a-zA-Z0-9_\-]+.git$) ]] ; then
        gitRepo="git@${BASH_REMATCH[1]}:${BASH_REMATCH[2]}"
    else
        if [[ "$gitRepo" =~ ([a-zA-Z0-9_\-]+\/[a-zA-Z0-9_\-]+.git$) ]] ; then
            gitRepo="git@github.com:${BASH_REMATCH[1]}"
        else
            echo "Not a proper git repository (dont forget the .git at the end)"
            exit 0
        fi
    fi
fi

git clone $gitRepo ${destPath}

