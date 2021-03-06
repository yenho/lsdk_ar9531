#############################################################
#
# acpid
#
#############################################################
ACPID_VERSION:=1.0.8
ACPID_DIR=$(BUILD_DIR)/acpid-$(ACPID_VERSION)
ACPID_SOURCE=acpid_$(ACPID_VERSION).orig.tar.gz
ACPID_SITE=$(BR2_DEBIAN_MIRROR)/debian/pool/main/a/acpid

$(DL_DIR)/$(ACPID_SOURCE):
	$(call DOWNLOAD,$(ACPID_SITE),$(ACPID_SOURCE))

$(ACPID_DIR)/.unpacked: $(DL_DIR)/$(ACPID_SOURCE)
	$(ZCAT) $(DL_DIR)/$(ACPID_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	toolchain/patch-kernel.sh $(ACPID_DIR) package/acpid/ acpid-$(ACPID_VERSION)\*.patch
	touch $(ACPID_DIR)/.unpacked

$(ACPID_DIR)/acpid: $(ACPID_DIR)/.unpacked
	$(MAKE) CC=$(TARGET_CC) -C $(ACPID_DIR)
	$(STRIPCMD) $(STRIP_STRIP_ALL) $(ACPID_DIR)/acpid
	$(STRIPCMD) $(STRIP_STRIP_ALL) $(ACPID_DIR)/acpi_listen
	touch -c $(ACPID_DIR)/acpid $(ACPID_DIR)/acpi_listen

$(TARGET_DIR)/usr/sbin/acpid: $(ACPID_DIR)/acpid
	cp -a $(ACPID_DIR)/acpid $(TARGET_DIR)/usr/sbin/acpid
	mkdir -p $(TARGET_DIR)/etc/acpi/events
	/bin/echo -e "event=button[ /]power\naction=/sbin/poweroff" > $(TARGET_DIR)/etc/acpi/events/powerbtn
	touch -c $(TARGET_DIR)/usr/sbin/acpid

acpid: $(TARGET_DIR)/usr/sbin/acpid

acpid-source: $(DL_DIR)/$(ACPID_SOURCE)

acpid-clean:
	-$(MAKE) -C $(ACPID_DIR) clean

acpid-dirclean:
	rm -rf $(ACPID_DIR)

#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(BR2_PACKAGE_ACPID),y)
TARGETS+=acpid
endif
