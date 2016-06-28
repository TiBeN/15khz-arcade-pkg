15khz-arcade-pkg TODO
=====================

-    New X instance layout: PulseAudio: select default device
-    Add tag on the changelog of the nouveau driver APT package to prevent apt
     to ask to update it by the update manager
-    Improve the documentation about the Xorg configuration:
     how xorg is configured, step by step guide through the configuration of 
     each supported layout, usage depending on the configured layout
-    Add some links and reference at the end of the documentation
-    Makefile: Create `dist` target 
-    Do some photos of the results
-    Makefile: make distinction between nvidia and others :
     -   nvidia: no kernel but driver patch. 
     -   other: kernel
-    Makefile: Make an option to not compile kernel
-    Kernel: Add suffix to kernel name (+patched) to be sure to delete
     the good one
-    15khz-change-res: handle cases:
     - When output is off by default
     - When output as the same res as beeing tested
-    Add support for "attractmode" frontend ?
-    Add support + doc for "One CRT Only" Xorg config layout
-    [WIP] - Create Custom EDID file with 15khz modeline for the kernel or make
     theses provided by the 15khz kernel patch works (640x480 doesn't work since
     kernel > 3.19) to recover good Modeline on KMS boot.
-    BUG : (**MAJOR**) `make uninstall` does remove the kernel if the patched one 
     is of the same version of the previous one, leave the the system without 
     any Kernel. Find another method to reinstall the previous original
