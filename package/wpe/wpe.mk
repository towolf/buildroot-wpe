################################################################################
#
# WPE
#
################################################################################

WPE_VERSION = 4ef64d691ead0756fde395a632705211d2d91b4f
WPE_SITE = $(call github,Metrological,WebKitForWayland,$(WPE_VERSION))

WPE_INSTALL_STAGING = YES
WPE_DEPENDENCIES = host-flex host-bison host-gperf host-ruby host-pkgconf zlib \
	openssl pcre libgles libegl cairo freetype fontconfig harfbuzz icu libxml2 \
	libxslt sqlite libsoup jpeg libpng webp libinput libxkbcommon xkeyboard-config

ifeq ($(BR2_PACKAGE_NINJA),y)
WPE_DEPENDENCIES += host-ninja
WPE_EXTRA_FLAGS += \
	-G Ninja
ifeq ($(VERBOSE),1)
WPE_EXTRA_OPTIONS += -v
endif
endif

ifeq ($(BR2_TOOLCHAIN_USES_UCLIBC),y)
WPE_EXTRA_FLAGS += \
	-D__UCLIBC__
endif

ifeq ($(BR2_PACKAGE_WAYLAND),y)
WPE_DEPENDENCIES += wayland
WPE_FLAGS += -DUSE_WPE_BACKEND_WAYLAND=ON
else ifeq ($(BR2_PACKAGE_RPI_USERLAND),y)
WPE_FLAGS += -DUSE_WPE_BACKEND_BCM_RPI=ON
endif

ifeq ($(BR2_ENABLE_DEBUG),y)
WPE_BUILD_TYPE = Debug
WPE_EXTRA_FLAGS += \
	-DCMAKE_C_FLAGS_RELEASE="-O0 -g -Wno-cast-align" \
	-DCMAKE_CXX_FLAGS_RELEASE="-O0 -g -Wno-cast-align"
ifeq ($(BR2_BINUTILS_VERSION_2_25),y)
WPE_EXTRA_FLAGS += \
	-DDEBUG_FISSION=TRUE
endif
else
WPE_BUILD_TYPE = Release
WPE_EXTRA_FLAGS += \
	-DCMAKE_C_FLAGS_RELEASE="-O2 -DNDEBUG -Wno-cast-align" \
	-DCMAKE_CXX_FLAGS_RELEASE="-O2 -DNDEBUG -Wno-cast-align"
endif

ifeq ($(BR2_PACKAGE_GSTREAMER1),y)
WPE_DEPENDENCIES += gstreamer1 gst1-plugins-base gst1-plugins-good gst1-plugins-bad
WPE_FLAGS += \
	-DENABLE_VIDEO=ON \
	-DENABLE_VIDEO_TRACK=ON \
	-DENABLE_WEB_AUDIO=ON
else
WPE_FLAGS += \
	-DENABLE_VIDEO=OFF \
	-DENABLE_VIDEO_TRACK=OFF \
	-DENABLE_WEB_AUDIO=OFF
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_GOOD_PLUGIN_ISOMP4),y)
WPE_FLAGS += -DENABLE_MEDIA_SOURCE=ON
endif

ifeq ($(BR2_PACKAGE_WPE_USE_ENCRYPTED_MEDIA_V1),y)
WPE_FLAGS += -DENABLE_ENCRYPTED_MEDIA=ON
endif

ifeq ($(BR2_PACKAGE_WPE_USE_ENCRYPTED_MEDIA_V2),y)
WPE_FLAGS += -DENABLE_ENCRYPTED_MEDIA_V2=ON
endif

ifeq ($(BR2_PACKAGE_DXDRM),y)
WPE_DEPENDENCIES += dxdrm
WPE_FLAGS += -DENABLE_DXDRM=ON
ifeq ($(BR2_PACKAGE_DXDRM_EXTERNAL),y)
WPE_FLAGS += -DENABLE_PROVISIONING=ON
endif
endif

ifeq ($(BR2_PACKAGE_WPE_USE_GSTREAMER_GL),y)
WPE_FLAGS += -DUSE_GSTREAMER_GL=ON
endif

ifeq ($(BR2_PACKAGE_WPE_USE_PUNCH_HOLE_GSTREAMER),y)
WPE_FLAGS += -DUSE_HOLE_PUNCH_GSTREAMER=ON
else ifeq ($(BR2_PACKAGE_WPE_USE_PUNCH_HOLE_EXTERNAL),y)
WPE_FLAGS += -DUSE_HOLE_PUNCH_EXTERNAL=ON
endif

WPE_CONF_OPTS = \
	-DPORT=WPE \
	-DCMAKE_BUILD_TYPE=$(WPE_BUILD_TYPE) \
	$(WPE_EXTRA_FLAGS) \
	$(WPE_FLAGS)

ifeq ($(BR2_PACKAGE_NINJA),y)
define WPE_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(HOST_DIR)/usr/bin/ninja -C $(@D) $(WPE_EXTRA_OPTIONS) libWPEWebKit.so libWPEWebInspectorResources.so WPE{Web,Network}Process
endef

define WPE_INSTALL_STAGING_CMDS
	(cd $(@D) && \
	cp bin/WPE{Network,Web}Process $(STAGING_DIR)/usr/bin/ && \
	cp -d lib/libWPE* $(STAGING_DIR)/usr/lib/ )
	DESTDIR=$(STAGING_DIR) $(HOST_DIR)/usr/bin/cmake -DCOMPONENT=Development -P $(@D)/Source/WebKit2/cmake_install.cmake
endef

define WPE_INSTALL_TARGET_CMDS
	(pushd $(@D) > /dev/null && \
	cp bin/WPE{Network,Web}Process $(TARGET_DIR)/usr/bin/ && \
	cp -d lib/libWPE* $(TARGET_DIR)/usr/lib/ && \
	$(STRIPCMD) $(TARGET_DIR)/usr/lib/libWPEWebKit.so.0.0.1 && \
	popd > /dev/null)
endef
endif

$(eval $(cmake-package))