# 15khz Arcade PKG Makefile
# 
# This makefile automates deliverables
# production

SHELL = /bin/sh
DESTDIR = /usr/local

UBUNTU_VERSION = xenial
KERNEL_BASE_VERSION = 4.4.0
KERNEL_ABI_NUMBER = 31
KERNEL_UPLOAD_NUMBER = 50
KERNEL_GIT_URL = git://kernel.ubuntu.com/ubuntu/ubuntu-$(UBUNTU_VERSION).git
KERNEL_GIT_TAG = Ubuntu-$(KERNEL_BASE_VERSION)-$(KERNEL_ABI_NUMBER).$(KERNEL_UPLOAD_NUMBER)

KERNEL_SRC_PKG = vendor/ubuntu-$(UBUNTU_VERSION).tar.gz
LINUX_HEADERS_ALL_APT = linux-headers-$(KERNEL_BASE_VERSION)-$(KERNEL_ABI_NUMBER)
LINUX_HEADERS_ALL_DEB = vendor/$(LINUX_HEADERS_ALL_APT)_$(KERNEL_BASE_VERSION)-$(KERNEL_ABI_NUMBER).$(KERNEL_UPLOAD_NUMBER)+patched15khz_all.deb
LINUX_HEADERS_GENERIC_APT = linux-headers-$(KERNEL_BASE_VERSION)-$(KERNEL_ABI_NUMBER)-generic
LINUX_HEADERS_GENERIC_DEB = vendor/$(LINUX_HEADERS_GENERIC_APT)_$(KERNEL_BASE_VERSION)-$(KERNEL_ABI_NUMBER).$(KERNEL_UPLOAD_NUMBER)+patched15khz_amd64.deb
LINUX_IMAGE_APT = linux-image-$(KERNEL_BASE_VERSION)-$(KERNEL_ABI_NUMBER)-generic
LINUX_IMAGE_DEB = vendor/$(LINUX_IMAGE_APT)_$(KERNEL_BASE_VERSION)-$(KERNEL_ABI_NUMBER).$(KERNEL_UPLOAD_NUMBER)+patched15khz_amd64.deb
LINUX_IMAGE_EXTRA_APT = linux-image-extra-$(KERNEL_BASE_VERSION)-$(KERNEL_ABI_NUMBER)-generic
LINUX_IMAGE_EXTRA_DEB = vendor/$(LINUX_IMAGE_EXTRA_APT)_$(KERNEL_BASE_VERSION)-$(KERNEL_ABI_NUMBER).$(KERNEL_UPLOAD_NUMBER)+patched15khz_amd64.deb

LINUX_15KHZ_PATCH = src/linux-4.2.diff
LINUX_AT9200_PATCH = src/ati9200_pllfix-3.19.diff
LINUX_AVGA3000_PATCH = src/avga3000-4.4.diff

MAME_SRC_PKG_URL = https://github.com/mamedev/mame/releases/download/mame0170/mame0170s.zip
MAME_SRC_PKG = vendor/mame0170s.zip
GROOVYMAME_HI_PATCH_URL = https://54c0ab1f0b10beedc11517491db5e9770a1c66c6.googledrive.com/host/0B5iMjDor3P__aEFpcVNkVW5jbEE/v0.170_015l/hi_0170.diff
GROOVYMAME_HI_PATCH = vendor/groovymame-patchs/hi.diff
GROOVYMAME_PATCH_URL = https://54c0ab1f0b10beedc11517491db5e9770a1c66c6.googledrive.com/host/0B5iMjDor3P__aEFpcVNkVW5jbEE/v0.170_015l/0170_groovymame_015l.diff
GROOVYMAME_PATCH = vendor/groovymame-patchs/groovymame.diff
GROOVYMAME_BIN = vendor/mame/mame64

XSERVER_XORG_VIDEO_NOUVEAU_DEB_SRC = vendor/xserver-xorg-video-nouveau-1.0.12
XSERVER_XORG_VIDEO_NOUVEAU_PATCH = src/xorg-video-nouveau-1.0.12-low-res.diff
XSERVER_XORG_VIDEO_NOUVEAU_DEB_PKG = vendor/xserver-xorg-video-nouveau_1.0.12-1build2_amd64.deb

SWITCHRES_SRC_PKG_URL = http://forum.arcadecontrols.com/index.php?action=dlattach;topic=106405.0;attach=308813
SWITCHRES_SRC_PKG = vendor/SwitchResLinux-1.52.rar
SWITCHRES_BIN = vendor/switchres/switchres

VICE_SRC_PKG_URL = http://downloads.sourceforge.net/project/vice-emu/releases/vice-2.4.tar.gz?r=http%3A%2F%2Fvice-emu.sourceforge.net%2Findex.html&ts=1457259873&use_mirror=freefr
VICE_SRC_PKG = vendor/vice.tar.gz
VICE_BIN = vendor/vice-2.4/src/x64

.PHONY: all install clean

.NOTPARALLEL: $(LINUX_IMAGE_DEB)

all: linux-kernel \
     xserver-xorg-video-nouveau \
 	groovymame \
	 switchres \
	 vice

clean:
	rm -rf vendor

