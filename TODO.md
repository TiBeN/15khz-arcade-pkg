15khz-arcade-pkg TODO
=====================

-    New X instance layout: PulseAudio: select default device
-    [WIP] - Add tag on the changelog of the nouveau driver APT package to prevent apt
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
-    [WIP] Kernel: Add suffix to kernel name (+patched) to be sure to delete
     the good one
-    15khz-change-res: handle cases:
     - When output is off by default
     - When output as the same res as beeing tested
-    Add support for "attractmode" frontend ?
-    Add support + doc for "One CRT Only" Xorg config layout
