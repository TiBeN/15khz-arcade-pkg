# 15khz Arcade PKG Makefile
# 
# This makefile automates deliverables
# production

SHELL = /bin/sh
DESTDIR = /usr/local

UBUNTU_VERSION = wily
KERNEL_BASE_VERSION = 4.2.0
KERNEL_ABI_NUMBER = 22
KERNEL_UPLOAD_NUMBER = 27
KERNEL_GIT_URL = git://kernel.ubuntu.com/ubuntu/ubuntu-$(UBUNTU_VERSION).git
KERNEL_GIT_TAG = Ubuntu-$(KERNEL_BASE_VERSION)-$(KERNEL_ABI_NUMBER).$(KERNEL_UPLOAD_NUMBER)

KERNEL_SRC_PKG = vendor/ubuntu-$(UBUNTU_VERSION).tar.gz
LINUX_HEADERS_ALL_APT = linux-headers-$(KERNEL_BASE_VERSION)-$(KERNEL_ABI_NUMBER)
LINUX_HEADERS_ALL_DEB = vendor/$(LINUX_HEADERS_ALL_APT)_$(KERNEL_BASE_VERSION)-$(KERNEL_ABI_NUMBER).$(KERNEL_UPLOAD_NUMBER)+patched15khz_all.deb
LINUX_HEADERS_GENERIC_APT = linux-headers-$(KERNEL_BASE_VERSION)-$(KERNEL_ABI_NUMBER)-generic
LINUX_HEADERS_GENERIC_DEB = vendor/$(LINUX_HEADERS_GENERIC_APT)_$(KERNEL_BASE_VERSION)-$(KERNEL_ABI_NUMBER).$(KERNEL_UPLOAD_NUMBER)+patched15khz_amd64.deb
LINUX_IMAGE_APT = linux-image-$(KERNEL_BASE_VERSION)-$(KERNEL_ABI_NUMBER)-generic
LINUX_IMAGE_DEB = vendor/$(LINUX_IMAGE_APT)_$(KERNEL_BASE_VERSION)-$(KERNEL_ABI_NUMBER).$(KERNEL_UPLOAD_NUMBER)+patched15khz_amd64.deb

LINUX_15KHZ_PATCH = src/linux-4.2.diff
LINUX_AT9200_PATCH = src/patch-3.19/ati9200_pllfix-3.19.diff
LINUX_AVGA3000_PATCH = src/patch-3.19/avga3000-3.19.diff

GROOVYMAME_BIN = vendor/mame/mame64
MAME_SRC_PKG = vendor/mame0168s.zip
MAME_SRC_PKG_URL = http://mamedev.org/downloader.php?file=mame0168/mame0168s.zip
GROOVYMAME_HI_PATCH = vendor/groovymame-patchs/hi_0168.diff
GROOVYMAME_HI_PATCH_URL = https://54c0ab1f0b10beedc11517491db5e9770a1c66c6.googledrive.com/host/0B5iMjDor3P__aEFpcVNkVW5jbEE/v0.168_015k/hi_0168.diff
GROOVYMAME_PATCH = vendor/groovymame-patchs/0164_groovymame_015h.diff
GROOVYMAME_PATCH_URL = https://54c0ab1f0b10beedc11517491db5e9770a1c66c6.googledrive.com/host/0B5iMjDor3P__aEFpcVNkVW5jbEE/v0.168_015k/0168_groovymame_015k.diff

XSERVER_XORG_VIDEO_NOUVEAU_DEB_SRC = vendor/xserver-xorg-video-nouveau-1.0.11
XSERVER_XORG_VIDEO_NOUVEAU_PATCH = src/xorg-video-nouveau-1.0.11-low-res.diff
XSERVER_XORG_VIDEO_NOUVEAU_DEB_PKG = vendor/xserver-xorg-video-nouveau_1.0.11-1ubuntu3_amd64.deb

.PHONY: all install clean

.NOTPARALLEL: $(LINUX_IMAGE_DEB)

all: linux-kernel \
	 groovymame \
	 xserver-xorg-video-nouveau 

clean:
	rm -rf vendor

install:
	dpkg -i $(LINUX_HEADERS_ALL_DEB) \
		$(LINUX_HEADERS_GENERIC_DEB) \
		$(LINUX_IMAGE_DEB) \
		$(XSERVER_XORG_VIDEO_NOUVEAU_DEB_PKG)
	mkdir -p $(DESTDIR)/lib/15khz-arcade-pkg
	cp -r vendor/mame $(DESTDIR)/lib/15khz-arcade-pkg/groovymame
	cd $(DESTDIR)/lib/15khz-arcade-pkg/groovymame && make clean
	mkdir -p $(DESTDIR)/bin
	cp bin/15khz-* $(DESTDIR)/bin
	sed -i -e "7s=.*=$(DESTDIR)/lib/15khz-arcade-pkg/groovymame/mame64=" \
		$(DESTDIR)/bin/15khz-mame
	sed -i -re "4,5d" $(DESTDIR)/bin/15khz-mame
	sed -i -e "16s=.*=$(DESTDIR)/lib/15khz-arcade-pkg/groovymame/mame64=" \
		$(DESTDIR)/bin/15khz-zaphod-mame
	sed -i -re "4,5d" $(DESTDIR)/bin/15khz-zaphod-mame
	@echo "Install finished"
	@echo "Please reboot your computer to the new patched kernel"

