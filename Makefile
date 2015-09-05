
# 15khz Arcade PKG Makefile
# 
# This makefile automates deliverables
# production

SHELL = /bin/sh
PREFIX = /usr/local
BUILDDIR = build
TMPDIR = /tmp/15khz-arcade-pkg

LINUX_VERSION = 3
LINUX_MAJ_REV = 19
LINUX_MIN_REV = 0

LINUX_SHORT_VERSION = $(LINUX_VERSION).$(LINUX_MAJ_REV)
LINUX_COMPLETE_VERSION = $(LINUX_VERSION).$(LINUX_MAJ_REV).$(LINUX_MIN_REV)

UBUNTU_VERSION = vivid
LINUX_UBUNTU_VERSION = Ubuntu-3.19.0-25.26
LINUX_UBUNTU_GIT_REPO_URL = git://kernel.ubuntu.com/ubuntu/ubuntu-$(UBUNTU_VERSION).git

LINUX_KERNEL_SRC_PKG = $(BUILDDIR)/pkg/kernel/ubuntu-$(UBUNTU_VERSION).tar.gz
LINUX_KERNEL_PATCH_PKG = $(BUILDDIR)/pkg/kernel/kernel-patch-$(LINUX_SHORT_VERSION).zip
LINUX_KERNEL_PATCH_PKG_URL = http://forum.arcadecontrols.com/index.php?action=dlattach;topic=107620.0;attach=324731
LINUX_KERNEL_DEB_PKG = $(BUILDDIR)/linux-image-patched15khz-10.00.Custom_amd64.deb

MAME_SRC_PKG = $(BUILDDIR)/pkg/mame/mame0164s.zip
MAME_SRC_PKG_URL = http://mamedev.org/downloader.php?file=mame0164/mame0164s.zip
MAME_HI_PATCH = $(BUILDDIR)/pkg/mame/hi_0164.diff
MAME_HI_PATCH_URL = https://54c0ab1f0b10beedc11517491db5e9770a1c66c6.googledrive.com/host/0B5iMjDor3P__aEFpcVNkVW5jbEE/v0.164_015h/hi_0164.diff
MAME_GROOVY_PATCH = $(BUILDDIR)/pkg/mame/0164_groovymame_015h.diff
MAME_GROOVY_PATCH_URL = https://54c0ab1f0b10beedc11517491db5e9770a1c66c6.googledrive.com/host/0B5iMjDor3P__aEFpcVNkVW5jbEE/v0.164_015h/0164_groovymame_015h.diff
GROOVYMAME_BIN = $(BUILDDIR)/groovymame64/mame64

XSERVER_XORG_VIDEO_NOUVEAU_DEB_SRC_DIR = $(BUILDDIR)/pkg/xorg-video-nouveau-deb-src
XSERVER_XORG_VIDEO_NOUVEAU_PATCH = src/xorg-video-nouveau-1.0.11-low-res.diff
XSERVER_XORG_VIDEO_NOUVEAU_DEB_PKG = $(BUILDDIR)/xserver-xorg-video-nouveau_1.0.11-1ubuntu2build1_amd64.deb

LIBGL1_MESA_DRI_DEB_SRC_DIR = $(BUILDDIR)/pkg/libgl1-mesa-dri
LIBGL1_MESA_DRI_PATCH = src/libgl1-mesa-dri-10.5.2-zaphodheads.diff
LIBGL1_MESA_DRI_PATCHED_NOUVEAU_DRI_LIB = $(BUILDDIR)/nouveau_dri.so

.PHONY: all install clean

all: $(LINUX_KERNEL_DEB_PKG) \
	 $(GROOVYMAME_BIN) \
	 $(XSERVER_XORG_VIDEO_NOUVEAU_DEB_PKG) \
	 $(LIBGL1_MESA_DRI_PATCHED_NOUVEAU_DRI_LIB)

clean:
	rm -rf $(BUILDDIR)

install:
	dpkg -i $(LINUX_KERNEL_DEB_PKG)
	dpkg -i $(XSERVER_XORG_VIDEO_NOUVEAU_DEB_PKG)
	mkdir -p $(PREFIX)/lib/15khz-arcade-pkg
	cp -r $(BUILDDIR)/groovymame64 $(PREFIX)/lib/15khz-arcade-pkg/
	cp $(BUILDDIR)/nouveau_dri.so $(PREFIX)/lib/15khz-arcade-pkg/
	mkdir -p $(PREFIX)/bin
	cp src/bin/gm-15khz $(PREFIX)/bin/
	@echo "Install finished"
	@echo "Please reboot your computer using the new -patched15khz kernel"

