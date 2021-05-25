# Gits
---

<!-- TABLE OF CONTENTS -->
## Table of Contents

- [# Gits](#-gits)
- [Table of Contents](#table-of-contents)
- [About The Project](#about-the-project)
  - [Aims](#aims)
  - [Built with](#built-with)
- [Usage](#usage)
  - [gits-init](#gits-init)
  - [gits-add _filenames_...](#gits-add-filenames)
  - [gits-commit _[-a]_ -m _message_](#gits-commit--a--m-message)
  - [gits-log](#gits-log)
  - [gits-show _[commit]:filename_](#gits-show-commitfilename)
  - [gits-rm _[--force] [--cached] filenames..._](#gits-rm---force---cached-filenames)
  - [gits-status](#gits-status)
  - [gits-branch _[-d] [branch-name]_](#gits-branch--d-branch-name)
  - [gits-checkout _branch-name_](#gits-checkout-branch-name)
  - [gits-merge (_branch-name_ | _commit_) -m _message_](#gits-merge-branch-name--commit--m-message)
- [Assumptions](#assumptions)
- [License](#license)
- [Contact](#contact)

<!-- ABOUT THE PROJECT -->
## About The Project

**Gits** is a simple git like version control system implementing many git commands, which is contraction of **git** **s**ubset.

Git is a very complex program which has many individual commands. I will implement only a few of the most important commands. There will also be a number of simplifying assumptions ([Assumptions](#assumptions)), which make the task easier.

### Aims

* practice in Shell programming generally
* a clear concrete understanding of Git's core semantics

### Built with

* shell

<!-- USAGE EXAMPLES -->
## Usage

### gits-init

The `gits-init` command creates an empty Gits repository.

`gits-init` creates a directory named .gits, which will be used to store the repository. It produces an error message if this directory already exists.

`gits-init` also creates initial files or directories inside .gits.

For example:

```
$ ls -d .gits
ls: cannot access .gits: No such file or directory
$ ./gits-init
Initialized empty gits repository in .gits
$ ls -d .gits
.gits
$ ./gits-init
gits-init: error: .gits already exists
```

### gits-add _filenames_...
The `gits-add` command adds the contents of one or more files to the "**index**".

Files are added to the repository in a two step process. The first step is adding them to the index.

Files in the index are stored in the .gits sub-directory.

Only ordinary files in the current directory can be added. The filenames must start with an alphanumeric character ([a-zA-Z0-9]) and will only contain alpha-numeric characters, plus '.', '-' and '_' characters.

### gits-commit _[-a]_ -m _message_
The `gits-commit` command saves a copy of all files in the index to the repository.

A message describing the commit must be included as part of the commit command.

Gits commits are numbered sequentially: they are not hashes, like Git.

We assume the commit message is ASCII, does not contain new-line characters, and does not start with a '-' character.

`gits-commit` can have a `-a` option, which causes all files already in the index to have their contents from the current directory added to the index before the commit.

### gits-log
The `gits-log` command prints a line for every commit made to the repository: each line should contain the commit number, and the commit message.

### gits-show _[commit]:filename_
The `gits-show` prints the contents of the specified _filename_ as of the specified _commit_. If _commit_ is omitted, the contents of the file in the index should be printed.

We assume the commit if specified will be a non-negative integer.

For example: 
```
$ ./gits-init
Initialized empty gits repository in .gits
$ echo line 1 > a
$ echo hello world >b
$ ./gits-add a b
$ ./gits-commit -m 'first commit'
Committed as commit 0
$ echo  line 2 >>a
$ ./gits-add a
$ ./gits-commit -m 'second commit'
Committed as commit 1
$ ./gits-log
1 second commit
0 first commit
$ echo line 3 >>a
$ ./gits-add a
echo line 4 >>a
$ ./gits-show 0:a
line 1
$ ./gits-show 1:a
line 1
line 2
$ ./gits-show :a
line 1
line 2
line 3
$ cat a
line 1
line 2
line 3
line 4
$ ./gits-show 0:b
hello world
$ ./gits-show 1:b
hello world
```

### gits-rm _[--force] [--cached] filenames..._
`gits-rm` removes a file from the index, or from the current directory and the index.

If the `--cached` option is specified, the file is removed only from the index, and not from the current directory.

`gits-rm`, like `git rm`, stops the user accidentally losing work, and gives an error message instead if the removal would cause the user to lose work.

The `--force` option overrides this, and will carry out the removal even if the user will lose work.

### gits-status
`gits-status` shows the status of files in the current directory, the index, and the repository.
```
$ ./gits-init
Initialized empty gits repository in .gits
$ touch a b c d e f g h
$ ./gits-add a b c d e f
$ ./gits-commit -m 'first commit'
Committed as commit 0
$ echo hello >a
$ echo hello >b
$ echo hello >c
$ ./gits-add a b
$ echo world >a
$ rm d
$ ./gits-rm e
$ ./gits-add g
$ ./gits-status
a - file changed, different changes staged for commit
b - file changed, changes staged for commit
c - file changed, changes not staged for commit
d - file deleted
e - deleted
f - same as repo
g - added to index
gits-add - untracked
gits-branch - untracked
gits-checkout - untracked
gits-commit - untracked
gits-init - untracked
gits-log - untracked
gits-merge - untracked
gits-rm - untracked
gits-show - untracked
gits-status - untracked
gits.py - untracked
h - untracked
```

### gits-branch _[-d] [branch-name]_
`gits-branch` either creates a branch, deletes a branch, or lists current branch names.

### gits-checkout _branch-name_
`gits-checkout` switches branches.

Unlike Git, we can not specify a commit or a file: we can only specify a branch. 

### gits-merge (_branch-name_ | _commit_) -m _message_
`gits-merge` adds the changes that have been made to the specified branch or commit to the index, and commits them.

For example:

```
$ ./gits-init
Initialized empty gits repository in .gits
$ seq 1 7 >7.txt
$ ./gits-add 7.txt
$ ./gits-commit -m commit-1
Committed as commit 0
$ ./gits-branch b1
$ ./gits-checkout b1
Switched to branch 'b1'
$ perl -pi -e 's/2/42/' 7.txt
$ cat 7.txt
1
42
3
4
5
6
7
$ ./gits-commit -a -m commit-2
Committed as commit 1
$ ./gits-checkout master
Switched to branch 'master'
$ cat 7.txt
1
2
3
4
5
6
7
$ ./gits-merge b1 -m merge-message
Fast-forward: no commit created
$ cat 7.txt
1
42
3
4
5
6
7
```

If a file has been changed in both branches `gits-merge` produces an error message.

If a file has been changed in both branches `git` examines which lines have been changed and combines the changes if possible. Gits doe not do this, for example:

```
$ ./gits-init
Initialized empty gits repository in .gits
$ seq 1 7 >7.txt
$ ./gits-add 7.txt
$ ./gits-commit -m commit-1
Committed as commit 0
$ ./gits-branch b1
$ ./gits-checkout b1
Switched to branch 'b1'
$ perl -pi -e 's/2/42/' 7.txt
$ cat 7.txt
1
42
3
4
5
6
7
$ ./gits-commit -a -m commit-2
Committed as commit 1
$ ./gits-checkout master
Switched to branch 'master'
$ cat 7.txt
1
2
3
4
5
6
7
$ perl -pi -e 's/5/24/' 7.txt
$ cat 7.txt
1
2
3
4
24
6
7
$ ./gits-commit -a -m commit-3
Committed as commit 2
$ ./gits-merge b1 -m merge-message
gits-merge: error: can not merge
$ cat 7.txt
1
2
3
4
24
6
7
```

<!-- Assumptions -->
## Assumptions

We make a few assumptions as follows.

Gits commands are always run in the same directory as the repository, and only files from that directory are added to the repository.

The directory in which gits commands are run will not contain sub-directories apart from .gits.

Where a branch name is expected a string will start with an alphanumeric character ([a-zA-Z0-9]), and only contain alphanumeric characters plus '-' and '_'. In addition a branch name will not be entirely numeric. This allows branch names to be distinguished from commits when merging.

Where a filenames is expected a string will start with an alphanumeric character ([a-zA-Z0-9]) and only contain alpha-numeric characters, plus '.', '-' and '_' characters.

Where a commit number is expected a string will be a non-negative integer with no leading zeros. It will not contain white space or any other characters except digits.

Gits-add, gits-show, and gits-rm will be given just a filename, not pathname with slashes.

Only one instance of any gits command is running at any time.

Arguments will be in the position and order shown in the usage message. Other orders and positions will not be considered.

<!-- LICENSE -->
## License

Distributed under the MIT License. See [`LICENSE`](/LICENSE) for more information.

<!-- CONTACT -->
## Contact

Zhuolin Li - lzlscx@gmail.com

Project Link: [https://github.com/ZL-Li/Gits](https://github.com/ZL-Li/Gits)