#############################################################
#
# libcgi
#
#############################################################
LIBCGI_VERSION:=1.0
LIBCGI_SOURCE:=libcgi-$(LIBCGI_VERSION).tar.gz
LIBCGI_SITE:=http://$(BR2_SOURCEFORGE_MIRROR).dl.sourceforge.net/sourceforge/libcgi
LIBCGI_DIR:=$(BUILD_DIR)/libcgi-$(LIBCGI_VERSION)
LIBCGI_LIBRARY:=src/libcgi.so
LIBCGI_DESTDIR:=usr/lib
LIBCGI_TARGET_LIBRARY=$(LIBCGI_DESTDIR)/libcgi.so

$(DL_DIR)/$(LIBCGI_SOURCE):
	$(call DOWNLOAD,$(LIBCGI_SITE),$(LIBCGI_SOURCE))

$(LIBCGI_DIR)/.source: $(DL_DIR)/$(LIBCGI_SOURCE)
	$(ZCAT) $(DL_DIR)/$(LIBCGI_SOURCE) | tar -C $(BUILD_DIR) $(TAR_OPTIONS) -
	toolchain/patch-kernel.sh $(LIBCGI_DIR) package/libcgi/ libcgi\*.patch
	touch $(LIBCGI_DIR)/.source

$(LIBCGI_DIR)/.configured: $(LIBCGI_DIR)/.source
	(cd $(LIBCGI_DIR); rm -f config.cache; \
		$(TARGET_CONFIGURE_OPTS) \
		$(TARGET_CONFIGURE_ARGS) \
		./configure \
		--target=$(GNU_TARGET_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--build=$(GNU_HOST_NAME) \
		--prefix=/usr \
		--exec-prefix=/usr \
		--bindir=/usr/bin \
		--sbindir=/usr/sbin \
		--libdir=/lib \
		--libexecdir=/$(LIBCGI_DESTDIR) \
		--sysconfdir=/etc \
		--datadir=/usr/share \
		--localstatedir=/var \
		--includedir=/include \
		--mandir=/usr/man \
		--infodir=/usr/info \
	)
	touch $(LIBCGI_DIR)/.configured

$(LIBCGI_DIR)/$(LIBCGI_LIBRARY): $(LIBCGI_DIR)/.configured
	$(MAKE) CC=$(TARGET_CC) -C $(LIBCGI_DIR)

$(STAGING_DIR)/$(LIBCGI_TARGET_LIBRARY): $(LIBCGI_DIR)/$(LIBCGI_LIBRARY)
	$(MAKE) DESTDIR=$(STAGING_DIR) -C $(LIBCGI_DIR) install
	touch -c $@

$(TARGET_DIR)/$(LIBCGI_TARGET_LIBRARY): $(STAGING_DIR)/$(LIBCGI_TARGET_LIBRARY)
	cp -dpf $<* $(TARGET_DIR)/$(LIBCGI_DESTDIR)

libcgi: uclibc $(TARGET_DIR)/$(LIBCGI_TARGET_LIBRARY)

libcgi-source: $(DL_DIR)/$(LIBCGI_SOURCE)

libcgi-clean:
	rm -f $(TARGET_DIR)/$(LIBCGI_TARGET_LIBRARY)*
	-$(MAKE) -C $(LIBCGI_DIR) clean

libcgi-dirclean:
	rm -rf $(LIBCGI_DIR)

.PHONY: libcgi
#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(BR2_PACKAGE_LIBCGI),y)
TARGETS+=libcgi
endif