uninstall:
	rm -r $(DESTDIR)/lib/15khz-arcade-pkg
	rm $(DESTDIR)/bin/15khz-*
	apt-get install --reinstall xserver-xorg-video-nouveau
	sudo apt-get remove $(LINUX_HEADERS_ALL_APT) \
		$(LINUX_HEADERS_GENERIC_APT) \
		$(LINUX_IMAGE_APT)
	@echo "Uninstall finished. Please reboot your computer now"

dist: 

linux-kernel: $(LINUX_IMAGE_DEB)

xserver-xorg-video-nouveau: $(XSERVER_XORG_VIDEO_NOUVEAU_DEB_PKG)

groovymame: $(GROOVYMAME_BIN)

$(LINUX_IMAGE_DEB): $(KERNEL_SRC_PKG)
	mkdir -p vendor
	rm -rf vendor/linux-source
	mkdir -p vendor/linux-source
	cd vendor/linux-source && tar xf $(realpath $(KERNEL_SRC_PKG))
	cd vendor/linux-source \
		&& patch -p1 < $(realpath $(LINUX_15KHZ_PATCH))
	cd vendor/linux-source \
		&& patch -p1 < $(realpath $(LINUX_AT9200_PATCH))
	cd vendor/linux-source \
		&& patch -p1 < $(realpath $(LINUX_AVGA3000_PATCH))
	cd vendor/linux-source \
		&& sed -i -e "1 s/)/+patched15khz)/" debian.master/changelog
	cd vendor/linux-source \
		&& env - PATH="$$PATH" fakeroot debian/rules clean
	cd vendor/linux-source \
		&& env - PATH="$$PATH" skipabi=true fakeroot debian/rules \
		binary-headers \
		binary-generic

$(KERNEL_SRC_PKG):
	mkdir -p vendor
	git clone --depth 1 --branch $(KERNEL_GIT_TAG) \
	    $(KERNEL_GIT_URL) vendor/ubuntu-$(UBUNTU_VERSION)
	(cd vendor/ubuntu-$(UBUNTU_VERSION) && git archive $(KERNEL_GIT_TAG)) \
		| gzip > $(KERNEL_SRC_PKG)
	rm -rf vendor/ubuntu-$(UBUNTU_VERSION)

$(LINUX_KERNEL_PATCH_PKG):
	mkdir -p $(dir $(LINUX_KERNEL_PATCH_PKG))
	wget -O $(LINUX_KERNEL_PATCH_PKG) "$(LINUX_KERNEL_PATCH_PKG_URL)"
	touch $(LINUX_KERNEL_PATCH_PKG)

$(XSERVER_XORG_VIDEO_NOUVEAU_DEB_PKG): $(XSERVER_XORG_VIDEO_NOUVEAU_DEB_SRC)
	mkdir -p vendor
	cd $(XSERVER_XORG_VIDEO_NOUVEAU_DEB_SRC)/src \
		&& patch < $(realpath $(XSERVER_XORG_VIDEO_NOUVEAU_PATCH))
	cd $(XSERVER_XORG_VIDEO_NOUVEAU_DEB_SRC)/ \
		&& dpkg-buildpackage -us -uc -nc

$(XSERVER_XORG_VIDEO_NOUVEAU_DEB_SRC):
	mkdir -p vendor
	cd vendor && apt-get source xserver-xorg-video-nouveau

$(GROOVYMAME_BIN): $(MAME_SRC_PKG) \
				   $(GROOVYMAME_HI_PATCH) \
				   $(GROOVYMAME_PATCH)
	rm -rf vendor/mame
	cd vendor && unzip $(realpath $(MAME_SRC_PKG))
	mkdir vendor/mame 
	cd vendor/mame && unzip ../mame.zip
	rm vendor/mame.zip
	cd vendor/mame && patch -p0 --binary < $(realpath $(GROOVYMAME_HI_PATCH))
	cd vendor/mame && patch -p0 --binary < $(realpath $(GROOVYMAME_PATCH))
	cd vendor/mame && MAKEFLAGS= MFLAGS= make

$(MAME_SRC_PKG):
	mkdir -p $(dir $(MAME_SRC_PKG))
	wget -O $(MAME_SRC_PKG) $(MAME_SRC_PKG_URL)
	touch $(MAME_SRC_PKG)

$(GROOVYMAME_HI_PATCH):
	mkdir -p $(dir $(GROOVYMAME_HI_PATCH))
	wget -O $(GROOVYMAME_HI_PATCH) $(GROOVYMAME_HI_PATCH_URL)
	touch $(GROOVYMAME_HI_PATCH)

$(GROOVYMAME_PATCH):
	mkdir -p $(dir $(GROOVYMAME_PATCH))
	wget -O $(GROOVYMAME_PATCH) $(GROOVYMAME_PATCH_URL)
	touch $(GROOVYMAME_PATCH)