uninstall:
	rm -r $(PREFIX)/lib/15khz-arcade-pkg
	rm $(PREFIX)/bin/gm-15khz
	apt-get install --reinstall xserver-xorg-video-nouveau
	@echo "Uninstall finished."
	@echo
	@echo "The patched Linux kernel can't be safely uninstalled automatically while running."
	@echo "Don't forget to uninstall it manually after booted to another kernel using:"
	@echo "sudo apt-get remove linux-image-<version>-patched15khz linux-headers-<version>-patched15khz"


# Deliveries recipes

$(LINUX_KERNEL_DEB_PKG): $(LINUX_KERNEL_SRC_PKG) \
						 $(LINUX_KERNEL_PATCH_PKG)
	mkdir -p $(dir $(LINUX_KERNEL_DEB_PKG))
	rm -rf $(TMPDIR)
	mkdir -p $(TMPDIR)/linux-source
	cd $(TMPDIR)/linux-source && tar xf $(realpath $(LINUX_KERNEL_SRC_PKG))
	cd $(TMPDIR) && unzip $(realpath $(LINUX_KERNEL_PATCH_PKG))
	cd $(TMPDIR)/linux-source \
		&& patch -p1 < ../patch-$(LINUX_SHORT_VERSION)/ati9200_pllfix-$(LINUX_SHORT_VERSION).diff
	cd $(TMPDIR)/linux-source \
	   	&& patch -p1 < ../patch-$(LINUX_SHORT_VERSION)/avga3000-$(LINUX_SHORT_VERSION).diff
	cd $(TMPDIR)/linux-source \
		&& patch -p1 < ../patch-$(LINUX_SHORT_VERSION)/linux-$(LINUX_SHORT_VERSION).diff
	cd $(TMPDIR)/linux-source \
		&& cp -vi /boot/config-`uname -r` .config
	cd $(TMPDIR)/linux-source \
		&& make oldconfig
	cd $(TMPDIR)/linux-source \
		&& KERN_DIR=$(TMPDIR)/linux-source make-kpkg clean 
	cd $(TMPDIR)/linux-source \
		&& KERN_DIR=$(TMPDIR)/linux-source fakeroot make-kpkg \
			--initrd \
			--append-to-version "-patched15khz" \
			kernel-image kernel-headers
	mv $(TMPDIR)/linux-image-*-patched15khz_*-patched15khz-10.00.Custom_amd64.deb \
		$(BUILDDIR)/
	mv $(TMPDIR)/linux-headers-*-patched15khz_*-patched15khz-10.00.Custom_amd64.deb \
		$(BUILDDIR)/
	rm -f $(LINUX_KERNEL_DEB_PKG)
	cd $(BUILDDIR) && ln -s linux-image-*-patched15khz_*-patched15khz-10.00.Custom_amd64.deb \
		../$(LINUX_KERNEL_DEB_PKG)
	rm -r $(TMPDIR)

