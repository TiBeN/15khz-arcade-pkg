
# 15khz Arcade PKG Makefile
# 
# This makefile automates deliverables
# production

SHELL = /bin/sh
PREFIX = /usr/local
BUILDDIR = build
TMPDIR = /tmp/15khz-arcade-pkg

UBUNTU_VERSION = wily
KERNEL_BASE_VERSION = 4.2.0
KERNEL_ABI_NUMBER = 22
KERNEL_UPLOAD_NUMBER = 27
KERNEL_GIT_URL = git://kernel.ubuntu.com/ubuntu/ubuntu-$(UBUNTU_VERSION).git
KERNEL_GIT_TAG = Ubuntu-$(KERNEL_BASE_VERSION)-$(KERNEL_ABI_NUMBER).$(KERNEL_UPLOAD_NUMBER)

KERNEL_SRC_PKG = $(BUILDDIR)/pkg/kernel/ubuntu-$(UBUNTU_VERSION).tar.gz
LINUX_HEADERS_ALL_DEB = $(BUILDDIR)/linux-headers-$(KERNEL_BASE_VERSION)-$(KERNEL_ABI_NUMBER)_$(KERNEL_BASE_VERSION)-$(KERNEL_ABI_NUMBER).$(KERNEL_UPLOAD_NUMBER)+patched15khz_all.deb
LINUX_HEADERS_GENERIC_DEB = $(BUILDDIR)/linux-headers-$(KERNEL_BASE_VERSION)-$(KERNEL_ABI_NUMBER)-generic_$(KERNEL_BASE_VERSION)-$(KERNEL_ABI_NUMBER).$(KERNEL_UPLOAD_NUMBER)+patched15khz_amd64.deb
LINUX_IMAGE_DEB = $(BUILDDIR)/linux-image-$(KERNEL_BASE_VERSION)-$(KERNEL_ABI_NUMBER)-generic_$(KERNEL_BASE_VERSION)-$(KERNEL_ABI_NUMBER).$(KERNEL_UPLOAD_NUMBER)+patched15khz_amd64.deb

#LINUX_15KHZ_PATCH = src/patch-3.19/linux-3.19.diff
LINUX_15KHZ_PATCH = src/linux-4.2.diff

LINUX_AT9200_PATCH = src/patch-3.19/ati9200_pllfix-3.19.diff
LINUX_AVGA3000_PATCH = src/patch-3.19/avga3000-3.19.diff

MAME_SRC_PKG = $(BUILDDIR)/pkg/mame/mame0168s.zip
MAME_SRC_PKG_URL = http://mamedev.org/downloader.php?file=mame0168/mame0168s.zip
MAME_HI_PATCH = $(BUILDDIR)/pkg/mame/hi_0168.diff
MAME_HI_PATCH_URL = https://54c0ab1f0b10beedc11517491db5e9770a1c66c6.googledrive.com/host/0B5iMjDor3P__aEFpcVNkVW5jbEE/v0.168_015k/hi_0168.diff
MAME_GROOVY_PATCH = $(BUILDDIR)/pkg/mame/0164_groovymame_015h.diff
MAME_GROOVY_PATCH_URL = https://54c0ab1f0b10beedc11517491db5e9770a1c66c6.googledrive.com/host/0B5iMjDor3P__aEFpcVNkVW5jbEE/v0.168_015k/0168_groovymame_015k.diff
GROOVYMAME_BIN = $(BUILDDIR)/groovymame64/mame64

XSERVER_XORG_VIDEO_NOUVEAU_DEB_SRC_DIR = $(BUILDDIR)/pkg/xorg-video-nouveau-deb-src
XSERVER_XORG_VIDEO_NOUVEAU_PATCH = src/xorg-video-nouveau-1.0.11-low-res.diff
XSERVER_XORG_VIDEO_NOUVEAU_DEB_PKG = $(BUILDDIR)/xserver-xorg-video-nouveau_1.0.11-1ubuntu3_amd64.deb

.PHONY: all install clean

.NOTPARALLEL: $(LINUX_IMAGE_DEB)

all: $(LINUX_IMAGE_DEB) \
	 $(GROOVYMAME_BIN) \
	 $(XSERVER_XORG_VIDEO_NOUVEAU_DEB_PKG) 

clean:
	rm -rf $(BUILDDIR)

install:
	dpkg -i $(LINUX_HEADERS_ALL_DEB) \
		$(LINUX_HEADERS_GENERIC_DEB) \
		$(LINUX_IMAGE_DEB) \
		$(XSERVER_XORG_VIDEO_NOUVEAU_DEB_PKG)
	mkdir -p $(PREFIX)/lib/15khz-arcade-pkg
	cp -r $(BUILDDIR)/groovymame64 $(PREFIX)/lib/15khz-arcade-pkg/
	mkdir -p $(PREFIX)/bin
	cp src/bin/gm-15khz $(PREFIX)/bin/
	@echo "Install finished"
	@echo "Please reboot your computer to the new patched kernel"

uninstall:
	rm -r $(PREFIX)/lib/15khz-arcade-pkg
	rm $(PREFIX)/bin/gm-15khz
	apt-get install --reinstall xserver-xorg-video-nouveau
	sudo apt-get remove $(notdir $(LINUX_HEADERS_ALL_DEB)) \
		$(notdir $(LINUX_HEADERS_GENERIC_DEB)) \
		$(notdir $(LINUX_IMAGE_DEB))
	@echo "Uninstall finished. Please reboot your computer now"

dist: 

linux-kernel: $(KERNEL_IMAGE_DEB)

nouveau: $(XSERVER_XORG_VIDEO_NOUVEAU_DEB_PKG)

