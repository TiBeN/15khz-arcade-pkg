15khz Arcade Package
====================

This repository provides guidelines to connect an old CRT monitor (TV or
Arcade videogames monitor running at 15Khz horizontal scan frequencies)
to the VGA output of an Nvidia card using Ubuntu while keeping your
primary screen connected.

One of the aims is to play emulated retro arcade/console/computer games
at real low resolutions on this monitor using emulators like MAME.

Doing this is actually harder than it sounds because:

-   Linux kernel disallows 15Khz horizontal scan frequencies which are
    used by theses old monitors — 31Khz is now the norm
-   Nvidia Drivers disallow resolutions lower than 320x200
-   This setup requires not so obvious Xorg configuration
-   Using 15khz monitors require the use of custom
    [modelines](https://en.wikipedia.org/wiki/XFree86_Modeline)
    unhandled by Xorg nor Mame.
-   The Xorg `ZaphodHead` mode used to achieve the setup of two separate
    X screens at the same time triggers various nasty SDL/Mesa/OpenGL
    bugs and behaviors with Mame.

This project helps to resolve theses issues by providing instructions
and a `Makefile` which help generating:

-   A patched Linux kernel wich allows 15Khz modelines as a deb package
-   Patched nouveau drivers allowing low resolutions as a deb package
-   Patched `nouveau_dri.so` lib from libgl-mesa-dri package which
    resolves a bug related to ZaphodHeads mode
-   Patched Mame binary using GroovyMame patch allowing Mame to generate
    good 15khz compatible modelines on the fly
-   A Groovymame bash launcher which sets custom SDL env vars resolving
    some weird SDL related behaviors, sets the \$DISPLAY var on the
    right screen and tells the linker to use the patched nouveau.dri.so
    library.

The generation of theses assets can be done automatically using `make`
or manually by following the provided instructions.

Motivation
----------

The main purpose of this repository is to keep track and automate steps
needed to achieve this goal. Second motivation is to share hoping that
it might help despite it fits my hardware/OS specifically. If you have
suggestions or knowledges to make it more generic feel free to let me
know.

Assets versions
---------------

-   **Ubuntu**: Vidid
-   **Linux kernel**: Ubuntu-3.19.0-25.26
-   **Groovymame**: 0.164

Hardware setup
--------------

The connexion between the PC and the TV monitor can be done using a
custom homemade VGA / Scart Adapter as shown here
<http://www.geocities.ws/podernixie/htpc/cables-en.html#vgascart> or
using an UMSA Ultimate SCART Adapter available here:
<http://arcadeforge.net/UMSA/UMSA-Ultimate-SCART-Adapter::57.html>

Because my monitor is a Schneider CTM644 (provided with old CPC464
Computer), i use a Scart / DIN adapter bought online at `CoolNovelties`
here:
<http://coolnovelties.co.uk/coolnovelties/amstrad-video-cables/26-amstrad-ctm-644-monitor-rgb-scart-adapter.html>

### Vertical under/overscan adjustment

Vertical overscan/underscan can't be adjusted using software modelines.
It is often possible to adjust it inside some kind of `service menu` or
directly on the PCB of the TV.

On my CTM 644 monitor it can be adjusted by turning the `VR406` Variable
Resistor (See the [Schneider CTM640 Service
Manual](http://www.cpcwiki.eu/imgs/6/6f/Schneider_CTM640_Service_Manual_%28German_and_English%29.pdf)
for a view of the monitor main PCB).

Assets generation, installation and configuration
-------------------------------------------------

The following explains how to use the provided `Makefile` to automate
the generation and installation of the assets.

1.  Install the following packages using APT:

    ``` {.sourceCode .bash}
    $ apt-get install build-essential kernel-package debconf-utils dpkg-dev \
    debhelper ncurses-dev fakeroot zlib1g-dev \
    libqt4-dev libsdl2-dev libsdl2-ttf-dev libfontconfig1-dev git
    ```

2.  `git clone` this repository

    ``` {.sourceCode .bash}
    $ git clone git@github.com:TiBeN/15khz-arcade-pkg.git
    ```

3.  Go the source dir of the project and launch the generation of the
    assets:

    ``` {.sourceCode .bash}
    $ cd ./15khz-arcade-package
    $ make
    ```

    Be warned that this step will take hours because it triggers the
    compilation of the Linux Kernel and the MAME emulator among others.

Once done, all assets are available inside the `build` directory.

4.  You can install the assets automatically by doing:

    ``` {.sourceCode .bash}
    $ sudo make install
    ```

If you prefer you can install them manually — i suggest to read the
`Detailled instruction for manual setup` chapter to know exactly what to
do.

5.  Follow the `Bypassing EDID detection by KMS` and the `Xorg setup`
    steps from the manual setup instructions because these cannot be
    automated

6.  Reboot your computer to the newly installed patched kernel. To be
    sure to boot on the new kernel, hold `<shift>` during boot to make
    appear the Grub boot menu and select the good kernel which name
    contains `patched-15khz`.

The assets can be uninstalled by doing `sudo make uninstall`. While
running the patched kernel can't be automatically removed safely. First,
reboot to another kernel, then once rebooted, do

``` {.sourceCode .bash}
sudo apt-get remove linux-image-<version>-patched15khz linux-headers-<version>-patched15khz
```

Usage
-----

The 15Khz screen is made available as a separate X screen numbered :0.1.
So to launch a program on this screen, prefix the command-line with
`DISPLAY=:0.1`. Example:

``` {.sourceCode .bash}
$ DISPLAY=:0.1 xrandr
```

To launch groovymame64:

    $ gm-15khz sf2

Note the absence of the prefix DISPLAY=:0.1 . It is useless because it
is already set inside the `gm-15khz` bash launcher. `gm-15khz` is only a
wrapper of the `groovymame64` binary. All command line arguments
following `gm-15khz` invocation are passed to the underlying
`groovymame64` process.

Detailled instructions for manual setup
---------------------------------------

This chapter describes step by step how to connects your 15khz monitor
on your computer having an Nvidia card using Ubuntu.

### Allowing the Linux Kernel for 15khz modelines.

Linux kernels disallows 15khz modelines to preserve monitors healths.
Patchs for the kernel are made for bypassing this security. Here are the
steps to follow to patch a kernel, compil and boot it.

1.  Know the version of the installed Kernel:

    ``` {.sourceCode .bash}
    $ uname -r
    ```

2.  Get the patch for the kernel matching the actual version of the
    Kernel, if available, at this url:
    <http://forum.arcadecontrols.com/index.php/topic,107620.280.html>.
    New versions of the patch are frequently posted on this topic as new
    versions of the kernel are available.

3.  Grab the linux source. Here's two possibilities. If the kernel version
    of the system matches the patch found in step two, the package manager
    of the system can be used:

    ``` {.soureCode .bash}
    $ sudo apt-get install linux-source
    $ mkdir ~/kernel-15khz      # This is our working dir. It can be anywhere
    $ cd ~/kernel-15khz         
    $ tar xvf /usr/src/linux-source-<version>.tar.bz2
    $ mv linux-source-<version> linux-source    
    ```

    Otherwise, a specific version can be retrieved from the official
    Ubuntu GIT repository — this method is used by the Makefile to freeze 
    the version:

    ``` {.sourceCode .bash}
    $ mkdir ~/kernel-15khz      # This is our working dir. It can be anything
    $ cd ~/kernel-15khz
    $ git clone git://kernel.ubuntu.com/ubuntu/ubuntu-<distrib-codename>.git \
        ./linux-source
    ```

    <distrib-codename> must be replaced by the first name of the ubuntu version
    eg: `vivid` for Ubuntu 15.04 Vivit Vervet. Now, the source tree needs to be
    set at the git tag to the desired kernel version — the versions can be 
    listed using `git tag`:
    
    ``` {.sourceCode .bash}
    $ cd ~/kernel-15khz/linux-source
    $ git tag               # List the available version of the repository
    $ git checkout <tag>    # Set the source tree at the specified version
    ```
    
4.  Patch the kernel sources:

    ``` bash 
    $ cd ~/kernel-15khz
    $ unzip /path/to/download/kernel-patch-<linux-version>.zip
    $ cd linux-source
    $ patch -p1 < ../patch-<linux-version>/ati9200_pllfix-<linux-version>.diff
    $ patch -p1 < ../patch-<linux-version>/avga3000-<linux-version>.diff
    $ patch -p1 < ../patch-<linux-version>/linux-<linux-version>.diff
    ```

    If one of theses steps fail, consider using an older kernel minor version 
    — the major must be the same.

5.  Install some required packages for the compilation:

    ``` bash
    $ apt-get install build-essential kernel-package debconf-utils dpkg-dev \
        debhelper ncurses-dev fakeroot zlib1g-dev
    ```

6.  Launch the compilation and deb package generation of the kernel:

    ``` bash
    $ cd ~/kernel-15khz/linux-source
    $ cp -vi /boot/config-`uname -r` .config
    $ make oldconfig
    $ KERN_DIR=~/kernel-15khz/linux-source make-kpkg clean
    $ KERN_DIR=~/kernel-15khz/linux-source fakeroot make-kpkg \
        --initrd \
        --append-to-version "-patched15khz" \
        kernel-image kernel-headers
    ```
    
    Depend of the power of your cpus this can take some hours. Some versions
    of the kernel asked me some question at the beginning of the process. I advice 
    to wait one or two minutes before going AFK.

7.  Deploy the generated packages:

    ```bash
    $ cd ~/kernel-15khz
    $ sudo dpkg -i linux-image-<linux-version>-patched15khz_<linux-version>-patched15khz-10.00.Custom_amd64.deb
    $ sudo dpkg -i linux-headers-<linux-version>-patched15khz_<linux-version>-patched15khz-10.00.Custom_amd64.deb
    ```

8.  Reboot on the new patched kernel. Hold <shift> key at the start 
    of the boot to make appear the GRUB boot menu. Select 
    *Advanced options for Ubuntu* -> *Ubuntu, with <linux-version>-patched15kz*


### Bypassing EDID detection by KMS

Mosts VGA/DVI/HDMI screens communicates `EDID` data to the kernel — and
X server ? — at initialisation. Theses metadatas contains informations
about the screen like the min/max resolutions, supported frequencies
etc. The old CRT screen doesn't communicate theses informations. This
results the kernel to ignore the screen at boot. It is possible to tell
the kernel to bypass this detection and force the state as connected.
This is done by adding to parameters to the kernel at boot:

1.  Edit the grub configuration file `/etc/default/grub` and add
    `vga=0x311 video=VGA-1:640x480ec` to the kernel options
    `GRUB_CMDLINE_LINUX_DEFAULT`.

2.  Tell to take in account theses changes:

    ``` {.sourceCode .bash}
    $ sudo update-grub
    ```

### Allowing the Nouveau Nvidia driver to switch to low resolutions modelines

Most of Linux drivers doesn't allow the setting of very low resolutions
mode like theses used for old console and arcade systems, probably for
security reasons. About Nvidia, it is not possible to use the officials
drivers because they are distributed as binary blobs and can't be
patched. Having tested the official drivers, it resulted of stranges
white lignes on black screen artifacts on low resolutions. On the other
hand, The `nouveau` open-source Nvidia drivers can be patched to allow
this. Next are the instructions to do this on Ubuntu.

1.  Fetch the sources from APT:

    ``` {.sourceCode .bash}
    $ mkdir /some/path/to/store/nouveau-sources
    $ cd /some/path/to/store/nouveau-sources
    $ apt-get source xserver-xorg-video-nouveau
    ```

2.  Edit the following file
    `xserver-xorg-video-nouveau-<version>/src/drmmode_display.c` and
    apply theses changes: 

    ```c
    - xf86CrtcSetSizeRange(pScrn, 320, 200,
    -    drmmode->mode_res->max_width,
    -    drmmode->mode_res->max_height);
    + xf86CrtcSetSizeRange(pScrn, 160, 100,
    +   drmmode->mode_res->max_width,
    +   drmmode->mode_res->max_height);
    ```

3.  Compile the patched sources and create the deb package:

    ``` {.sourceCode .bash}
    cd xserver-xorg-video-nouveau-<version>
    dpkg-buildpackage -us -uc -nc
    ```

4.  Uninstall the official package and install the previouly built:

    ``` {.sourceCode .bash}
    sudo apt-get purge xserver-xorg-video-nouveau
    sudo dpkg -i xserver-xorg-video-nouveau_<version>.deb
    ```

5.  Reboot the system

### Configuring Xorg

`Separate X Screen` aka `Zaphodheads` mode is the only configuration
layout supported by this guide. Others layout like `Dual screen Xrandr`
or `Xinerama` have been tested but not working as expected. The
instructions to configure the X server in Zaphodhead for nouveau drivers
is well explained on the official `nouveau drivers` website at
<http://nouveau.freedesktop.org/wiki/Randr12/>.

It is recommended to delete the file `~/.config/monitors.xml` because it
seems to override Xorg options and makes debugging harder.

The file `etc/xorg.conf` available in the repository of the project is a
working `xorg.conf` example. Custom 15khz 648x480 modeline is defined
and set as default mode on the `Monitor1` attached to `Screen1`. This
ensures the CRT screen to be set with a compatible 15Khz modeline when
idle.

### Emulating retro systems at native resolutions with Groovymame

Groovymame is a patched version of Mame which generates and sets
on-the-fly accurates 15Khz modelines to aproximatelly fit the native
resolution of the emulated game.

#### Compile Groovymame from the sources.

Groovymame is distributed as a diff patch to apply to official Mame
sources. The following steps explain how to compile Groovymame on
Ubuntu.

1.  Grab the last version of the Mame sources at this url:
    <http://www.mamedev.org/release.html>

2.  Unzip the downloaded sources files and go to the unzipped sources
    path:

3.  Grab the Groovymame diff file and Hi score diff file (mandatory)
    that matches the official Mame sources previously downloaded at this
    url:
    <https://54c0ab1f0b10beedc11517491db5e9770a1c66c6.googledrive.com/host/0B5iMjDor3P__aEFpcVNkVW5jbEE/>

4.  Apply the Hi score diff file:

    ``` {.sourceCode .bash}
    patch -p0 --binary < path/to/hi_<mame_version>.diff
    ```

5.  Apply the Groovymame diff file:

    ``` {.sourceCode .bash}
    patch -p0 --binary < path/to/<mame_version>_groovymame_<groovymame_version>.diff
    ```

6.  Install the required packages for the compilation of Groovymame

    ``` {.sourceCode .bash}
    sudo apt-get install build-essential libqt4-dev libsdl2-dev libsdl2-ttf-dev libfontconfig1-dev
    ```

7.  Apply the `Changeres fix` as explained in the next chapter

8.  Start the compilation by launching `make`.

#### Groovymame usage

Groovymame works exactly like official Mame. To work properly with our
setup, some environment variables must be set:

``` {.sourceCode .bash}
LIBGL_DRIVERS_PATH=$rootPath/../lib/path-to-mesa-lib \
    SDL_JOYSTICK_ALLOW_BACKGROUND_EVENTS=1 \
    SDL_VIDEO_X11_XRANDR=0 \
    SDL_VIDEO_X11_XVIDMODE=0 \
    DISPLAY=:0.1 \
    ./groovymame sms sonic
```

The environment variables are explained below:

-   **LIBGL\_DRIVERS\_PATH=\$rootPath/../lib/path-to-mesa-lib**: Defines
    a custom path for library to search drivers libs. This is used to
    force Mesa to use our patched version the lib `nouveau_dri.so` (see
    the `Groovymame segfault changeres bug` chapter for more
    information.

-   **SDL\_JOYSTICK\_ALLOW\_BACKGROUND\_EVENTS=1**: Makes SDL to capture
    Joystick events when the application is in background which is the
    case when launching on the second available screen using
    ZaphodHeads.

-   **SDL\_VIDEO\_X11\_XRANDR=0** and **SDL\_VIDEO\_X11\_XVIDMODE=0**:
    This resolves a nasty bug which makesSDL to executes Mame on the
    wrong (first primary) screen after a `switchres` event during the
    runtime. This bug affects emulated systems which triggers
    resolutions changes like `Sega Genesis` or `Sony Playstation`. The
    action of theses SDL environnment variables is pretty hard
    understand but they fix it.

-   **DISPLAY=:0.1**: This tells Xorg to execute the program on the
    Screen1 (CRT Screen)

The `gm-15khz` bash launcher provided when installing the assets using
the Makefile is basically a wrapper of GroovyMame which sets theses
environment variables.

To know more about Mame usage, refer to the
[documentation](https://github.com/mamedev/mame/blob/master/docs/config.txt).

#### Groovymame segfault changeres bug

Using nouveau driver in ZaphodHead mode, a `segfault` bug is triggered
when a resolution switch occurs during the emulation of a system like
`Sega Genesis` or `Sony Playstation`.

This bug as been discussed with the Groovymame author `Calamity` in a
post on the ArcadeControls forum:
<http://forum.arcadecontrols.com/index.php/topic,145757.0.html>

The bug is caused by the Galium nouveau DRI of the OpenGL rendering MESA
library and is known by the developer team. This library is provided by
the Debian package `libgl1-mesa-dri`.

A patch is available here:
<http://cgit.freedesktop.org/mesa/mesa/commit/?id=a98600b0ebdfc8481c168aae6c5670071e22fc29>

Here are the steps to fix this:

-   Fetchs the debian source package of `libgl1-mesa-dri`

-   Apply the patch available at the link above

-   Launch the compilation and deb package building:

    ``` {.sourceCode .bash}
    $ cd /path/to/pkg
    $ dpkg-buildpackage -us -uc -nc
    ```

-   Search for the `nouveau_dri.c` usually available at:

    ``` {.sourceCode .bash}
    /path/to/pkg/build/dri/x86_64-linux-gnu/gallium/nouveau_dri.so` and copy it somewhere.
    ```

-   Launch GroovyMame using this environment var to force Mesa to use
    the patch library:

    ``` {.sourceCode .bash}
    LIBGL_DRIVERS_PATH=$rootPath/../lib/folder-containing-lib
    ```


