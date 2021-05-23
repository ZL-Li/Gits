#!/bin/dash

dirname='.gits'
index='.gits/index'
commits='.gits/commits'

# check if .gits exists
if [ ! -d "$dirname" ]
then
    echo "$0: error: gits repository directory $dirname not found" 1>&2
    exit 1
fi

# check the arguments
if [ $# -ne 1 ]
then
    echo "usage: $0 <commit>:<filename>" 1>&2
    exit 1
elif echo "$1" | grep -vE ':' > /dev/null
then
    echo "$0: error: invalid object $1" 1>&2
    exit 1
else
    commit=$(echo "$1" | cut -d':' -f1)
    filename=$(echo "$1" | cut -d':' -f2-)
fi

# count the commit number
count=$(ls -A "$commits" | wc -l)

# commit is omitted
if [ "$commit" = '' ]
then
    # check if the filename is valid
    if echo "$filename" | grep -vE '^[a-zA-Z0-9][a-zA-Z0-9\._-]*$' > /dev/null
    then
        echo "$0: error: invalid filename '$filename'" 1>&2
        exit 1
    # check if the file exists in index
    elif [ ! -f "$index/$filename" ]
    then
        echo "$0: error: '$filename' not found in index" 1>&2
        exit 1
    else
        cat "$index/$filename"
    fi
# commit number is a positive number less than $count
elif [ "$commit" -eq "$commit" ] 2> /dev/null &&
    [ $commit -ge 0 ] && [ $commit -lt $count ]
then
    # check if the filename is valid
    if echo "$filename" | grep -vE '^[a-zA-Z0-9][a-zA-Z0-9\._-]*$' > /dev/null
    then
        echo "$0: error: invalid filename '$filename'" 1>&2
        exit 1
    # check if the file exists in commit-$commit
    elif [ ! -f "$commits/commit-$commit/$filename" ]
    then
        echo "$0: error: '$filename' not found in commit $commit" 1>&2
        exit 1
    else
        cat "$commits/commit-$commit/$filename"
    fi
else
    echo "$0: error: unknown commit '$commit'" 1>&2
    exit 1
fi
