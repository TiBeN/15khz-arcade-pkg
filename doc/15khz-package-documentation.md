15khz Arcade Package documentation
==================================

Intro
-----

The goal of this repository is to play retro games emulators at the real 
low resolutions of theses old systems on an `old school` CRT monitor like an 
analog TV or an arcade video game screen using Ubuntu.

Doing this is actually harder than it sounds because:

-   For some graphics cards, and to enable some features, Linux kernel 
    must be patched.
-   Nvidia drivers, both proprietary and open-source `nouveau`, 
    disallow resolutions lower than 320x200
-   This setup requires not obvious Xorg configuration
-   Using monitors with an 
    [horizontal frequency](https://en.wikipedia.org/wiki/Horizontal_scan_rate) 
    at ~15khz requires the use of custom 
    [modelines](https://en.wikipedia.org/wiki/XFree86_Modeline)
    which must be setup manually — There are tools for that.

This repository provides:

-   a step by step guide to connect a CRT screen, patch and install 
    a linux kernel and nouveau drivers, configure your Ubuntu and
    patch and configure some emulators
-   a `Makefile` to automate the download and the build of required programs
-   a set of scripts and tools like `resolution switchers`
    or `emulator wrappers`

Note: If your goal is to dedicate a machine for this purpose (into a 
physical arcade cabinet for example) you should considere 
[GroovyArcade](https://code.google.com/archive/p/groovyarcade/), a great 
dedicated ArchLinux distribution which works more or less out of the 
box. `15khz-arcade-pkg` aims to basically do the same thing but manually, 
on Ubuntu, and is really less exaustive.

Prerequisites
-------------

-   A video card with VGA or DVI output (NVIDIA recommended)

Cards with "s-video" or yellow RCA composite outputs are not covered here.
Having an Nvidia myself, this document is nvidia focused, that's why i
recommend it.
The kernel patch used does some changes on the `ATI` and `Arcade VGA` 
drivers so i suppose it works with theses cards but i have not tested.
In this case, the nouveau drivers patchs step is obviously not needed.
Also, i can't confirm it will works with all Nvidia cards.

-   Ubuntu 16.04 (Xenial Xerus)

The provided Makefile and the required APT packages are compatible with 
Ubuntu. So it will work only on this distribution. But i think it won't 
be hard to adapt the process to others distribution — Especially on debian 
based ones — by following the manual build and installation method bellow.

-   An Analog CRT screen with proper cables adapter

See `Hardware setup` below.

Build and installation of required programs
-------------------------------------------

Connecting and use an old analog CRT screen requires the following:

-   Patching, building and installing a Linux kernel using the 15khz patchs 
-   Patching, building and installing nouveau drivers — for NVIDIA cards
    only.

Additionnaly, i recommend:

-   Patching and building the Mame emulator using Groovymame patch to
    switch the monitor at the resolution matching the original system
    automatically.

The following provides you with two builds and installation methods: 
The first makes use of the provided Makefile which builds and installs 
theses requirements, among others tools, automatically. This is the easier 
method if your system fits the requirements preciselly.

The second provides a step by step guide to do it manually. It 
is not easier but can be adjusted to fit setups which differ a little.

### Method 1: Automatic using Makefile

The provided makefile automates the build of the following:

-   **Linux kernel Ubuntu-4.4.0-24.43**, patched using 15khz patchs.
-   **nouveau drivers 1.0.11**, patched to support low resolutions
-   **Mame 0.170**, patched with the groovymame patch.
-   **Vice 2.4** — a Commodore 64 emulator — with the SDL support. 
    SDL version of vice has a better support for full screen native 
    resolution.
-   **Switchres 1.52** — A tool used internally by the provided 
    `15khz-change-res-exec` script — see `usage`. 

1.  Install the following required packages using APT:

    ``` {.sourceCode .bash}
    $ sudo apt-get update
    $ sudo apt-get build-dep linux-image-$(uname -r)
    $ sudo apt-get build-dep mame vice xserver-xorg-video-nouveau
    $ sudo apt-get install fakeroot qt5-default qtbase5-dev \
        qtbase5-dev-tools git unrar libxml2-dev libsdl1.2-dev
    ```

    You can also install theses optionnal packages if you
    want support for theses Atari ST and Amiga emulators (wrappers are
    provided to launch theses emulators at native resolution):

    ```bash
    $ sudo apt-get install hatari fs-uae
    ```

2.  Go to the
    [releases](https://github.com/TiBeN/15khz-arcade-pkg/releases)
    page and download the lastest version matching your Ubuntu version.
    Extract the files from the distribution file then go the extracted
    directory: 

    ```
    $ cd /somewhere/you/whant
    $ wget https://github.com/TiBeN/15khz-arcade-pkg/archive/wily_Ubuntu-4.4.0-24.43_0.170_1.tar.gz
    $ tar xvf wily_Ubuntu-4.4.0-24.43_0.170_1.tar.gz
    $ cd 15khz-arcade-pkg-wily_Ubuntu-4.4.0-24.43_0.170_1/
    ``` 
    (Change the version to the downloaded one from the line above)

    Alternatively you can clone this repository using git but beware
    the master branch may be in a "Work in progress" state and can
    not compile nor work as expected:

    ```bash
    $ git clone https://github.com/TiBeN/15khz-arcade-pkg.git
    ```

3.  Go the source dir of the project and launch the build:

    ``` {.sourceCode .bash}
    $ cd ./15khz-arcade-package
    $ make
    ```

    Be warned that this step will take hours because it triggers the
    compilation of the Linux Kernel and the MAME emulator among others.
    The `-j<number-of-cpu+1>` option can be used to paralelise the build 
    and speed up things a little.

    Once done, built items are available inside the `vendor` directory. 
    The kernel and nouveau drivers are made available as Debian packages.
    Others items built are available in their own directories.

4.  Uninstall official drivers if you use them. Search for packages prefixed 
    with `nvidia-` and uninstall them. You can know what package
    is installed by looking at packages marked `ii` on the output of this
    command:

    ``` {.sourceCode .bash}
    $ dpkg -l nvidia-*
    ```

    Once you know which are installed, uninstall them (replace
    `<installalled-nvidia-package>` by the list of the packages previously
    found):

    ``` {.sourceCode .bash}
    $ sudo apt-get remove <installed-nvidia-packages>
    ```

5.  Install everything automatically:

    ``` {.sourceCode .bash}
    $ sudo make install
    ```

    The command above triggers the installation of the kernel and nouveau 
    drivers package, and copy everything else (compiled programs and 
    provided scripts) on /usr/local/* to make them available in your $PATH.

    If you prefer to install them manually, i suggest you to read the manual 
    installation method below to know exactly what to do.

5.  Reboot your computer with the newly installed patched kernel. To be
    sure to boot on the new kernel, hold `<shift>` during boot to make
    appear the Grub boot menu and select the good kernel. Once done, check 
    if you have booted on the good kernel by type `uname -a`. It should 
    match the version specified on the list above.

### Uninstallation 

Everything can be uninstalled by doing 

```bash
$ sudo make uninstall
``` 

Because it will uninstall the patched kernel packages, you should reboot 
your computer after uninstall finished.

Please note that the `uninstall` method replaces the patched `nouveau`
drivers package by the original one available on the APT Repository. If you
used the official binary drivers, you have to reinstall them manually.

### Method 2: Manual installation

The following explains how to patch, build, and install manually a Linux 
kernel, nouveau drivers, and the Mame emulator.

#### Patching the kernel

Because i am not the author of the patchs — thanks to arcadecontrol 
forum for their work on that — It is not very clear to me what the patch 
is fixing but i presume the following:

-   It allows 15khz modelines in `KMS` mode — the framebuffer 
    display engine used by the kernel at boot (splashscreen).
-   It modifies some parts of the code related to `ATI` and 
    `Arcade VGA` cards drivers. Maybe theses cards are not allowed to 
    handle low resolutions or 15khz modelines without theses fixes.
-   **It is not required for NVIDIA cards**, at least for me. Only
    patched nouveau drivers — as explained bellow — are required if the 
    only goal is to play emulators and if you don't care about the 
    booting phase.
-   When patching a Kernel > 3.19, KMS feature doesn't seems to work.

1.  At first, get and note the version of the installed Kernel:

    ``` {.sourceCode .bash}
    $ uname -r
    ```

2.  Get the patch for the kernel matching the actual version of the
    Kernel, if available, at this url:
    <http://forum.arcadecontrols.com/index.php/topic,107620.280.html>.
    New versions of the patch are frequently posted on this topic as new
    versions of the kernel are available.
    **Update**: Since kernel v3.19, no updates have been done on this forum.
    Until now, the patchs seems to work with 4.2.0 kernel. If it is not the 
    case anymore, the following github repository hosts patched kernel 
    sources which seems to be up to date and synchronised with upstream 
    kernel sources. 
    To get the patchs, select the git tag which matches the kernel version then 
    check the commits done by the owner of the repo — `philenotfound`. He
    names the commits 'avga3000-<version>.diff', 
    'ati9200_pllfix-<version>.diff' and 'linux-<version>'.diff. 
    Append `.patch` to the github url of theses commits to obtain a patch file 
    (it's a github feature).

3.  Follow the official Ubuntu tutorial here:
    <https://wiki.ubuntu.com/Kernel/BuildYourOwnKernel>. At the 
    `Modifying the configuration` step, skip it but apply the patchs by
    doing:

    ``` bash 
    $ cd ~/path-to-kernel-sources
    $ unzip /path/to/download/kernel-patch-<linux-version>.zip
    $ patch -p1 < patch-<linux-version>/ati9200_pllfix-<linux-version>.diff
    $ patch -p1 < patch-<linux-version>/avga3000-<linux-version>.diff
    $ patch -p1 < patch-<linux-version>/linux-<linux-version>.diff
    ```
    
    Change the debian.master/changelog file by adding the suffix 
    `+patched15khz` as adviced on the tutorial.

    If the compilation fails due to an ABI error or something like that, 
    repeat the compilation step  by adding `skipabi=true` on the command
    line:

    ```bash
    $ skipabi=true fakeroot debian/rules binary-headers binary-generic
    ```
    
#### Patching the Nouveau drivers for Nvidia cards 

Probably for security concerns, some Linux video drivers don't allow the user 
to set resolutions mode under 320x200 like theses used by old consoles and 
arcade systems. 

Using Nvidia cards, it is not possible to use the officials drivers because 
they are distributed as binary blobs and can't be patched. During my tests
whith the official drivers, i noticed stranges white lignes on black screen 
artifacts on low resolutions. The solution is to patch and use the 
open-source `nouveau` drivers. 

During my tests i noticed the following: With a ZaphodHeads Xorg layout 
and drivers not patched, the window of games having very low resolutions 
(Insector X, or Sega Master system using Groovymame for example) were not
centered but too much to the right, a part of the window being out of the
edge. Using the patched drivers fix this issue. I have not encountered 
this issue with the `new X instance` configuration layout. This 
configuration layout doesn't seems to require patched drivers.

Follow theses step to patch the `nouveau` drivers and install them:

1.  Uninstall official drivers if you are using them. Search for any package
    prefixed with `nvidia-` and uninstall them. You can know what package
    is installed by looking at packages marked `ii` on the output of this
    command:

    ``` {.sourceCode .bash}
    $ dpkg -l nvidia-*
    ```

2.  Fetch the sources of the `nouveau` drivers from APT:

    ``` {.sourceCode .bash}
    $ mkdir /some/path/to/store/nouveau-sources
    $ cd /some/path/to/store/nouveau-sources
    $ apt-get source xserver-xorg-video-nouveau
    ```

3.  Edit the following file
    `xserver-xorg-video-nouveau-<version>/src/drmmode_display.c` and
    apply theses changes (lines prefixed by '-' must be replaced by theses
    prefixed by a '+'): 

    ```c
    - xf86CrtcSetSizeRange(pScrn, 320, 200,
    -    drmmode->mode_res->max_width,
    -    drmmode->mode_res->max_height);
    + xf86CrtcSetSizeRange(pScrn, 160, 100,
    +   drmmode->mode_res->max_width,
    +   drmmode->mode_res->max_height);
    ```

4.  Compile the patched sources and create the deb package:

    ``` {.sourceCode .bash}
    $ cd xserver-xorg-video-nouveau-<version>
    $ dpkg-buildpackage -us -uc -nc
    ```

5.  Install the package (it will automatically uninstall the official if 
    you use it):

    ``` {.sourceCode .bash}
    $ sudo apt-get purge xserver-xorg-video-nouveau
    $ sudo dpkg -i xserver-xorg-video-nouveau_<version>.deb
    ```

6.  Reboot the system

#### Compile Groovymame from the sources.

[Groovymame](http://forum.arcadecontrols.com/index.php/topic,135823.0.html?PHPSESSID=sblf9jfedgk1eg60i8l0524kq5) 
is a patched version of Mame which generates and sets on-the-fly accurates
15Khz modelines to aproximatelly fit the native resolution of the 
emulated game.

Groovymame is distributed as compiled binary packages or as a diff patch to 
apply to official Mame sources. 

You can download the compiled version at this url
<https://54c0ab1f0b10beedc11517491db5e9770a1c66c6.googledrive.com/host/0B5iMjDor3P__aEFpcVNkVW5jbEE/>
or the follow the steps below to compile Groovymame from the sources on Ubuntu.

1.  Grab the last version of the Mame sources at this url:
    <http://www.mamedev.org/release.html>

2.  Unzip the downloaded archive and go to the unzipped sources
    path:

3.  Grab the Groovymame diff file and Hi score diff file (mandatory)
    that matches the version of the official Mame sources previously 
    downloaded at this url:
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

Configuration
-------------

### Hardware setup

The connexion between the PC and the CRT monitor can be done using a
custom homemade VGA / Scart Adapter as shown here
<http://www.geocities.ws/podernixie/htpc/cables-en.html#vgascart> or
using an UMSA Ultimate SCART Adapter available here:
<http://arcadeforge.net/UMSA/UMSA-Ultimate-SCART-Adapter::57.html>

Because my monitor is a Schneider CTM644 (provided with old CPC464
Computer), i use a Scart / DIN adapter bought online at `CoolNovelties`
here:
<http://coolnovelties.co.uk/coolnovelties/amstrad-video-cables/26-amstrad-ctm-644-monitor-rgb-scart-adapter.html>

#### Vertical under/overscan adjustment

Vertical overscan/underscan can't be adjusted using software modelines.
It is often possible to adjust it inside some kind of `service menu` or
directly on the PCB of the TV.

On my CTM 644 monitor it can be adjusted by turning the `VR406` Variable
Resistor (See the [Schneider CTM640 Service
Manual](http://www.cpcwiki.eu/imgs/6/6f/Schneider_CTM640_Service_Manual_%28German_and_English%29.pdf)
for a view of the monitor main PCB).

### Bypassing EDID detection by KMS

Mosts VGA/DVI/HDMI screens communicates `EDID` data to the kernel — and
X server ? — at initialisation. Theses metadatas contain informations
about the screen like the min/max resolutions, supported frequencies
etc. The old CRT screen doesn't communicate theses informations. This
results the kernel to ignore the screen at boot. It is possible to tell
the kernel to bypass this detection and force the state as connected.
This is done by adding to parameters to the kernel at boot:

1.  Edit the grub configuration file `/etc/default/grub` and add
    `vga=0x311 video=<DEVICE-NAME>:640x480e` to the kernel options
    `GRUB_CMDLINE_LINUX_DEFAULT`.

    Replace <DEVICE-NAME> by the name of the output where the CRT screen is
    connected (common names: VGA-1, DVI-I-1). Ask your `xrandr` to know 
    the name of your available output devices and deduce on which your CRT	
    monitor is plugged.

2.  Tell to take in account theses changes:

    ``` {.sourceCode .bash}
    $ sudo update-grub
    ```

### Configuring Xorg

Here is the most tricky part. Xorg allows many configuration schemes but
having it to achieve what you really want is not easy and it demands you to
understand a little how it works.

Xorg allows many configuration layouts to acheive our goal:

-   **One CRT Screen only**: If think it's the most simple setup and should
    works with the provided tools but is not covered for now (My primary
    goal was to connect a CRT screen as a slave).

-   **Dualhead using Xrandr**: This is the standard layout used today by
    default when you connect two screens on Ubuntu. After many tests
    this mode is definitelly to avoid in our case. During my test i noticed
    fullscreen conflicts with the desktop like side bar percisting or
    flickering in front of the emulator window screen, or resizing issue
    or, worst, programs launching on the wrong screen with no real
    solutions make it to launch on the CRT. So it is not covered here.

-   **Separate X screen using ZaphoHeads**: This is a great layout but
    works only with GroovyMame. Other emulators starts but keyboard and mouse 
    input does not responds. I think it is related to xorg input
    to screen assignation but i have not managed to configure them properly. 
    What's more the zaphodhead mode seems to be specific to nvidia cards.

-   **New X instance**: The idea is to launch a completelly new X server 
    instance with a special server layout using the `startx` wrapper. It is
    the mode i use actually because it removes the input issues i had with
    the zaphodhead mode. It is a little harder to setup, i'll cover it here
    asap. Note: This configuration layout doesn't seems to require patched
    version of nouveau drivers — see the relevant section to know more.

#### CRT Screen only

Covered asap

#### Zaphodheads mode

The instructions to configure the X server in Zaphodhead for nouveau drivers 
is explained on the official `nouveau drivers` website at 
<https://nouveau.freedesktop.org/wiki/MultiMonitorDesktop/>.

It is recommended to delete the file `~/.config/monitors.xml` because it
seems to override Xorg options and makes debugging harder.

The file `doc/xorg-zaphodhead-example.conf` available in this repository of 
the project is a working `xorg.conf` example. In this example, CRT screen 
is set on the output "DVI-I-1". Custom 15khz 648x480 modeline is defined 
and set as default mode on the `Monitor1` attached to `Screen1`. This 
ensures the CRT screen to be set with a compatible 15Khz modeline 
by default.

You can use this config file and adjust it for your configuration.

#### On demand new X instance

Covered asap.

An example of an xorg.conf for this layout is avaible on this repository at 
`doc/xorg-separate-layouts-example.conf`.

Usage
-----

The 15Khz screen is made available as a separate X screen numbered `:0.1` — 
On Ubuntu Wily with Gnome 3 and maybe others, the screen number starts at
:1, so in this case the screen number is `:1.1`.
So to launch a program on this screen, prefix the command-line with
`DISPLAY=:0.1`. Example:

```bash
$ DISPLAY=:0.1 xrandr
```

Most of the wrappers and scripts provided by this package need the 
environment variable `OUTPUT15KHZ` to be set to the xrandr output 
where the CRT screen is connected. So, i recommend you
to put this variable in your `~/.bashrc` or `~/.profile` file and set it
matching your configuration: 

```bash
export OUTPUT15KHZ="VGA1" 
```

### Groovymame

Because groovymame is not on the APT repositories, its build is made by
the provided Makefile. To launch groovymame64:

```bash
$ 15khz-mame <mame-command-line-args>
```

For xorg setups in `Zaphod mode`, a special wrapper is provided, setting
some SDL related environment variables to make it work is this setup:

```bash
$ DISPLAY=:0.1 15khz-zaphod-mame <mame-command-line-args>
```

### Hatari

This Hatari wrapper switches the screen resolution to native Atari ST 
resolution before launching it.

```bash
$ 15khz-hatari <hatari-command-line-args>
```

Note: This emulator has no v-sync option or like. Despite all my efforts
to find the perfect vertical refresh rate, there is a small horizontal 
tearing artifact on my setup i have not managed to remove completelly.

### FS-UAE

This fs-uae wrapper switches the screen resolution to native Amiga
resolution before launching it.

This system supports many resolutions and the best to choose depends on 
the game. This wrapper has an optionnal -m switch to choose the best:

-   1: 320x200
-   2: 320x240 (default)
-   3: 320x256
-   4: 728x568 (experimental)

```bash
$ 15khz-fs-uae [-m {1,2,3}] <fs-uae-command-line-args>
```

### Vice

Despite its presence on the APT repository, We will use a custom build 
provided by the Makefile to make use of the SDL version which works 
better is this context.

This vice "x64" wrapper switches the screen resolution to native 
Commodore 64 resolution before launching it.

```bash
$ 15khz-x64 <x64-command-line-args>
```

Note: This emulator has no v-sync option or like. Despite all my efforts
to find the perfect vertical refresh rate, there is a small horizontal 
tearing artifact on my setup i have not managed to remove completelly.

### Change screen resolution and execute a command

A script is provided with this package which allows you to change the
resolution on the fly, executes a program, then reverts back to original
resolution when program quits:

```bash
$ OUTPUT15KHZ=VGA1 15khz-change-res-exec 320 240 50 firefox
```

This command sets the resolution of the screen connected to the 
output `VGA1` at 320x240 with a refresh rate of 50hz then launch 
firefox. Okay this is pretty useless, but it can be more usefull with 
an emulator. It is used by emulator wrappers provided by this package.

Internally, the 15khz modeline is computed on the fly using the 
`switchres` utility made by `Calamity`, the author of the Groovymame patch.
Like others assets of this package, `switchres` is automatically 
downloaded, compiled and installed using the `Makefile`.

### Launch a program on a new X instance

This package provides the launcher `15khz-startx` to be used when your xorg
setup follows the `On demand new X instance`. I'll cover it asap.

Version scheme
--------------

The versionning follows this pattern: 

```
<ubuntu-release-code>_<ubuntu-kernel-version>_<mame-version>_<pkg-version>
```

The `<pkg-version>` is incremented for new releases having the sames parts
version.
