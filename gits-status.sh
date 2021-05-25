#!/bin/sh

dirname='.gits'
index='.gits/index'
commits='.gits/commits'
branches='.gits/branches'
HEAD='.gits/HEAD'
temp='.gits/temp'

# check if .gits exists
if [ ! -d "$dirname" ]
then
    echo "$0: error: gits repository directory $dirname not found" 1>&2
    exit 1
fi

# create a temporary file
touch "$temp" || exit 1

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

# put filenames in temp
for file in $(ls) $(ls $index) $(ls $repository)
do
    # check if the filename is valid
    if echo "$file" | grep -vE '^[a-zA-Z0-9][a-zA-Z0-9\._-]*$' > /dev/null
    then
        :
    elif echo "$file" | grep -E '^gits-.*' > /dev/null
    then
        :
    else
        echo "$file" >> $temp
    fi
done

for file in $(cat $temp | sort | uniq)
do
    # file not in working directory
    if [ ! -f "$file" ]
    then
        # file not in index
        if [ ! -f "$index/$file" ]
        then
            # file in repository
            echo "$file - deleted"

        # file in index
        else
            # file not in repository
            if [ ! -f "$repository/$file" ]
            then
                echo "$file - added to index, file deleted"

            # file in repository
            else
                if diff "$index/$file" "$repository/$file" > /dev/null
                then
                    echo "$file - file deleted"
                else
                    echo "$file - file deleted, different changes staged for commit"
                fi
            fi
        fi

    # file in working directory
    else
        # file not in index
        if [ ! -f "$index/$file" ]
        then
            echo "$file - untracked"

        # file in index
        else
            # file not in repository
            if [ ! -f "$repository/$file" ]
            then
                if diff "$file" "$index/$file" > /dev/null
                then
                    echo "$file - added to index"
                else
                    echo "$file - added to index, file changed"
                fi
            # file in repository
            else
                # working file = index
                if diff "$file" "$index/$file" > /dev/null
                then
                    # working file = index = repository
                    if diff "$file" "$repository/$file" > /dev/null
                    then
                        echo "$file - same as repo"

                    # working file = index != repository
                    else
                        echo "$file - file changed, changes staged for commit"
                    fi
                
                # working file != index
                else
                    # working file != index = repository
                    if diff "$index/$file" "$repository/$file" > /dev/null
                    then
                        echo "$file - file changed, changes not staged for commit"

                    # working file != index != repository
                    else
                        echo "$file - file changed, different changes staged for commit"
                    fi
                fi
            fi
        fi
    fi
done

# remove the temporary file
rm -f $temp || exit 1
