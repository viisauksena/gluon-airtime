include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-airtime
PKG_VERSION:=1.2

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)
PKG_BUILD_DEPENDS := respondd

include $(INCLUDE_DIR)/package.mk

define Package/gluon-airtime
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=Airtime reporter
  DEPENDS:=+gluon-core +micrond +gluon-respondd +libgluonutil
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./src/* $(PKG_BUILD_DIR)/
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/gluon-airtime/install
        $(CP) ./files/* $(1)/
#	$(CP) $(PKG_BUILD_DIR)/luadest/* $(1)/
	$(INSTALL_DIR) $(1)/lib/gluon/respondd
	$(CP) $(PKG_BUILD_DIR)/respondd.so $(1)/lib/gluon/respondd/airtime.so
endef

$(eval $(call BuildPackage,gluon-airtime))
