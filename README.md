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

The gits-init command creates an empty Gits repository.  
gits-init creates a directory named .gits, which will be used to store the repository. It produces an error message if this directory already exists.  
gits-init also creates initial files or directories inside .gits.  
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









<!-- LICENSE -->
## License

Distributed under the MIT License. See [`LICENSE`](/LICENSE) for more information.

<!-- CONTACT -->
## Contact

Zhuolin Li - lzlscx@gmail.com

Project Link: [https://github.com/ZL-Li/Gits](https://github.com/ZL-Li/Gits)