#!/bin/dash

dirname='.gits'
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

create=0
delete=0
list=0

# check the arguments
if [ $# -eq 2 ] && [ "$1" = '-d' ] # delete
then
    delete=1
    branch_name="$2"
elif [ $# -eq 1 ] && [ "$1" = '-d' ]
then
    echo "$0: error: branch name required" 1>&2
    exit 1
elif [ $# -eq 1 ] # create
then
    create=1
    branch_name="$1"
elif [ $# -eq 0 ] # list
then
    list=1
else
    echo "usage: $0 [-d] <branch>" 1>&2
    exit 1
fi

# find the current branch
branch=$(cat $HEAD)
logs="$branches/$branch"

if [ "$delete" = '1' ] # delete
then
    if [ ! -f "$branches/$branch_name" ]
    then
        echo "$0: error: branch '$branch_name' doesn't exist" 1>&2
        exit 1
    elif [ "$branch_name" = 'master' ]
    then
        echo "$0: error: can not delete branch 'master'" 1>&2
        exit 1
    elif [ $(cat "$branches/$branch" | sed -n 1p | cut -c1) -lt $(cat "$branches/$branch_name" | sed -n 1p | cut -c1) ]
    then
        echo "$0: error: branch '$branch_name' has unmerged changes" 1>&2
        exit 1
    else
        rm -f "$branches/$branch_name" || exit 1
        echo "Deleted branch '$branch_name'"
    fi
elif [ "$list" = '1' ] # list
then
    for file in $(ls $branches)
    do
        echo "$file"
    done
else # create
    if [ -f "$branches/$branch_name" ]
    then
        echo "$0: error: branch '$branch_name' already exists" 1>&2
        exit 1
    else
        cp "$logs" "$branches/$branch_name" || exit 1
    fi
fi