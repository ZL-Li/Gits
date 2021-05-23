#!/bin/dash

dirname='.gits'
index='.gits/index'

# check if .gits exists
if [ ! -d "$dirname" ]
then
    echo "$0: error: gits repository directory $dirname not found" 1>&2
    exit 1
fi

# check the arguments
if [ $# -eq 0 ]
then
    echo "usage: $0 <filenames>" 1>&2
    exit 1
fi

# check the files
for file in "$@"
do
    # check if the filename is valid
    if echo "$file" | grep -vE '^[a-zA-Z0-9][a-zA-Z0-9\._-]*$' > /dev/null
    then
        echo "$0: error: invalid filename '$file'" 1>&2
        exit 1
    # when the file doesn't exist in both current directory and index
    elif [ ! -f "$file" ] && [ ! -f "$index/$file" ]
    then
        echo "$0: error: can not open '$file'" 1>&2
        exit 1
    fi
done

for file in "$@"
do
    # when the file doesn't exist in current directory but exists in index
    if [ ! -f "$file" ] && [ -f "$index/$file" ]
    then
        rm -f "$index/$file" || exit 1
    else
        cp "$file" "$index" || exit 1
    fi
done