$(XSERVER_XORG_VIDEO_NOUVEAU_DEB_PKG): $(XSERVER_XORG_VIDEO_NOUVEAU_DEB_SRC_DIR)
	mkdir -p $(dir $(XSERVER_XORG_VIDEO_NOUVEAU_DEB_PKG))
	rm -rf $(TMPDIR)
	mkdir -p $(TMPDIR)
	cp -r $(XSERVER_XORG_VIDEO_NOUVEAU_DEB_SRC_DIR)/* $(TMPDIR)
	cd $(TMPDIR)/xserver-xorg-video-nouveau-1.0.11/src \
		&& patch < $(realpath $(XSERVER_XORG_VIDEO_NOUVEAU_PATCH))
	cd $(TMPDIR)/xserver-xorg-video-nouveau-1.0.11 \
		&& dpkg-buildpackage -us -uc -nc
	cp $(TMPDIR)/xserver-xorg-video-nouveau_1.0.11-1ubuntu2build1_amd64.deb \
		$(XSERVER_XORG_VIDEO_NOUVEAU_DEB_PKG)
	rm -r $(TMPDIR)

$(LIBGL1_MESA_DRI_PATCHED_NOUVEAU_DRI_LIB): $(LIBGL1_MESA_DRI_DEB_SRC_DIR)
	mkdir -p $(dir $(LIBGL1_MESA_DRI_PATCHED_NOUVEAU_DRI_LIB))
	rm -rf $(TMPDIR)
	mkdir -p $(TMPDIR)
	cp -r $(LIBGL1_MESA_DRI_DEB_SRC_DIR)/* $(TMPDIR)
	cd $(TMPDIR)/mesa-10.5.2/src \
		&& patch -p0 < $(realpath $(LIBGL1_MESA_DRI_PATCH))
	cd $(TMPDIR)/mesa-10.5.2 \
		&& dpkg-buildpackage -us -uc -nc
	cp $(TMPDIR)/mesa-10.5.2/build/dri/x86_64-linux-gnu/gallium/nouveau_dri.so \
		$(LIBGL1_MESA_DRI_PATCHED_NOUVEAU_DRI_LIB)

$(GROOVYMAME_BIN): $(MAME_SRC_PKG) \
				   $(MAME_HI_PATCH) \
				   $(MAME_GROOVY_PATCH)
	rm -rf $(TMPDIR)
	mkdir -p $(TMPDIR)
	cd $(TMPDIR) && unzip $(realpath $(MAME_SRC_PKG))
	cd $(TMPDIR) && unzip $(TMPDIR)/mame.zip
	cd $(TMPDIR) && patch -p0 --binary < $(realpath $(MAME_HI_PATCH))
	cd $(TMPDIR) && patch -p0 --binary < $(realpath $(MAME_GROOVY_PATCH))
	cd $(TMPDIR) && make
	cp -r $(TMPDIR)/* $(BUILDDIR)/groovymame64
	rm -rf $(TMPDIR)
	
# Dependencies recipes

$(LINUX_KERNEL_SRC_PKG):
	mkdir -p $(TMPDIR)
	git clone $(LINUX_UBUNTU_GIT_REPO_URL) $(TMPDIR)/ubuntu-$(UBUNTU_VERSION)
	mkdir -p $(dir $(LINUX_KERNEL_SRC_PKG))
	(cd $(TMPDIR)/ubuntu-$(UBUNTU_VERSION) && git archive $(LINUX_UBUNTU_VERSION)) \
		| gzip > $(LINUX_KERNEL_SRC_PKG)
	rm -rf $(TMPDIR)

$(LINUX_KERNEL_PATCH_PKG):
	mkdir -p $(dir $(LINUX_KERNEL_PATCH_PKG))
	wget -O $(LINUX_KERNEL_PATCH_PKG) "$(LINUX_KERNEL_PATCH_PKG_URL)"
	touch $(LINUX_KERNEL_PATCH_PKG)

$(XSERVER_XORG_VIDEO_NOUVEAU_DEB_SRC_DIR):
	mkdir -p $(XSERVER_XORG_VIDEO_NOUVEAU_DEB_SRC_DIR)
	cd $(XSERVER_XORG_VIDEO_NOUVEAU_DEB_SRC_DIR) \
		&& apt-get source xserver-xorg-video-nouveau

$(LIBGL1_MESA_DRI_DEB_SRC_DIR):
	mkdir -p $(LIBGL1_MESA_DRI_DEB_SRC_DIR)
	cd $(LIBGL1_MESA_DRI_DEB_SRC_DIR) \
		&& apt-get source libgl1-mesa-dri

$(MAME_SRC_PKG):
	mkdir -p $(dir $(MAME_SRC_PKG))
	wget -O $(MAME_SRC_PKG) $(MAME_SRC_PKG_URL)
	touch $(MAME_SRC_PKG)

$(MAME_HI_PATCH):
	mkdir -p $(dir $(MAME_HI_PATCH))
	wget -O $(MAME_HI_PATCH) $(MAME_HI_PATCH_URL)
	touch $(MAME_HI_PATCH)

$(MAME_GROOVY_PATCH):
	mkdir -p $(dir $(MAME_GROOVY_PATCH))
	wget -O $(MAME_GROOVY_PATCH) $(MAME_GROOVY_PATCH_URL)
	touch $(MAME_GROOVY_PATCH)
