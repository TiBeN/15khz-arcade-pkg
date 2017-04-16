15khz Arcade Package
====================

This repository provides 
[documentation](doc/15khz-package-documentation.md) and a set of 
scripts to connect an analog CRT monitor on Ubuntu and use commons 
emulators (mame, fs-uae...) at real native resolution to make the 
"pixel perfect" experience. 

Supported Ubuntu version: **16.10** (Yakkety Yak).

Installation
------------

This repository comes with a Makefile that downloads and builds required
pieces of softwares.

1.  Install needed pre-requisites:

    ```bash
    $ sudo apt-get update
    $ sudo apt-get build-dep linux-image-4.8.0-45.48-generic
    $ sudo apt-get build-dep mame vice xserver-xorg-video-nouveau
    $ sudo apt-get install fakeroot qt5-default qtbase5-dev \
        qtbase5-dev-tools git unrar libxml2-dev libsdl1.2-dev cmake \
        libarchive13 libavcodec57 libavformat57 libavutil55 libc6 libexpat1 \
        libfontconfig1 libfreetype6 libgcc1 libgl1-mesa-glx libjpeg8 \
        libopenal1 libsfml-graphics2.4 libsfml-network2.4 libsfml-system2.4 \
        libsfml-window2.4 libstdc++6 libswresample2 libswscale4 libx11-6 \
        libxinerama1 zlib1g libarchive-dev libavcodec-dev libavformat-dev \
        libavresample-dev libavutil-dev libfontconfig-dev libfreetype6-dev \
        libglu-dev libjpeg-turbo8-dev libopenal-dev libsfml-dev \
        libswscale-dev libxinerama-dev
    ```

2.  Go to the
    [releases](https://github.com/TiBeN/15khz-arcade-pkg/releases)
    page and download the lastest version matching your Ubuntu version.
    Extract the files from the distribution file then go the extracted
    directory: 

    ```
    $ cd /somewhere/you/whant
    $ wget https://github.com/TiBeN/15khz-arcade-pkg/archive/<version>.tar.gz
    $ tar xvf <version>.tar.gz
    $ cd 15khz-arcade-pkg-<version>/
    ``` 
    (Change the \<version\> to the downloaded one from the lines above)

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
    $ 15khz-change-res-exec 320 240 50 <program>
    ```

More information
----------------

Please refer to the [documentation](doc/15khz-package-documentation.md) 
to know what is exactly built and installed and to setup properly your 
system.
