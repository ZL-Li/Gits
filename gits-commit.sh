#!/bin/dash

dirname='.gits'
index='.gits/index'
commits='.gits/commits'
branches='.gits/branches'
HEAD='.gits/HEAD'

# check if .gits exists
if [ ! -d "$dirname" ]
then
    echo "$0: error: gits repository directory $dirname not found" 1>&2
    exit 1
fi

# check the arguments
if [ $# -eq 2 ] && [ "$1" = '-m' ] &&
    echo "$2" | grep -vE '^ *$' > /dev/null
then
    message="$2"
elif [ $# -eq 3 ] && [ "$1" = '-a' ] && [ "$2" = '-m' ] &&
    echo "$3" | grep -vE '^ *$' > /dev/null
then
    message="$3"
else
    echo "usage: $0 [-a] -m commit-message" 1>&2
    exit 1
fi

# gits-commit -a -m message
if [ $# -eq 3 ]
then
    for file in "$index"/*
    do
        filename=$(basename "$file")
        if [ "$filename" = '*' ]
        then
            :
        # when the file doesn't exist in current directory
        elif [ ! -f "$filename" ]
        then
            rm -f "$index/$filename" || exit 1
        else
            cp "$filename" "$index" || exit 1
        fi
    done
fi

# count the commit number
count=$(ls -A "$commits" | wc -l)

# find the current branch
branch=$(cat $HEAD)
logs="$branches/$branch"
total_logs='.gits/logs'

# check if there is anything to commit
if [ $count -eq 0 ] && [ "$(ls -A $index)" = '' ]
then
    echo "nothing to commit"
    exit 1
elif [ $count -gt 0 ]
then
    num=$(cat "$logs" | sed -n 1p | cut -c1)
    if diff "$index" "$commits/commit-$num" > /dev/null
    then
        echo "nothing to commit"
        exit 1
    fi
fi

# insert commit number and message to the first line of logs and total_logs
if [ $count -eq 0 ]
then
    echo "$count $message" >> "$logs"
    echo "$count $message" >> "$total_logs"
else
    sed -i "1i $count $message" "$logs"
    sed -i "1i $count $message" "$total_logs"
fi

# add a copy to the commmit-$count
mkdir "$commits/commit-$count" || exit 1

for file in "$index"/*
do
    if [ "$file" != "$index/*" ]
    then
        cp "$file" "$commits/commit-$count" || exit 1
    fi
done

echo "Committed as commit $count"
