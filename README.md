15khz Arcade Package
====================

**WARNING:** Heavy refactorings are planned on the master branch, it may
not works as expected or the documentation can not be accurate has i'm in
the process of improving it. Please use 
[releases](https://github.com/TiBeN/15khz-arcade-pkg/releases) or 
[tags](https://github.com/TiBeN/15khz-arcade-pkg/tags) version instead.

This repository provides documentation and a set of scripts to connect 
an analog CRT monitor on Ubuntu and use commons emulators 
(mame, fs-uae...) at real native resolution to make the "pixel perfect"
experience. 

Supported Ubuntu version: **15.10** (Wily Werewolf).

Installation
------------

This repository comes with a Makefile that downloads and builds required
pieces of softwares.

1.  Install needed pre-requisites:

    ```bash
    $ sudo apt-get build-dep linux-image-$(uname -r)
    $ sudo apt-get build-dep mame vice
    $ sudo apt-get install fakeroot qt5-default qtbase5-dev \
        qtbase5-dev-tools git unrar libxml2-dev libsdl1.2-dev
    ```

2.  Clone this repo:

    ```bash
    $ git clone git@github.com:TiBeN/15khz-arcade-pkg.git
    ```
    or 
    ```
    git clone https://github.com/TiBeN/15khz-arcade-pkg.git
    ```
    (which avoids unnecessary public key validation)

3.  Start the build and install:

    ```bash
    $ make
    $ sudo make install
    ```

Usage
-----

This package comes with a set of wrapper scripts for some emulators and
others tools. For example:

-   To launch the provided mame: 

    ```bash
    $ 15khz-mame <mame-args>
    ```

-   To change the resolution of the screen and launch a program
    
    ```bash
    $ 15khz-change-res-exec 320 24O 50 <program>
    ```

More information
----------------

Please refer to the [documentation](doc/15khz-package-documentation.md) 
to know what is exactly built and installed and to setup properly your 
system.