mame: $(GROOVYMAME_BIN)

# Deliveries recipes

$(LINUX_IMAGE_DEB): $(KERNEL_SRC_PKG)
	mkdir -p $(dir $(LINUX_IMAGE_DEB))
	rm -rf $(TMPDIR)/linux-source
	mkdir -p $(TMPDIR)/linux-source
	cd $(TMPDIR)/linux-source && tar xf $(realpath $(KERNEL_SRC_PKG))
	cd $(TMPDIR)/linux-source \
		&& patch -p1 < $(realpath $(LINUX_15KHZ_PATCH))
	cd $(TMPDIR)/linux-source \
		&& patch -p1 < $(realpath $(LINUX_AT9200_PATCH))
	cd $(TMPDIR)/linux-source \
		&& patch -p1 < $(realpath $(LINUX_AVGA3000_PATCH))
	cd $(TMPDIR)/linux-source && sed -i -e "1 s/)/+patched15khz)/" debian.master/changelog
	cd $(TMPDIR)/linux-source && env - PATH="$$PATH" fakeroot debian/rules clean
	cd $(TMPDIR)/linux-source && env - PATH="$$PATH" skipabi=true fakeroot debian/rules \
		binary-headers \
		binary-generic
	mv $(TMPDIR)/$(notdir $(LINUX_HEADERS_ALL_DEB)) $(LINUX_HEADERS_ALL_DEB)
	mv $(TMPDIR)/$(notdir $(LINUX_HEADERS_GENERIC_DEB)) $(LINUX_HEADERS_GENERIC_DEB)
	mv $(TMPDIR)/$(notdir $(LINUX_IMAGE_DEB)) $(LINUX_IMAGE_DEB)
	rm -r $(TMPDIR)/linux-source

$(XSERVER_XORG_VIDEO_NOUVEAU_DEB_PKG): $(XSERVER_XORG_VIDEO_NOUVEAU_DEB_SRC_DIR)
	mkdir -p $(dir $(XSERVER_XORG_VIDEO_NOUVEAU_DEB_PKG))
	rm -rf $(TMPDIR)/nouveau
	mkdir -p $(TMPDIR)/nouveau
	cp -r $(XSERVER_XORG_VIDEO_NOUVEAU_DEB_SRC_DIR)/* $(TMPDIR)/nouveau
	cd $(TMPDIR)/nouveau/xserver-xorg-video-nouveau-1.0.11/src \
		&& patch < $(realpath $(XSERVER_XORG_VIDEO_NOUVEAU_PATCH))
	cd $(TMPDIR)/nouveau/xserver-xorg-video-nouveau-1.0.11 \
		&& dpkg-buildpackage -us -uc -nc
	cp $(TMPDIR)/nouveau/xserver-xorg-video-nouveau_1.0.11-1ubuntu3_amd64.deb \
		$(XSERVER_XORG_VIDEO_NOUVEAU_DEB_PKG)
	rm -r $(TMPDIR)/nouveau

$(GROOVYMAME_BIN): $(MAME_SRC_PKG) \
				   $(MAME_HI_PATCH) \
				   $(MAME_GROOVY_PATCH)
	rm -rf $(TMPDIR)/mame
	mkdir -p $(TMPDIR)/mame
	cd $(TMPDIR)/mame && unzip $(realpath $(MAME_SRC_PKG))
	cd $(TMPDIR)/mame && unzip $(TMPDIR)/mame/mame.zip
	cd $(TMPDIR)/mame && patch -p0 --binary < $(realpath $(MAME_HI_PATCH))
	cd $(TMPDIR)/mame && patch -p0 --binary < $(realpath $(MAME_GROOVY_PATCH))
	cd $(TMPDIR)/mame && MAKEFLAGS= MFLAGS= make
	cd $(TMPDIR)/mame && rm mame.zip
	cd $(TMPDIR)/mame && make clean
	mkdir -p $(BUILDDIR)/groovymame64
	cp -r $(TMPDIR)/mame/* $(BUILDDIR)/groovymame64
	rm -rf $(TMPDIR)/mame
	
# Dependencies recipes

$(KERNEL_SRC_PKG):
	rm -rf $(TMPDIR)/ubuntu-kernel
	mkdir -p $(TMPDIR)/ubuntu-kernel
	git clone --depth 1 --branch $(KERNEL_GIT_TAG) \
	    $(KERNEL_GIT_URL) $(TMPDIR)/ubuntu-kernel/ubuntu-$(UBUNTU_VERSION)
	mkdir -p $(dir $(KERNEL_SRC_PKG))
	(cd $(TMPDIR)/ubuntu-kernel/ubuntu-$(UBUNTU_VERSION) && git archive $(KERNEL_GIT_TAG)) \
		| gzip > $(KERNEL_SRC_PKG)
	rm -rf $(TMPDIR)/ubuntu-kernel

$(LINUX_KERNEL_PATCH_PKG):
	mkdir -p $(dir $(LINUX_KERNEL_PATCH_PKG))
	wget -O $(LINUX_KERNEL_PATCH_PKG) "$(LINUX_KERNEL_PATCH_PKG_URL)"
	touch $(LINUX_KERNEL_PATCH_PKG)

$(XSERVER_XORG_VIDEO_NOUVEAU_DEB_SRC_DIR):
	mkdir -p $(XSERVER_XORG_VIDEO_NOUVEAU_DEB_SRC_DIR)
	cd $(XSERVER_XORG_VIDEO_NOUVEAU_DEB_SRC_DIR) \
		&& apt-get source xserver-xorg-video-nouveau

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
