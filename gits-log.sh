#!/bin/dash

dirname='.gits'
branches='.gits/branches'
HEAD='.gits/HEAD'

# check if .gits exists
if [ ! -d "$dirname" ]
then
    echo "$0: error: gits repository directory $dirname not found" 1>&2
    exit 1
fi

# check the arguments
if [ $# -ne 0 ]
then
    echo "usage: $0" 1>&2
    exit 1
fi

# find the current branch
branch=$(cat $HEAD)
logs="$branches/$branch"

# read logs
cat "$logs"