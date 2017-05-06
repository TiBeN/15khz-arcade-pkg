15khz Arcade Package documentation
==================================

Abstract
--------

This documentation explains how to build required packages and tools and
setup your system to make use of a Monitor with an [horizontal scan
rate](https://en.wikipedia.org/wiki/Horizontal_scan_rate) at 15khz on
Ubuntu with the main goal of using commons emulators, like Mame, at the real
resolution of the emulated systems.

Doing this is actually harder than it sounds because:

-   By default, the system doesn't allow the use of such low resolutions —
    for example, the NES game console has a native resolution of 256×240
    pixels. To workaround this issue, some parts of the system must be patched:
    The Linux kernel itself and Xorg nouveau drivers for Nvidia cards 
    (radeon drivers does not have to).

-   This setup requires manual, and not so obvious, Xorg Server configuration

-   15khz monitor are, for most, pretty old and does not provide [EDID
    information](https://en.wikipedia.org/wiki/Extended_Display_Identification_Data)
    so the kernel must be forced to enable the display and, at least one,
    [modelines](https://en.wikipedia.org/wiki/XFree86_Modeline) that suits
    such monitors must be manually provided to Xorg.

Note: If your goal is to dedicate a machine for this purpose (into a 
physical arcade cabinet for example) and doesn't not want to use Ubuntu
specifically, you should considere 
[GroovyArcade](https://code.google.com/archive/p/groovyarcade/), a great 
dedicated ArchLinux distribution that works more or less out of the 
box and is well supported by a community.

Compared to Groovyarcade, `15khz-arcade-pkg` is more of a tutorial in order
to accomplish manually a similar goal for Ubuntu specifically.

Table of contents
-----------------

-   [Prerequites](#prerequisites)
-   [Build and installation of packages and tools](#build-and-installation-of-packages-and-tools)
-   [Configuration](#configuration)
-   [Provided tools configuration and usage](#provided-tools-configuration-and-usage)
-   [Version scheme](#version-scheme)
-   [Doing things by yourself](#doing-things-by-yourself)
-   [Thanks](#thanks)


Prerequisites
-------------

-   A video card with VGA or DVI output

S-video or yellow RCA composite outputs cannot be used for what we want to
achieve because the signal that is output by these connectors is converted
to PAL or NTSC standards. Because of that it is not possible to make use of
custom modelines in order to tweak the resolution/refresh rate to match
native resolutions of emulated systems (Please correct if i'm wrong).

I have tested with success with two Nvidia cards and a Radeon. ArcadeVGA cards
seems to be supported too. `Calamity`, a prolific developper is this field
— author of GroovyMame patch, the GroovyArcade distribution among other —
[recommends the use of a Radeon
card](http://forum.arcadecontrols.com/index.php/topic,151459.0.html) for this usage:

> Regarding the hardware part, do yourself a favour and grab an ATI/AMD
> Radeon card, any model from Radeon 7000 to the HD 7xxx family should
> work, both AGP and PCIe models. As far as we know, there is nothing that
> can remotely compare to these cards in terms of flexibility.

I can relate some tearing issue with nvidia cards i am able to fight with
`vsync` related options of emulators. This issue does not affect the Radeon.

-   Ubuntu 16.10 (Yakkety Yak)

The dependencies required by the provided Makefile in order to build needed
parts targets Ubuntu specifically. So it will work only on the mentionned
version of this distribution. I try to release new versions of this
packages as new versions of Ubuntu or new kernel updates are released.

I think it won't be too hard to adapt the process to others Debian based
distributions. I provide in this documentation a guide to build essentials
parts manually too. 

-   Obviously, a 15khz monitor screen with proper cables and adapters to
    connect it to a DVI or VGA adapter.

See `Hardware setup` below.

Build and installation of packages and tools
--------------------------------------------

The provided makefile builds the following packages and tools:

-   **Linux kernel Ubuntu-4.8.0-51.54** patched to support low
    resolutions
-   **nouveau drivers 1.0.12**, patched to support low resolutions.  Note:
    it is not possible to use the officials Nvidia drivers because they are
    distributed as binary blobs and can't be patched. During my tests with the
    official drivers, i noticed stranges white lignes on black screen artifacts
    on low resolutions. `nouveau` drivers are the only solution.
-   **Groovymame 0.183**, a Mame emulator with special abilities to compute
    modelines on the fly and switch the screen to the resolution of the
    emulated system.
-   **Vice 3.0** — a Commodore 64 emulator — compiled with the SDL support. 
    SDL version of vice has a better support for full screen native 
    resolution that's why it is provided here and not simply advised to be
    installed from Ubuntu repositories.
-   **Hatari 2.0.0** — An Atari ST emulator. Version 2.0.0 adds a Vsync
    feature that can help reduce tearing issues on some setups (Nvidia).
-   **Switchres 1.52** — A modeline generator made by `Calamity` that is able 
    to generate modelines for 15khz monitors. 
-   **Attract-Mode 2.2.1** — A good full-screen emulators frontend that can be 
    used with a Joystick. It is ideal for arcade cab or multi-seat setups.

All theses programs are installed by default on
`/usr/local/lib/15khz-arcade-pkg/*`. Bash wrappers launchers of theses
programs, that are prefixed by `15khz-<program>` are copied to `/usr/local/bin`
so there will be no clash with some of theses programs eventually already
installed on your system.

1.  Install the following required deb packages needed for the build:

    ``` {.sourceCode .bash}
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

    `15khz-arcade-pkg` does not build the emulator `fs-uae` but provides a
    simple bash wrapper to use the one provided by official Ubuntu repositories
    with a 15khz monitor. You can install this emulator from the official
    Ubuntu repository:

    ```bash
    $ sudo apt-get install fs-uae
    ```

2.  Go to the
    [releases](https://github.com/TiBeN/15khz-arcade-pkg/releases)
    page and download the lastest version matching your Ubuntu version.
    Extract the files from the distribution file then go the extracted
    directory: 

    ```
    $ cd /somewhere/on/your/drive
    $ wget https://github.com/TiBeN/15khz-arcade-pkg/archive/<version>.tar.gz
    $ tar xvf <version>.tar.gz
    $ cd 15khz-arcade-pkg-<version>/
    ``` 
    (Change the \<version\> to the downloaded one from the lines above)

    Alternatively you can clone this repository using git but beware
    the master branch may be in a "Work in progress" state and can
    not compile nor work as expected, or could not be syncronised with this 
    documentation:

    ```bash
    $ git clone https://github.com/TiBeN/15khz-arcade-pkg.git
    ```

3.  Go the source dir of the project and launch the build:

    ``` {.sourceCode .bash}
    $ cd ./15khz-arcade-package
    $ make
    ```

    Be warned that this step can take many hours because it triggers the
    compilation of the Linux Kernel and the MAME emulator among others.

    Once done, built items are available inside the `vendor` directory. 
    The kernel and nouveau drivers are available as Debian packages.
    Others built items are available in their own directories.

4.  (Nvidia user only) If you make use of Official binary drivers, you 
    have to uninstall them first. Search for packages 
    prefixed  with `nvidia-` and uninstall them. You can know what package
    is installed by looking at packages marked `ii` on the output of this
    command:

    ``` {.sourceCode .bash}
    $ dpkg -l nvidia-*
    ```

    Once you know which are installed, uninstall them (replace
    `<installed-nvidia-package>` by the list of the packages previously
    found):

    ``` {.sourceCode .bash}
    $ sudo apt-get remove <installed-nvidia-packages>
    ```

5.  Install:

    Here you have the choice of installing everything automatically and
    properly, or just installing the required pieces (Kernel and nvidia
    drivers) manually and make use of the provided tools directly from the
    source tree by launching them from the `bin` directory.

    Install everything automatically:

    Simply type: 

    ``` {.sourceCode .bash}
    $ sudo make install
    ```

    The command above triggers the installation of the kernel and nouveau 
    drivers package, and copy everything else (compiled programs and 
    provided scripts) on /usr/local/* to make them available in your $PATH.

    Install only required parts:

    Go to the `vendors/` directory and type

    ``` {.sourceCode bash}

    $ dpkg -i linux-headers-<version>+patched15khz_all.deb \
        linux-headers-<version>+patched15khz_amd64.deb \
        linux-image-<version>+patched15khz_amd64.deb \
        linux-image-extra-<version>+patched15khz_amd64.deb
    ```

    If you have a Nvidia card type additionally: 

    ``` {.sourceCode bash}
    $ sudo dpkg -i xserver-xorg-video-nouveau_<version>+patched15khz_amd64.deb
    ```

5.  Reboot your computer with the newly installed patched kernel. To be
    sure to boot on the new kernel, hold `<shift>` during boot to make
    the Grub boot menu to appear and select the good kernel. Once done, check 
    if you have booted on the good kernel by type `uname -a`. It should
    match the version specified on the list above, suffixed by
    'patched15khz'.

### Uninstallation 

If you installed everything automatically using `sudo make install`,
uninstallation is as simple as: 

```bash
$ sudo make uninstall
``` 

This method takes care to uninstall the patched kernel and install, if not
already installed, the latest kernel available from the official Ubuntu
repositories (ie the meta packages `linux-image-generic` and
`linux-header-generic`) to prevent your system to reboot without any kernel
installed.

Additionnaly, it replaces the patched `nouveau` drivers package
by the original one available on the APT Repository. If you used the
official binary drivers, you have to reinstall them manually.

Because it uninstalls the patched kernel packages, you should reboot 
your computer after uninstall finished.

If you installed only the required parts manually, you have to uninstall them
manually and reinstall the original ones:

```bash
$ sudo apt-get remove linux-headers-<version> \
    linux-headers-<version>-generic linux-image-<version>-generic
$ sudo apt-get install linux-headers-<version> \
    linux-headers-<version-generic linux-image-<version>-generic
```

If you have a Nvidia card, you have to uninstall patched Xorg nouveau drivers
ans reinstall the originals ones. This can be done in one command line: 

```bash
$ apt-get install --reinstall xserver-xorg-video-nouveau
```

Configuration
-------------

### Hardware setup

This documentation does not covers hardware part of the configuration
because it depends on your actual system and your goals.

Here are however some tips: 

The connection between the graphic card and the monitor is done through 
RGB video signal. On the graphic card side, the VGA or DVI connector can be
used. On the monitor side any connector that handle RGB can be used (SCART,
RCA red/green/blue etc.).
 
The following resource explains how to make a custom homemade VGA / Scart
Adapter: <http://www.geocities.ws/podernixie/htpc/cables-en.html#vgascart>.

I use personally an UMSA Ultimate SCART Adapter available here:
<http://arcadeforge.net/UMSA/UMSA-Ultimate-SCART-Adapter::57.html>

#### Vertical under/overscan adjustment

Vertical overscan/underscan can't be adjusted using software modelines.
It is often possible to adjust it inside some kind of `service menu` or
directly on the PCB of the TV.

### Force the kernel to enable the output without EDID

Almost all recent monitors communicates [EDID
data](https://en.wikipedia.org/wiki/Extended_Display_Identification_Data)
to the kernel at initialisation. Theses metadatas contain technical data
about the screen like the min/max resolutions, supported frequencies etc.
that are used by the Kernel and Xorg to know to allowed modelines for the
monitor. Old 15khz monitors don't communicate theses informations. This
results the kernel to ignore the screen at boot. The following
configuration will force the kernel to activate the graphic card's output
where the 15khz monitor is connected — despite the lack of EDID data — and
sets it to the 640x480 15khz modeline provided by the patch. This is done
by adding theses parameters to the kernel at boot:

1.  Edit the grub configuration file `/etc/default/grub` and add
    `vga=0x311 video=<connector>:640x480@60ec` to the kernel options
    `GRUB_CMDLINE_LINUX_DEFAULT`.

    Replace <connector> by the name of the connector where your 15khz monitor is
    plugged (common names: VGA-1, DVI-I-1). You can list connector name by
    doing: 

    ```
    ls /sys/class/drm/
    ```

    The `e` option forces the activation of the output and the `c`
    activates 15khz modeline. This last option is not part of the kernel video
    options but brought by the patch only.

2.  Tell Grub to take in account theses changes:

    ``` {.sourceCode .bash}
    $ sudo update-grub
    ```

3.  Reboot

It seems to have another path to achieve this: Generate EDID data and
inject it to the kernel using the `drm_kms_helper` kernel  module.
Unfortunately this only seems to work with ATI drivers. I tried myself
using NVIDIA wihout any luck. More information in this [arcadecontrol forum
thread](<http://forum.arcadecontrols.com/index.php?topic=140215.0) , and
[in this github repository](https://github.com/Ansa89/linux-15khz-patch).

### Define the patched kernel as default to boot on

If the patched kernel version is the same as the current in Ubuntu
repositories, it will be choosen by default because it replaces the
official. But if the patched kernel is anterior to the current official,
[Grub](https://en.wikipedia.org/wiki/GNU_GRUB) will boot by default on the
last one.

Grub can be forced to boot a specific kernel.  Defining the default Kernel
to boot is done by setting the option `GRUB_DEFAULT` of the
`/etc/default/grub` file to the path of the kernel from the grub menu entry
— in letter. If, for example, you navigate through the following grub menu
to boot your kernel: Advanced options for Ubuntu > Ubuntu, with Linux
3.13.0-53-generic, define the option like this:

1.  Edit the grub configuration file `/etc/default/grub`

2.  Set the `GRUB_DEFAULT` option like this — Don't forget the quotes:

    ```
    GRUB_DEFAULT="Ubuntu > Ubuntu, with Linux 3.13.0-53-generic"
    ```

3.  Tell grub to take in account theses changes:

    ``` {.sourceCode .bash}
    $ sudo update-grub
    ```

4. Reboot

### Xorg configuration

Here is the most tricky part because it depends on your hardware how you
want to setup your monitors: Only the 15khz monitor, an LCD monitor on the
HDMI port and the 15khz monitor as a slave etc.

Xorg allows many configuration layouts but having it to achieve what you
really want is not easy. It demands you to understand a little how to
configure a `xorg.conf` file.

I tried many layouts. How to configure some of them is explained below.

### Instructions commons to all layouts

The make things simple, [Xorg
Xserver](https://en.wikipedia.org/wiki/X.Org_Server) is the base graphical
environment software componant on Linux. It is configured through a file
named `xorg.conf` located at `/etc/X11/xorg.conf`, at least on Ubuntu
distributions.  If you have not already played with it there are chances it
doesn't exists on your system because today it's configuration is now handled
dynamically.

I will not explain here the concepts and methods of the `xorg.conf`
configuration — Here is a good 
[introduction](http://www.ghacks.net/2009/02/04/get-to-know-linux-understanding-xorgconf/) 
—, but i provide a `xorg.conf` example file for each configuration 
layouts i cover on this documentation.

All configuration layouts have in common the use of a custom Modeline (see
the Modeline parameter on the examples files) with a resolution of 648x480
and refresh rate of 60hz attached to the CRT screen configuration. This is
the key configuration to make your 15khz monitor to display something by
default — emulators provided by this package handle their own modelines.

Using these examples as templates, you will essentially need to check 
and replace the outputname (common names are DVI-I-1, VGA-1 or HDMI-1) 
or the BusID. 

Outputnames of your system can be known using `xrandr`:

```bash
$ xrandr
```

It is important to note the output name used by `Xorg` may differs to the
ones used by the kernel.

Bus id can be known with the following command: 

```bash
$ lspci | grep VGA
```

#### 15khz monitor only

This is the layout to use when you only want your CRT screen connected.
(with a cab or as a box connected to a TV set)
I strongly recommend you to use a patched kernel and KMS configured 
properly to allow you to debug your system without X instance.
The provided example `xorg.conf` file is available 
[here](doc/xorg-crt-only-example.conf).

#### Dualhead using Xrandr

This layout is the standard used today by default when you connect two
screens on Ubuntu. After many tests this mode is definitelly to avoid in
our case. During my tests i noticed fullscreen conflicts with the desktop
like side bar percisting or flickering in front of the emulator window
screen, or resizing issue or, worst, programs launching on the wrong screen
with no real solutions make it to launch on the CRT.

#### Zaphodheads mode

This layout allows Xorg to enable two distincts displays (:0 and :1, or :0.0
and :0.1) using only one X server instance, one graphic card and two
outputs. Display :0 can be used for your desktop/LCD screen, and display :1
can be used for the 15khz monitor. 

In this layout, applications/emulators can be launched on specific screen
by exported the DISPLAY environment variable. Example:

```
$ DISPLAY=:0.1 firefox
```

This layout has unfortunatelly a drawback: It not possible (or at least i
have not found how ) to configure the inputs (keyboard/mouse/joystick). I
was only able to make Groovymame to work on display :1. Other emulators
start but keyboard and mouse input does not responds. I think it is related
to Xorg input to screen assignation but i have not managed to configure
them properly. What's more, when an application is launch on display :1,
display :0 can't be used.

The instructions to configure the X server in Zaphodhead for nouveau drivers 
is explained on the official `nouveau drivers` website at 
<https://nouveau.freedesktop.org/wiki/MultiMonitorDesktop/>.

It is recommended to delete the file `~/.config/monitors.xml` because it
seems to override Xorg options and makes debugging harder.

The provided example `xorg.conf` file is available
[here](doc/xorg-zaphodhead-example.conf). In this example, 15khz monitor
is set on the output "DVI-I-1". 

Once done, the 15Khz monitor is made available as a separate X screen 
numbered `:0.1` — On Ubuntu with Gnome 3 and maybe others, the screen 
number starts at :1, so in this case the screen number is `:1.1`.
So to launch a program on this screen, prefix the command-line with
`DISPLAY=:0.1`. Example:

```bash
$ DISPLAY=:0.1 xrandr
```

#### On demand new X instance

Like the `Zaphodheads mode`, this layout is suitable for two monitors
connected to only one graphic card with two (or more) outputs.

In this layout, two distincts Xorg "ServerLayout" are configured. The first
is for the main desktop screen (the main Xorg session started by your
system), and the second for the 15khz monitor. The second is only activated
on demand by launching a new Xserver instance with the `startx` wrapper. 

An `xorg.conf` example file for this layout is available 
[here](doc/xorg-separate-layouts-example.conf). 

To ease things, a launcher `15khz-startx` is provided with this package.
This launcher solves a command line argument limitation encountered with
the original `startx` program. This wrapper requires the `ServerLayout`
section suited for the 15khz monitor to be named `arcade`, like in the
`xorg.conf` example. Once configured, you can launch a program on your
15khz monitor with 15khz-startx:

```
$ sudo 15khz-startx 15khz-mame sf2
```

Sudo is required to launch a new X server. 

In order to have sound, this layout requires `PulseAudio` (the sound server
used by Ubuntu) to by configured as a system-wise service. By default an
instance is launched per session. This
[tutorial](https://rudd-o.com/linux-and-free-software/how-to-make-pulseaudio-run-once-at-boot-for-all-your-users) explains how to do that. 

This layout has, like `Zaphodheads mode`, the drawback of making your main
screen unusable while launching something on the 15khz monitor. It makes,
on the contrary, inputs manageable.

#### Multi seat

The [Multi seat](https://en.wikipedia.org/wiki/Multiseat_configuration)
layout allows you to have many combinations of [monitor/keyboard/mouse]
called `seat` physically connected to only one machine, but acting like
they were distinct systems, running each one their own session. This
configuration solves the `main screen unusable` issue encountered with
`zaphodhead mode` and `on demand new X instance`. It however
requires one graphic card per seat, so at least two graphics cards.

For non decicated machine usage, like `15khz monitor only` layout, this is
the more manageable layout. This is the one i use now with this setup: 

- Seat 0 is for desktop usage: An LCD monitor, one mouse, one keyboard, 
  integrated sound card in graphic card through HDMI all others usb ports.

- Seat 1 is for arcade gaming usage: A 15khz TV set, a X-Arcade controller,
  sound card integrated on the motherboard and optionnal pair of
  mouse/keyboard i hotplug when i need to configure something. Session
  is configured to boot on `attract-mode` frontend (This frontend is
  provided by the package, see below to see how to configure it).

An `xorg.conf` example file for this layout is available
[here](doc/xorg-multiseat-example.conf). The important configuration
parameter is `MatchSeat`. Each device section (one per graphic card) must
have a different seat. `seat0` is the one launched by default by the
system.

Now you have to groups your available device by `seat`. `systemd` init
system includes a tool named `loginctl` that really simplifies the
configuration of multiseats.

First, list all the devices attached to the default `seat0`:

```
$ loginctl seat-status seat0
```

This will outputs something like this:

```
seat0
        Sessions: *c3
         Devices:
                  ├─/sys/devices/LNXSYSTM:00/LNXPWRBN:00/input/input1
                  │ input:input1 "Power Button"
                  ├─/sys/devices/LNXSYSTM:00/LNXSYBUS:00/PNP0C0C:00/input/input0
                  │ input:input0 "Power Button"
                  ├─/sys/devices/pci0000:00/0000:00:03.0/0000:01:00.0/drm/card1
                  │ [MASTER] drm:card1
                  │ ├─/sys/devices/pci0000:00/0000:00:03.0/0000:01:00.0/drm/card1/card1-DVI-I-2
                  │ │ [MASTER] drm:card1-DVI-I-2
                  │ ├─/sys/devices/pci0000:00/0000:00:03.0/0000:01:00.0/drm/card1/card1-HDMI-A-2
                  │ │ [MASTER] drm:card1-HDMI-A-2
                  │ └─/sys/devices/pci0000:00/0000:00:03.0/0000:01:00.0/drm/card1/card1-VGA-2
                  │   [MASTER] drm:card1-VGA-2
                  ├─/sys/devices/pci0000:00/0000:00:03.0/0000:01:00.0/drm/renderD129
                  │ drm:renderD129
                  ├─/sys/devices/pci0000:00/0000:00:03.0/0000:01:00.0/graphics/fb1
                  │ [MASTER] graphics:fb1 "radeondrmfb"
                  ├─/sys/devices/pci0000:00/0000:00:03.0/0000:01:00.1/sound/card1
                  │ sound:card1 "HDMI"
                  │ └─/sys/devices/pci0000:00/0000:00:03.0/0000:01:00.1/sound/card1/input13
                  │   input:input13 "HDA ATI HDMI HDMI/DP,pcm=3"
                  ├─/sys/devices/pci0000:00/0000:00:1a.0/usb1
                  │ usb:usb1
                  │ └─/sys/devices/pci0000:00/0000:00:1a.0/usb1/1-1

```

You have to find the graphic card device you want to attach to your second
seat. Graphic card is made of three parts. On the example above it is: 

```
/sys/devices/pci0000:00/0000:00:03.0/0000:01:00.0/drm/card1
/sys/devices/pci0000:00/0000:00:03.0/0000:01:00.0/drm/renderD129
/sys/devices/pci0000:00/0000:00:03.0/0000:01:00.0/graphics/fb1
``` 

Now attach the device to a new seat `seat-1`. The seat name must match the
one mentionned in the `MultiSeat` parameter of the xorg.conf configuration
file:

```
$ loginctl attach seat-1 /sys/devices/pci0000:00/0000:00:03.0/0000:01:00.0/drm/card1
```

Repeat this operation for the two others parts of your graphic card. If
everything is ok, you should be able to see the composition of your new
seat:

```
$ loginctl seat-status seat-1
```

A seat must at least have a graphic device attached. If the seat does not
appears, something is wrong with the commands above.

Now, you have to identify the others devices you want to attach to your
seat. It is usually easy because devices names are given. For example, i
want to attach my Logitech keyboard to seat-1: 

Extract of ```$ loginctl seat-status seat0```
```
│   ├─/sys/devices/pci0000:00/0000:00:1a.0/usb1/1-1/1-1.2/1-1.2:1.0/0003:046D:C31C.0004/input/input8
│   │ input:input8 "Logitech USB Keyboard"
```

```
$ loginctl seat-status /sys/devices/pci0000:00/0000:00:1a.0/usb1/1-1/1-1.2/1-1.2:1.0/0003:046D:C31C.0004/input/input8
```

Repeat this operation for all the devices you want to attach.
Once done, reboot your computer. I should see two distincts user sessions.

For more information about multiseat, please refer to
[systemd](https://www.freedesktop.org/wiki/Software/systemd/multiseat/)
documentation.

Provided tools configuration and usage
--------------------------------------

Some of the tools provided by this package need the 
environment variable `OUTPUT15KHZ` to be set to the xrandr output 
where your 15khz monitor is connected. So, i recommend you
to put this variable in your `~/.bashrc` or `~/.profile` file and set it
matching your configuration: 

```bash
export OUTPUT15KHZ="VGA1" 
```

### Groovymame

[Groovymame](forum.arcadecontrols.com/index.php/topic,151459.0.html) is a
patched version of the emulator Mame that computes modelines compatible
with 15khz monitor matching the emulated system and resize the screen on
the fly. More information about this emulator can be found on this
[documentation](http://geedorah.com/eiusdemmodi/forum/viewtopic.php?id=290)

To launch the provided Groovymame:

```bash
$ 15khz-mame <mame-command-line-args>
```

For xorg setups in `Zaphod mode`, a special wrapper is provided, setting
some SDL related environment variables to make it work with this layout:

```bash
$ DISPLAY=:0.1 15khz-zaphod-mame <mame-command-line-args>
```

### Hatari

Hatari is an Atari ST Emulator. It is available from the Ubuntu APT
repositories but the newer 2.0.0 version is provided by the Makefile because
it includes a Vsync option that can be needed on some setups to avoid
tearing. 

#### Setup

In order to make Hatari to perform in fullscreen with a good resolution, some
configuration is required. First, for usage on a real CRT screen, one of
theses modelines need to be added on the `Monitor` section matching your
CRT screen of your `xorg.conf` file, depending on the ST roms used:

```
# 50Hz Low/Medium resolution (European machine)
ModeLine       "352x288x50.00" 7.386800 352 368 408 472 288 292 295 313 -HSync -VSync

# 60Hz Low/Medium resolution (US machine)
ModeLine       "352x200x60.00" 7.391520 352 368 408 472 200 222 225 261 -HSync -VSync
```

Next, add or update theses option values into the Hatari configuration
file (default sits at `$HOME/.config/hatari/hatari.cfg`, create it if it
doesnt already exists): 

```
[Screen]
nMonitorType = 1
nFrameSkips = 0
bFullScreen = TRUE
bKeepResolution = FALSE
bAllowOverscan = TRUE
nSpec512Threshold = 1
nForceBpp = 0
bAspectCorrect = FALSE
bUseExtVdiResolutions = FALSE
nVdiWidth = 640
nVdiHeight = 480
nVdiColors = 2
bMouseWarp = TRUE
bShowStatusbar = FALSE
bShowDriveLed = TRUE
bCrop = FALSE
bForceMax = FALSE
nMaxWidth = 352
nMaxHeight = 288
nRenderScaleQuality = 0
bUseVsync = 0
``` 

Hatari will now makes use of the resolution matching the modeline set on
the `xorg.conf` file.

If you notice some tearing, try to set bUseVsync option to 1. 

To launch the provided hatari:

```bash
$ 15khz-hatari <hatari-command-line-args>
```

See [Hatari User's
Manual](https://hg.tuxfamily.org/mercurialroot/hatari/hatari/raw-file/tip/doc/manual.html)
for more information about Hatari configuration and usage.

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
to find the perfect vertical refresh rate, a small horizontal 
tearing artifact could be noticed (at least with Nvidia cards). 

### Attract-Mode

`Attract-Mode` is a fullscreen emulators frontend that can be used with
joystick/pads and works well with a 15khz monitor. 

#### Configuration directory initialization

Attract-Mode stores its configuration into `$HOME/.attract`. As mentionned
in the official documentation, this directory must be copied from the
source tree first:

```
$ cp -r /usr/local/lib/15khz-arcade-pkg/attract/config $HOME/.attract
```

If you altered the `$(DESTDIR)` variable of the Makefile, source
directory must be adapted: `$(DESTDIR)/lib/15khz-arcade-pkg/attract/config`.

Once done, `Attract-Mode` can be launched:

```
$ 15khz-attract
```

Documentation for Attract-Mode can be found on the [official
webside](http://attractmode.org/about.html).

#### Make Attract-Mode start on boot

If you plan to dedicate a machine to arcade gaming using 15khz monitor only
layout, or one of your seats in a multiseat layout, you can configure
your system to make Attract-Mode to start automatically on system boot.
Please note that there are many ways to do that. The following method makes
use of the `Lightdm` session-manager and the `Openbox` Windows Manager.

Note: Despite `Lightdm` is able to launch Attract-Mode (or simply Mame)
directly, a window manager is required to avoid input event handling issues
causing keyboard to not respond etc. See this [ArcadeControls forum
thread](http://forum.arcadecontrols.com/index.php?topic=150716.0) for more
information about this issue. We use Openbox here because it is really
lightweight but any windows manager that can start a command automatically
at start can be used.

1.  Install Openbox
   
    ```
    $ sudo apt-get install openbox
    ```

2.  Tell `Lightdm` to auto-logon (if desired) and define `Openbox` as the
    default window manager by adding theses configuration lines on
    `/etc/lightdm/lightdm.conf`:

    ```
    [Seat:*]
    autologin-user=<username>
    user-session=openbox
    ```

    If you have a multi-seat setup you can constrain the application of
    theses rule to a specific seat. Exemple for a `seat-1`, place theses
    rule below `[Seat:seat-1]`.
 
3.  Tell `Openbox` to launch `Attract-Mode` on startup. Create the file
    `$HOME/.config/openbox/autostart` and put the following into:

    ```
    # Launch Attract Mode
    /usr/local/bin/15khz-attract &
    ```

    Don't forget to add the `&` char in the end. More information in the
    [official documentation](http://openbox.org/wiki/Help:Autostart).

### Change screen resolution and execute a command

A script is provided with this package that allows you to change the
resolution on the fly, executes a program, then reverts back to original
resolution when program quits:

```bash
$ OUTPUT15KHZ=VGA1 15khz-change-res-exec 320 240 50 firefox
```

The example command above sets the resolution of the screen connected to the 
output `VGA1` at 320x240 with a refresh rate of 50hz then launch 
firefox.

Internally, the 15khz modeline is computed on the fly using the 
`switchres` utility made by `Calamity`, the author of the Groovymame patch.

Version scheme
--------------

The versionning used by this project follows this pattern: 

```
<ubuntu-release-code>_<ubuntu-kernel-version>_<mame-version>_<pkg-version>
```

The `<pkg-version>` is incremented for new releases having the sames parts
version.

Doing things by yourself
------------------------

This last section contains somes guides to patch and compiles things by
yourself, without the use of the provided Makefile. This can be useful if
you target another operating system or your system specifications is not
covered by this package.

### Patch and build the kernel

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
    
#### Patch and build Xorg nouveau drivers for Nvidia cards 

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

### Patch and compile Mame with the Groovymame patch

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

Thanks
------

I would like to thank `Calamity` the author of `GroovyArcade`,
`Groovymame` and `switchres` and other guys of the [arcadecontrol
forum](http://forum.arcadecontrols.com) for their work and help on theses
great pieces of code and for their 15khz knowledge, hacks and tweaks.