install:
	dpkg -i $(LINUX_HEADERS_ALL_DEB) \
		$(LINUX_HEADERS_GENERIC_DEB) \
		$(LINUX_IMAGE_DEB) \
		$(LINUX_IMAGE_EXTRA_DEB) \
		$(XSERVER_XORG_VIDEO_NOUVEAU_DEB_PKG)
	mkdir -p $(DESTDIR)/lib/15khz-arcade-pkg
	cp -r vendor/mame $(DESTDIR)/lib/15khz-arcade-pkg/groovymame
	cp -r vendor/vice-2.4 $(DESTDIR)/lib/15khz-arcade-pkg/vice
	cd $(DESTDIR)/lib/15khz-arcade-pkg/groovymame && make clean
	cp vendor/switchres/switchres $(DESTDIR)/lib/15khz-arcade-pkg
	mkdir -p $(DESTDIR)/bin
	cp bin/15khz-* $(DESTDIR)/bin
	# Adjust paths of binaries
	# Mame
	sed -i -e "7s=.*=$(DESTDIR)/lib/15khz-arcade-pkg/groovymame/mame64 \"\$$@\"=" \
		$(DESTDIR)/bin/15khz-mame
	sed -i -re "4,5d" $(DESTDIR)/bin/15khz-mame
	sed -i -e "16s=.*=$(DESTDIR)/lib/15khz-arcade-pkg/groovymame/mame64 \"\$$@\"=" \
		$(DESTDIR)/bin/15khz-zaphod-mame
	sed -i -re "4,5d" $(DESTDIR)/bin/15khz-zaphod-mame
	# Change res exec
	sed -i -e "11s=.*=switchres\=$(DESTDIR)/lib/15khz-arcade-pkg/switchres=" \
		$(DESTDIR)/bin/15khz-change-res-exec
	sed -i -re "10d" $(DESTDIR)/bin/15khz-change-res-exec
	# FS-UAE
	sed -i \
		-e "8s=.*=declare changeresbin\=$(DESTDIR)/bin/15khz-change-res-exec=" \
		$(DESTDIR)/bin/15khz-fs-uae
	sed -i -re "4,5d" $(DESTDIR)/bin/15khz-fs-uae
	# Hatari
	sed -i \
		-e "8s=.*=declare changeresbin\=$(DESTDIR)/bin/15khz-change-res-exec=" \
		$(DESTDIR)/bin/15khz-hatari
	sed -i -re "4,5d" $(DESTDIR)/bin/15khz-hatari
	# Vice
	sed -i \
		-e "7s=.*=declare x64\=$(DESTDIR)/lib/15khz-arcade-pkg/vice/src/x64=" \
		$(DESTDIR)/bin/15khz-x64
	sed -i \
		-e "8s=.*=declare changeresbin\=$(DESTDIR)/bin/15khz-change-res-exec=" \
		$(DESTDIR)/bin/15khz-x64
	sed -i \
		-e "9s=.*=declare rompath\=$(DESTDIR)/lib/15khz-arcade-pkg/vice/data/C64=" \
		$(DESTDIR)/bin/15khz-x64
	sed -i \
		-e "10s=.*=declare romdrivepath\=$(DESTDIR)/lib/15khz-arcade-pkg/vice/data/DRIVES=" \
		$(DESTDIR)/bin/15khz-x64
	sed -i -re "4,5d" $(DESTDIR)/bin/15khz-x64
	@echo "Install finished"
	@echo "Please reboot your computer to the new patched kernel"

uninstall:
	-rm -r $(DESTDIR)/lib/15khz-arcade-pkg
	-rm $(DESTDIR)/bin/15khz-*
	-apt-get install --reinstall xserver-xorg-video-nouveau
	-sudo apt-get remove $(LINUX_HEADERS_ALL_APT) \
		$(LINUX_HEADERS_GENERIC_APT) \
		$(LINUX_IMAGE_APT)
	# Reinstall latest generic image/headers packages to avoid 
	# release the system without any kernel (!!). This should 
	# happen if the patched installed kernel is of the same version
	# as the distribution's current one.
	-sudo apt-get install linux-image-generic linux-headers-generic
	@echo "Uninstall finished. Please reboot your computer now"

dist: 

linux-kernel: $(LINUX_IMAGE_DEB)

xserver-xorg-video-nouveau: $(XSERVER_XORG_VIDEO_NOUVEAU_DEB_PKG)

groovymame: $(GROOVYMAME_BIN)

switchres: $(SWITCHRES_BIN)

vice: $(VICE_BIN)

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

$(SWITCHRES_BIN): $(SWITCHRES_SRC_PKG)	
	mkdir -p $(dir $(SWITCHRES_BIN))
	cd $(dir $(SWITCHRES_BIN)) \
		&& unrar e $(realpath $(SWITCHRES_SRC_PKG))
	chmod +x $(dir $(SWITCHRES_BIN))/version.sh
	cd $(dir $(SWITCHRES_BIN)) && make

$(SWITCHRES_SRC_PKG):
	mkdir -p $(dir $(SWITCHRES_SRC_PKG))
	wget -O $(SWITCHRES_SRC_PKG) "$(SWITCHRES_SRC_PKG_URL)"
	touch $(SWITCHRES_SRC_PKG)

$(VICE_BIN): $(VICE_SRC_PKG)
	mkdir -p vendor
	cd vendor \
		&& tar xf $(realpath $(VICE_SRC_PKG))
	cd vendor/vice-2.4 \
		&& ./configure --enable-sdlui --disable-ffmpeg \
		&& make

$(VICE_SRC_PKG):
	mkdir -p $(dir $(VICE_SRC_PKG))
	wget -O $(VICE_SRC_PKG) "$(VICE_SRC_PKG_URL)"
	touch $(VICE_SRC_PKG)
