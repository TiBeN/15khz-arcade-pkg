15khz Arcade Package
====================

This repository provides documentation and a set of scripts to connect 
an analog CRT monitor on Ubuntu and use commons emulators 
(mame, fs-uae...) at real native resolution to make the "pixel perfect"
experience. 

Supported Ubuntu version: **16.04** (Xenial Xerus).

Installation
------------

This repository comes with a Makefile that downloads and builds required
pieces of softwares.

1.  Install needed pre-requisites:

    ```bash
    $ sudo apt-get update
    $ sudo apt-get build-dep linux-image-$(uname -r)
    $ sudo apt-get build-dep mame vice xserver-xorg-video-nouveau
    $ sudo apt-get install fakeroot qt5-default qtbase5-dev \
        qtbase5-dev-tools git unrar libxml2-dev libsdl1.2-dev
    ```

2.  Go to the
    [releases](https://github.com/TiBeN/15khz-arcade-pkg/releases)
    page and download the lastest version matching your Ubuntu version.
    Extract the files from the distribution file then go the extracted
    directory: 

    ```
    $ cd /somewhere/you/whant
    $ wget https://github.com/TiBeN/15khz-arcade-pkg/archive/wily_Ubuntu-4.2.0-38.45_0.170_1.tar.gz
    $ tar xvf wily_Ubuntu-4.2.0-38.45_0.170_1.tar.gz
    $ cd 15khz-arcade-pkg-wily_Ubuntu-4.2.0-38.45_0.170_1/
    ``` 
    (Change the version to the downloaded one from the line above)

    Alternatively you can clone this repository using git but beware
    the master branch may be in a "Work in progress" state and can
    not compile nor work as expected:

    ```bash
    $ git clone https://github.com/TiBeN/15khz-arcade-pkg.git
    ```

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
