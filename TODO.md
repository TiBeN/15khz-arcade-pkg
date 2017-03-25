15khz-arcade-pkg TODO
=====================

- [ ] New X instance layout: PulseAudio: select default device
- [ ] Add some links and reference at the end of the documentation
- [ ] Makefile: Create `dist` target 
- [ ] Do some photos of the results
- [ ] Make build and install of nvidia driver optional
- [ ] Build "attractmode" frontend with the Makefile
- [ ] Add some tips to configure emulators
    
    Add tips to how adjust horizontal overscan with groovymame

- [ ] Write documentation about `new X instance` layout
- [ ] Configure the system to launch attractmode at boot, without
     desktop environment
- [x] Build Hatari 2.0.0 with the Makefile (2.0.0 added a vsync feature)
- [ ] Fix switchres core dump (since 16.10) issue. 

    First, remove its use from the emulator wrappers: Either define the
    modeline statically on the wrapper or, when possible, in xorg.conf 
    (possible with Hatari for example). Explain how to and why.

- [ ] Write documentation on how to make a multiseat (2 graphics cards)
     setup.

- [ ] Rename the project 15khz-ubuntu-pkg, or something like that
