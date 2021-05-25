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

# check the arguments
if [ $# -ge 3 ] && [ "$1" = '--force' ] && [ "$2" = '--cached' ]
then
    force=1
    cached=1
elif [ $# -ge 2 ] && [ "$1" = '--force' ]
then
    force=1
    cached=0
elif [ $# -ge 2 ] && [ "$1" = '--cached' ]
then
    force=0
    cached=1
elif [ $# -ge 1 ]
then
    force=0
    cached=0
else
    echo "usage: $0 [--force] [--cached] <filenames>" 1>&2
    exit 1
fi

# find the current branch
branch=$(cat $HEAD)
logs="$branches/$branch"

# find the last commited repository
if [ $(ls -A "$commits" | wc -l) -eq 0 ]
then
    repository="$commits"
else
    count=$(cat "$logs" | sed -n 1p | cut -c1)
    repository="$commits/commit-$count"
fi

# first iteration check all the files
for file in "$@"
do
    if [ "$file" != "--force" ] && [ "$file" != "--cached" ]
    then
        # check if the filename is valid
        if echo "$file" | grep -vE '^[a-zA-Z0-9][a-zA-Z0-9\._-]*$' > /dev/null
        then
            echo "$0: error: invalid filename '$file'" 1>&2
            exit 1
        fi

        # check if the file is in the index
        if [ ! -f "$index/$file" ]
        then
            echo "$0: error: '$file' is not in the gits repository" 1>&2
            exit 1
        fi

        # check if the file is in the working file
        if [ ! -f "$file" ]
        then
            :
        
        # if --force
        elif [ $force = '1' ]
        then
            :
        
        # working file = index
        elif diff "$index/$file" "$file" > /dev/null
        then
            # working file = index = repository
            if diff "$file" "$repository/$file" > /dev/null 2>&1
            then
                :
            # working file = index != repository
            else
                if [ $cached = '0' ]
                then
                    echo "$0: error: '$file' has staged changes in the index" 1>&2
                    exit 1
                fi
            fi

        # working file != index
        else
            # working file != index = repository
            if diff "$index/$file" "$repository/$file" > /dev/null 2>&1
            then
                if [ $cached = '0' ]
                then
                    echo "$0: error: '$file' in the repository is different to the working file" 1>&2
                    exit 1
                fi
            # working file != index != repository
            else
                echo "$0: error: '$file' in index is different to both to the working file and the repository" 1>&2
                exit 1
            fi
        fi
    fi
done

# second iteration remove
for file in "$@"
do
    if [ "$file" != "--force" ] && [ "$file" != "--cached" ]
    then
        # check if the file is in the working directory
        if [ ! -f "$file" ]
        then
            rm -f "$index/$file" || exit 1
        
        # if --force
        elif [ $force = '1' ]
        then
            rm -f "$index/$file" || exit 1
            if [ $cached = '0' ]
            then
                rm -f "$file" || exit 1
            fi
        
        # working file = index
        elif diff "$index/$file" "$file" > /dev/null
        then
            # working file = index = repository
            if diff "$file" "$repository/$file" > /dev/null 2>&1
            then
                rm -f "$index/$file" || exit 1
                if [ $cached = '0' ]
                then
                    rm -f "$file" || exit 1
                fi
            # working file = index != repository
            else
                if [ $cached = '1' ]
                then
                    rm -f "$index/$file" || exit 1
                fi
            fi

        # working file != index
        else
            # working file != index = repository
            if diff "$index/$file" "$repository/$file" > /dev/null 2>&1
            then
                if [ $cached = '1' ]
                then
                    rm -f "$index/$file" || exit 1
                fi
            fi
        fi
    fi
done