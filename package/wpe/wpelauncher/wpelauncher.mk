###############################################################################
#
# WPELauncher
#
################################################################################

WPELAUNCHER_VERSION = 9c8c85c278687f5cd658dd8e6cdfaaf3f035e8e9
WPELAUNCHER_SITE = $(call github,WebPlatformForEmbedded,WPEWebKitLauncher,$(WPELAUNCHER_VERSION))

WPELAUNCHER_DEPENDENCIES = wpewebkit

define WPELAUNCHER_BINS
	$(INSTALL) -D -m 0644 package/wpe/wpelauncher/wpe.{txt,conf} $(BINARIES_DIR)/
	$(INSTALL) -D -m 0755 package/wpe/wpelauncher/wpe $(TARGET_DIR)/usr/bin
endef

define WPELAUNCHER_AUTOSTART
	$(INSTALL) -D -m 0755 package/wpe/wpelauncher/S90wpe $(TARGET_DIR)/etc/init.d
endef

WPELAUNCHER_POST_INSTALL_TARGET_HOOKS += WPELAUNCHER_BINS

ifeq ($(BR2_PACKAGE_PLUGIN_WEBKITBROWSER),)
WPELAUNCHER_POST_INSTALL_TARGET_HOOKS += WPELAUNCHER_AUTOSTART
endif

define GF_CUSTOM
	$(INSTALL) -D -m 0644 package/wpe/wpelauncher/wpe.service $(TARGET_DIR)/etc/systemd/system
	$(INSTALL) -d -m 0755 $(TARGET_DIR)/etc/fonts/conf.d
	$(INSTALL) -D -m 0644 package/wpe/wpelauncher/95-hinting.conf $(TARGET_DIR)/etc/fonts/conf.d
	$(INSTALL) -d -m 0755 $(TARGET_DIR)/etc/systemd/journald.conf.d/
	$(INSTALL) -D -m 0644 package/wpe/wpelauncher/journald-override.conf $(TARGET_DIR)/etc/systemd/journald.conf.d/journald-override.conf
	$(INSTALL) -d -m 0755 $(TARGET_DIR)/root/.ssh
	$(INSTALL) -D -m 0644 package/wpe/wpelauncher/authorized_keys $(TARGET_DIR)/root/.ssh/authorized_keys
	$(INSTALL) -D -m 0644 package/wpe/wpelauncher/.profile $(TARGET_DIR)/root/.profile
	$(INSTALL) -D -m 0644 package/wpe/wpelauncher/.bashrc $(TARGET_DIR)/root/.bashrc
	$(INSTALL) -D -m 0644 package/wpe/wpelauncher/.bashrc_local $(TARGET_DIR)/root/.bashrc_local
	$(INSTALL) -D -m 0644 package/wpe/wpelauncher/.bash_aliases $(TARGET_DIR)/root/.bash_aliases
	$(INSTALL) -D -m 0644 package/wpe/wpelauncher/drop-splash.mp4 $(TARGET_DIR)/root/drop-splash.mp4
	$(INSTALL) -d -m 0755 $(TARGET_DIR)/usr/share/fonts/roboto
	$(INSTALL) -D -m 0644 package/wpe/wpelauncher/RobotoCondensed-*.ttf $(TARGET_DIR)/usr/share/fonts/roboto/
	$(INSTALL) -D -m 644 package/wpe/wpelauncher/bootsplash.service \
		$(TARGET_DIR)/usr/lib/systemd/system/bootsplash.service
	mkdir -p $(TARGET_DIR)/etc/systemd/system/sysinit.target.wants
	ln -fs ../../../../usr/lib/systemd/system/bootsplash.service \
		$(TARGET_DIR)/etc/systemd/system/sysinit.target.wants/bootsplash.service
endef

WPELAUNCHER_POST_INSTALL_TARGET_HOOKS += GF_CUSTOM

$(eval $(cmake-package))
