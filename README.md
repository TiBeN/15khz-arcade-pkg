15khz Arcade Package
====================

**WARNING:** Heavy refactorings are planned on the master branch, it may 
not work as expected. Please use 
[releases](https://github.com/TiBeN/15khz-arcade-pkg/releases) or 
[tags](https://github.com/TiBeN/15khz-arcade-pkg/tags) version instead.

This repository provides guidelines to connect an old CRT monitor (TV or
Arcade videogames monitor running at 15Khz horizontal scan frequencies)
to the VGA output of an Nvidia card using Ubuntu while keeping your
primary screen connected.

The goal is to play emulated retro arcade/console/computer games
at real low resolutions on this monitor using emulators like MAME.

Doing this is actually harder than it sounds because:

-   For some graphics card, and to enables some features, Linux kernel 
    must be patched.
-   Nvidia Drivers, both proprietary and open-source `nouveau`, 
    disallow resolutions lower than 320x200
-   This setup requires not so obvious Xorg configuration
-   Using 15khz monitors require the use of custom
    [modelines](https://en.wikipedia.org/wiki/XFree86_Modeline)
    which must be setup manually — There are tools for that.

The following guide provides instructions for patching and installing a 
linux kernel, nouveau drivers and groovymame, and configuring your xorg
server. 

This repository contains also a `makefile` which automate the generation 
and the installation of the required parts (patched kernel, nouveau 
drivers, groovymame) and some useful scripts (emulators launchers, 
15khz resolution switchers etc.)

Note: If your goal is to dedicate a machine for this purpose (into a 
physical arcade cabinet for example) you should considere 
[GroovyArcade](https://code.google.com/archive/p/groovyarcade/), a great 
dedicated ArchLinux distribution which works more or less out of the 
box. `15khz-arcade-pkg` aims to basically do the same thing but manually, 
on Ubuntu, and is really less exaustive.

Motivation
----------

The main purpose of this repository is to keep track and automate steps
needed to achieve this goal. Second motivation is to share, hoping that
it might help despite it fits my hardware/OS specifically. If you have
suggestions or knowledges to make it more generic feel free to let me
know.

Assets versions
---------------

-   **Ubuntu**: Wily
-   **Linux kernel**: Ubuntu-4.2.0-22.27
-   **Groovymame**: 0.170

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
    $ sudo apt-get build-dep linux-image-$(uname -r) mame \
        xserver-xorg-video-nouveau
    $ sudo apt-get install fakeroot qt5-default qtbase5-dev \
        qtbase5-dev-tools git unrar libxml2-dev
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
    The `-j<number-of-cpu+1>` option can be used to paralelise the build 
    and speed up things a little.

Once done, all assets are available inside the `build` directory.

4.  You can install the assets automatically by doing:

    ``` {.sourceCode .bash}
    $ sudo make install
    ```

    If you prefer you can install them manually — i suggest to read 
    the `Detailled instruction for manual setup` chapter to know 
    exactly what to do.

5.  Follow the `Bypassing EDID detection by KMS` and the `Xorg setup`
    steps from the manual setup instructions because these cannot be
    automated

6.  Reboot your computer to the newly installed patched kernel. To be
    sure to boot on the new kernel, hold `<shift>` during boot to make
    appear the Grub boot menu and select the good kernel. Once done, you
    check if you have booted on the good kernel by type `uname -a`. It 
    should contain a suffix `patched15khz`.

The assets can be uninstalled by doing `sudo make uninstall`. While
running the patched kernel can't be automatically removed safely. First,
reboot to another kernel, then once rebooted, do

``` {.sourceCode .bash}
sudo apt-get remove linux-image-<version>-patched15khz \
    linux-headers-<version>-patched15khz
```

Usage
-----

The 15Khz screen is made available as a separate X screen numbered `:0.1` — 
On Ubuntu Wily with Gnome 3 and maybe others, the screen number starts at
:1, so in this case the screen number is `:1.1`.
So to launch a program on this screen, prefix the command-line with
`DISPLAY=:0.1`. Example:

``` {.sourceCode .bash}
$ DISPLAY=:0.1 xrandr
```

### Groovymame

To launch groovymame64 :

```
$ DISPLAY=:0.1 15khz-zaphod-mame sf2
```

### Change screen resolution and execute a command

A script is provided with this package which allows to change the
resolution on the fly, execute a program, then revert back to original
resolution when program quits:

```
$ DISPLAY=:0.1 OUTPUT15KHZ=VGA1 15khz-change-res-exec 320 240 50 firefox
```

This command sets the resolution of the screen connected to the 
output `VGA1` at 320x240 with a refresh rate of 50hz then launch 
firefox. Okay this is pretty useless, but it can be more usefull with 
an emulator.

Internally, the 15khz modeline is computed on the fly by using the 
`switchres` utility made by `Calamity`, the author of the Groovymame patch.
Like others assets of this package, `switchres` is automatically 
downloaded and compiled using the `Makefile`.

The environment variable `OUTPUT15KHZ` defines the xrandr output 
where the CRT screen is connected. If used often, i recommand you
to put this variable in your `~/.bashrc` or `~/.profile` file:

```bash
export OUTPUT15KHZ="VGA1"
```

Detailled instructions for manual setup
---------------------------------------

This chapter describes step by step how to connects your 15khz monitor
on your computer having an Nvidia card using Ubuntu.

### Patching the kernel

As i am not the author of the patchs — thanks to arcadecontrol forum — it 
is not very clear to me what is the aim of the patch but i presume 
the following:

-   The patch allows 15khz modelines in `KMS` mode, which is the display 
    engine used by the kernel at boot (splashscreen) before Xorg is 
    launched
-   The patch provide diff for ArcadeVGA and ATI cards. I think without
    theses thoses cards are not allowed to handle low resolutions or 15khz
    modelines.
-   **The patch is not required for NVIDIA cards**, at least for mine. Only
    patched nouveau drivers — as explained bellow — are required if the 
    only goal is to play emulators and if you don't care about the 
    booting phase.
-   Patching the Kernel > 3.19, KMS feature doesn't seems to work.

1.  Know the version of the installed Kernel:

    ``` {.sourceCode .bash}
    $ uname -r
    ```

2.  Get the patch for the kernel matching the actual version of the
    Kernel, if available, at this url:
    <http://forum.arcadecontrols.com/index.php/topic,107620.280.html>.
    New versions of the patch are frequently posted on this topic as new
    versions of the kernel are available.
    Update: Since kernel v3.19 no updates seems to be done on this forum.
    Until now, the patchs seems to work with 4.2.0 kernel. If is not the 
    case anymore, the following github repository hosts patched kernel 
    sources which seems to be up to date and synchronised with upstream 
    kernel sources. 
    To get the patchs, select the git tag which match the kernel version then 
    check the commits done by the owner of the repo — `philenotfound`. He
    names the commits 'avga3000-<version>.diff', 
    'ati9200_pllfix-<version>.diff' and 'linux-<version>'.diff. 
    Append `.patch` to the github url of theses commits to obtain a patch file 
    (it's a github feature).

3.  Follow the official Ubuntu tutorial here:
    <https://wiki.ubuntu.com/Kernel/BuildYourOwnKernel>. At the 
    `Modifying the configuration` step, skip it but apply the patchs:

    ``` bash 
    $ cd ~/path-to-kernel-sources
    $ unzip /path/to/download/kernel-patch-<linux-version>.zip
    $ patch -p1 < patch-<linux-version>/ati9200_pllfix-<linux-version>.diff
    $ patch -p1 < patch-<linux-version>/avga3000-<linux-version>.diff
    $ patch -p1 < patch-<linux-version>/linux-<linux-version>.diff
    ```
    
    Follow the tuto advice to change the debian.master/changelog file by
    adding the suffix `+patched15khz`.

    If the compilation fails due to an ABI error or something like this, 
    repeat the compilation command line by adding `skipabi=true`:

    ```bash
    $ skipabi=true fakeroot debian/rules binary-headers binary-generic
    ```
    
### Bypassing EDID detection by KMS

Mosts VGA/DVI/HDMI screens communicates `EDID` data to the kernel — and
X server ? — at initialisation. Theses metadatas contains informations
about the screen like the min/max resolutions, supported frequencies
etc. The old CRT screen doesn't communicate theses informations. This
results the kernel to ignore the screen at boot. It is possible to tell
the kernel to bypass this detection and force the state as connected.
This is done by adding to parameters to the kernel at boot:

1.  Edit the grub configuration file `/etc/default/grub` and add
    `vga=0x311 video=<DEVICE-NAME>:640x480e` to the kernel options
    `GRUB_CMDLINE_LINUX_DEFAULT`.

    Replace <DEVICE-NAME> by the name of the output where the CRT screen is
    connected (common names: VGA-1, DVI-I-1). Asks your `xrandr` to know 
    the name of your available output devices.

2.  Tell to take in account theses changes:

    ``` {.sourceCode .bash}
    $ sudo update-grub
    ```

### Allowing the Nouveau Nvidia driver to use low resolutions modelines

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
layout provided with this guide for now. It is planned to present here 
others alternatives. The instructions to configure the X server in 
Zaphodhead for nouveau drivers is well explained on the official 
`nouveau drivers` website at <http://nouveau.freedesktop.org/wiki/Randr12/>.

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
    sudo apt-get build-dep mame
    ```

7.  Start the compilation by launching `make`.

#### Groovymame usage

Groovymame works exactly like official Mame. To work properly with our
setup, some environment variables must be set:

``` {.sourceCode .bash}
SDL_JOYSTICK_ALLOW_BACKGROUND_EVENTS=1 \
    SDL_VIDEO_X11_XRANDR=0 \
    SDL_VIDEO_X11_XVIDMODE=0 \
    DISPLAY=$DISPLAY.1 \
    ./mame64 sms sonic
```

The environment variables are explained below:

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

-   **DISPLAY=:$DISPLAY.1**: This tells Xorg to execute the program on the
    Screen1 (CRT Screen).

When installed with this package using `make` and `sudo make install`,
theses two wrappers are provided:

-   `15khz-zaphod-mame`: Launch groovymame with the environment variables
    set for use in Zaphod mode.

-   `15khz-mame`: Simply launch groovymame.

To know more about Mame usage, refer to the
[documentation](https://github.com/mamedev/mame/blob/master/docs/config.txt).
