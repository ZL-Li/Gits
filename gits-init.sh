#!/bin/sh

dirname='.gits'

# check the arguments
if [ $# -ne 0 ]
then
    echo "usage: $0" 1>&2
    exit 1
fi

# check if .gits exists
if [ -d "$dirname" ]
then
    echo "$0: error: $dirname already exists" 1>&2
    exit 1
fi

# initialize directories and files
mkdir "$dirname" &&
mkdir "$dirname/index" &&
mkdir "$dirname/commits" &&
mkdir "$dirname/branches" &&
touch "$dirname/branches/master" &&
touch "$dirname/logs" &&
echo master > "$dirname/HEAD" &&
echo "Initialized empty gits repository in $dirname"