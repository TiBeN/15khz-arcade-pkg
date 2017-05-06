15khz Arcade Package
====================

This package provides [instructions](doc/15khz-package-documentation.md),
packages and tools needed to use a TV or arcade monitor — or any other
monitor with an horizontal scan rate at 15khz — on Ubuntu.

The main objective of this package is to use commons emulators, like Mame,
at real native resolution of the emulated system to make the "pixel
perfect" experience. 

Among others things, this package provides a patched Linux kernel and
patched Xorg nouveau drivers that allow the graphic stack to switch to very
low resolutions used by old consoles, arcades machines and computers,
theses resolutions being not allowed by the system by default. A patched Mame
version named `Groovymame` is provided too. This customized Mame version
automatically switchs the resolution of the monitor to the resolution of the
original emulated system. Instructions are provided to reproduce this
behavior with emulators — used by myself — Hatari, FS-UAE and VICE and a
generic tool is provided too to configure others emulators or any other 
software.

This package can be used as a starter to build an arcade cab but is it not
focused on this objective. Different kind of setups are covered like using
the 15khz monitor alone (arcade cab use case), or as a slave of a primary
desktop LCD screen.

The documentation is software oriented. Some tips about hardware are given but 
this part of the setup is up to the user. Resources are available online
for that. 

Tools and packages are not directly provided but a Makefile to build them.

Current Ubuntu version supported: **16.10** (Yakkety Yak).

Installation
------------

1.  Install needed pre-requisites:

    ```bash
    $ sudo apt-get update
    $ sudo apt-get build-dep linux-image-4.8.0-51-generic
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

Configuration
-------------

Please refer to the [documentation](doc/15khz-package-documentation.md) to
configure your system.

Contribution
------------

This project was initially a heap of personal notes to document how to
connect and use a 15khz monitor on Ubuntu and to easily reconfigure my
system after Ubuntu OS and kernel upgrades. I decided to automate things a
little with a Makefile because the entire process of rebuild manually
needed pieces takes time and is annoying to repeat after each system or
kernel upgrade. But what works for my system could not in another — i tried
successfully with two Nvidia and one Radeon card). So any contributions
that can make this project more tested and viable for a wider range of
systems/configurations/setups are welcome. As you can read i am not english
native so contributions is this field are welcome too!
