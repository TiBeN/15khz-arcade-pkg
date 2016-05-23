15khz-arcade-pkg TODO
=====================

-    New X instance layout: PulseAudio: select default device
-    Add tag on the changelog of the nouveau driver apt package to prevent apt
     bo reinstall the original
-    Improve the documentation about the Xorg configuration 
    (step by step guide through each supported layout)
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
-    Do some tests to confirm nvidia drivers doesn't need to be patched
     anymore since 1.0.12 and remove the nvidia patching stuff (make +
     doc).
-    Add support for "attractmode" frontend ?
