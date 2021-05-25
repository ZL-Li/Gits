#!/bin/sh

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

# check if there is any commit
if [ $(ls -A "$commits" | wc -l) -eq 0 ]
then
    echo "$0: error: this command can not be run until after the first commit" 1>&2
    exit 1
fi

# check the arguments
if [ $# -eq 1 ]
then
    echo "$0: error: empty commit message" 1>&2
    exit 1
elif [ $# -eq 3 ] && [ "$2" = '-m' ]
then
    if echo "$3" | grep -E '^ *$' > /dev/null
    then
        echo "$0: error: empty commit message" 1>&2
        exit 1
    else
        message="$3"
    fi
else
    echo "usage: $0 <branch|commit> -m message" 1>&2
    exit 1
fi

# count the commit number
count=$(ls -A "$commits" | wc -l)

# find the current branch
branch=$(cat $HEAD)
logs="$branches/$branch"
total_logs='.gits/logs'

# $1 is numeric -> commit
if [ "$1" -eq "$1" ] 2> /dev/null && [ $1 -ge 0 ]
then
    if [ $1 -lt $count ]
    then
        checked_num=$1
    else
        echo "$0: error: unknown commit '$1'" 1>&2
        exit 1
    fi

# $2 is not numeric -> branch
else
    if [ ! -f "$branches/$1" ]
    then
        echo "$0: error: unknown branch '$1'" 1>&2
        exit 1
    # merge the current branch
    elif [ "$branch" = "$1" ]
    then
        echo "Already up to date"
        exit 0
    else
        checked_num=$(cat "$branches/$1" | sed -n 1p | cut -c1)
    fi
fi

# the last commit number of the current branch
last_commit=$(cat "$logs" | sed -n 1p | cut -c1)
repo_last_commit="$commits/commit-$last_commit"

# find the last updated commit number of the current branch
last_update=0
for i in $(cat "$logs" | cut -d' ' -f1 | sort -n )
do
    if [ $i -eq $last_update ]
    then
        last_update=$(($last_update + 1))
    fi
done
last_update=$(($last_update - 1))
repo_last_update="$commits/commit-$last_update"

# if checked_num exists in the log file of the current branch
if cat "$logs" | cut -d' ' -f1 | grep -E "$checked_num" > /dev/null
then
    # no matter if the files exists in working directory
    echo "Already up to date"
    exit 0
fi

repo_checked="$commits/commit-$checked_num"

# check errors
for file in $(ls $repo_checked)
do
    # if file in working directory
    if [ -f "$file" ]
    then
        # if file in repo_last_commit
        if [ -f "$repo_last_commit/$file" ]
        then
            # local changes
            if ! diff "$file" "$repo_last_commit/$file" > /dev/null
            then
                echo "$0: error: can not merge: local changes to files" 1>&2
                exit 1
            fi

            # if file in repo_last_update
            if [ -f "$repo_last_update/$file" ]
            then
                if diff "$repo_last_commit/$file" "$repo_last_update/$file" > /dev/null ||
                    diff "$repo_last_commit/$file" "$repo_checked/$file" > /dev/null ||
                    diff "$repo_checked/$file" "$repo_last_update/$file" > /dev/null
                then
                    :
                # can not merge
                else
                    echo "$0: error: can not merge" 1>&2
                    exit 1
                fi
            fi
        fi
    fi
done

for file in $(ls $repo_checked)
do
    cp "$repo_checked/$file" "$file" || exit 1
    cp "$repo_checked/$file" "$index/$file" || exit 1
done

# check if fast forward
if [ $last_update -eq $last_commit ]
then
    echo "Fast-forward: no commit created"
else
    gits-commit -m "$message"
fi

# change the log file
logs_copy=$(cat $logs)
rm -f $logs || exit 1
while read line
do
    number=$(echo $line | cut -d' ' -f1)
    if [ $number -le $checked_num ]
    then
        echo "$line" >> $logs
    elif echo $logs_copy | cut -d' ' -f1 | grep -E "$number" > /dev/null
    then
        echo "$line" >> $logs
    fi
done < $total_logs