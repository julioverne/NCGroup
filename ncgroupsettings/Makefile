include theos/makefiles/common.mk

BUNDLE_NAME = NCGroup
NCGroup_FILES = NCGroupController.mm
NCGroup_INSTALL_PATH = /Library/PreferenceBundles
NCGroup_FRAMEWORKS = UIKit QuartzCore CoreGraphics MessageUI Social Twitter
NCGroup_PRIVATE_FRAMEWORKS = Preferences
NCGroup_CFLAGS = -fobjc-arc
NCGroup_LDFLAGS = -Wl,-segalign,4000
NCGroup_ARCHS = armv7 arm64
export ARCHS = armv7 arm64

include $(THEOS_MAKE_PATH)/bundle.mk

all::
	@echo "[+] Copying Files..."
	@ldid -S ./obj/NCGroup.bundle/NCGroup
	@cp ./obj/NCGroup.bundle/NCGroup //Library/PreferenceBundles/NCGroup.bundle/NCGroup
	@echo "DONE"
	
	