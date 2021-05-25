#!/bin/sh

dirname='.gits'
index='.gits/index'
commits='.gits/commits'
branches='.gits/branches'
HEAD='.gits/HEAD'
temp1='.gits/temp1'
temp2='.gits/temp2'
temp3='.gits/temp3'
temp='.gits/temp'

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
    if [ -f "$branches/$1" ]
    then
        branch_name="$1"
    else
        echo "$0: error: unknown branch '$1'" 1>&2
        exit 1
    fi
else
    echo "usage: $0 <branch>" 1>&2
    exit 1
fi

# find the current branch
branch=$(cat $HEAD)

# check if already in the branch
if [ $branch = $branch_name ]
then
    echo "Already on '$branch_name'"
    exit 0
fi

# find the last commited repository for two branches
count1=$(cat "$branches/$branch" | sed -n 1p | cut -c1)
repository1="$commits/commit-$count1"

count2=$(cat "$branches/$branch_name" | sed -n 1p | cut -c1)
repository2="$commits/commit-$count2"

# create three temporary files for storing files failed, files to copy and files to remove
touch "$temp1" || exit 1
touch "$temp2" || exit 1
touch "$temp3" || exit 1
touch "$temp" || exit 1

# put filenames in temp
for file in $(ls $repository1) $(ls $repository2)
do
    # check if the filename is valid
    if echo "$file" | grep -vE '^[a-zA-Z0-9][a-zA-Z0-9\._-]*$' > /dev/null
    then
        :
    else
        echo "$file" >> $temp
    fi
done

for filename in $(cat $temp | sort | uniq)
do
    # if exists in repo2
    if [ -f "$repository2/$filename" ]
    then
        # if exists in repo1
        if [ -f "$repository1/$filename" ]
        then
            # repo1 = repo2
            if diff "$repository1/$filename" "$repository2/$filename" > /dev/null
            then
                :
            
            # repo1 != repo2
            else
                # if exists in index
                if [ -f "$index/$filename" ]
                then
                    # index = repo2
                    if diff "$index/$filename" "$repository2/$filename" > /dev/null
                    then
                        :
                    
                    # index != repo2
                    else
                        # index = repo1
                        if diff "$index/$filename" "$repository1/$filename" > /dev/null
                        then
                            # if exists in working directory
                            if [ -f "$filename" ]
                            then
                                # working directory = index
                                if diff "$filename" "$index/$filename" > /dev/null
                                then
                                    echo "$filename" >> "$temp2"
                                
                                # working directory != index
                                else
                                    echo "$filename" >> "$temp1"
                                fi
                            
                            # if not exist in working directory
                            else
                                echo "$filename" >> "$temp2"
                            fi

                        # index != repo1
                        else
                            echo "$filename" >> "$temp1"
                        fi
                    fi
                
                # if not exist in index
                else
                    echo "$filename" >> "$temp1"
                fi
            fi
        
        # if not exist in repo1
        else
            # if exists in index
            if [ -f "$index/$filename" ]
            then
                # index = repo2
                if diff "$index/$filename" "$repository2/$filename" > /dev/null
                then
                    :
                
                # index != repo2
                else
                    echo "$filename" >> "$temp1"
                fi
            
            # if not exist in index
            else
                # if exists in working directory
                if [ -f "$filename" ]
                then
                    echo "$filename" >> "$temp1"
                
                # if not exist in working directory
                else
                    echo "$filename" >> "$temp2"
                fi
            fi
        fi
    
    # if not exist in repo2
    else
        # if exists in index
        if [ -f "$index/$filename" ]
        then
            # index = repo1
            if diff "$index/$filename" "$repository1/$filename" > /dev/null
            then
                # if exists in working directory
                if [ -f "$filename" ]
                then
                    # working directory = repo1
                    if diff "$filename" "$repository1/$filename" > /dev/null
                    then
                        echo "$filename" >> "$temp3"
                    
                    # working directory != repo1
                    else
                        echo "$filename" >> "$temp1"
                    fi

                # if not exist in working directory
                else
                    echo "$filename" >> "$temp3"
                fi
            
            # index != repo1
            else
                echo "$filename" >> "$temp1"
            fi
            
        # if not exist in index
        else
            # if exists in working irectory
            if [ -f "$filename" ]
            then
                echo "$filename" >> "$temp1"
            fi   
        fi
    fi
done

fail=$(cat $temp1 | sort)
copy=$(cat $temp2)
remove=$(cat $temp3)

# remove three temporary files
rm -f $temp1 || exit 1
rm -f $temp2 || exit 1
rm -f $temp3 || exit 1
rm -f $temp || exit 1

# if no files fail
if [ -z "$fail" ]
then
    echo "$branch_name" > $HEAD
    
    for file in $copy
    do
        cp "$repository2/$file" "$index/$file" || exit 1
        cp "$repository2/$file" "$file" || exit 1
    done

    for file in $remove
    do
        rm -f "$index/$file" || exit 1
        rm -f "$file" || exit 1
    done

    echo "Switched to branch '$branch_name'" 

# if there are failed files
else
    echo "$0: error: Your changes to the following files would be overwritten by checkout:"
    echo "$fail"
fi