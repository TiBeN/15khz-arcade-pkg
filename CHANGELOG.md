Current
-------


- Source tree refactoring: Moved software downloads and builds to vendor/
- Updated to Ubuntu Wily, Kernel 4.2.0-22.27, Mame 0.168
- Removed Mesa nouveau_dri patch since it is now fixed in upstream
- Improved parallel handling of the makefile
- Rewritten the kernel build recipe, now following the more 
  up-to-date and simpler procedure given at 
  <https://wiki.ubuntu.com/Kernel/BuildYourOwnKernel>. 
- The linux patchs are now hosted on the repo.
- Fixed and added precision on the KMS setup in the README.md
