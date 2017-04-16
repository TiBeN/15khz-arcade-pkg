CHANGELOG
=========

Current
-------

- Now provides Attract-Mode emulators frontend

yakkety_Ubuntu-4.8.0-45.48_0.183_1
----------------------------------

- Upgraded to Groovymame 0.183
- Now provide Hatari in version 2.0.0 (This version added a vsync feature
  which can helps in some setups) and improved its configuration in order
  to launch it real full screen and avoid tearing.
- Upgraded VICE emulator to version 3.0
- Upgraded Ubuntu version to 16.10 Yakkety Yak, kernel Ubuntu-4.8.0-45.48
- Now embed the Groovymame patch since it is not possible to download
  directly from its Google Drive since google doesn't allow direct link
  anymore.

xenial_Ubuntu-4.4.0-47.68_0.179_1
---------------------------------

- Upgraded supported kernel version to Ubuntu-4.4.0-47.68
- Upgraded to Groovymame 0.179
- Improved Xorg configuration documentation
- Added support + doc for "One CRT Only" Xorg config layout

xenial_Ubuntu-4.4.0-31.50_0.170_1
---------------------------------

- Added tag on the changelog of the patched nouveau driver APT 
  package to prevent its update by the update manager
- Fixed `Make install` doesn't install package 
  `linux-image-extra` which is required for good installation
  of the kernel.
- Upgraded supported kernel version to Ubuntu-4.4.0-31.50
- Fixed BUG : (**MAJOR**) `make uninstall` does remove the kernel if
  the patched one is of the same version of the previous one, leave 
  the system without any Kernel. Find another method to reinstall the 
  previous original.

xenial_Ubuntu-4.4.0-24.43_0.170_1
---------------------------------

- Added comments on setting the patched as default on GRUB
- Tried creating custom EDID binaries for 15khz but doesn't
  seems to work with NVIDIA
- Fixed 15khz modeline in KMS mode using Modelines provided
  with the kernel patch and improved documentation about
  KMS.
- Upgraded supported xorg nouveau drivers to 1.0.12
- Upgraded supported kernel version to Ubuntu-4.4.0-24.43
- Supported Ubuntu version is now Xenial

wily_Ubuntu-4.2.0-38.45_0.170_1
-------------------------------

- Upgraded supported kernel version to Ubuntu-4.2.0-38.45

wily_Ubuntu-4.2.0-22.27_0.170_1
-------------------------------

- Moved the documentation from the README.md to a separate file
- Added custom build support and wrapper for`Vice` emulator
- Added wrappers for `Hatari` and `FS-UAE` emulators
- Added the `15khz-change-res-exec` wrapper script to execute a command
  at a specific resolution
- Source tree refactoring: Moved software downloads and builds to vendor/
- Updated to Ubuntu Wily, Kernel 4.2.0-22.27 Mame 0.170
- Removed Mesa nouveau_dri patch since it is now fixed in upstream
- Improved parallel handling of the makefile
- Rewritten the kernel build recipe, now following the more 
  up-to-date and simpler procedure given at 
  <https://wiki.ubuntu.com/Kernel/BuildYourOwnKernel>. 
- The linux patchs are now hosted on the repo.
- Fixed and added precision on the KMS setup in the README.md
