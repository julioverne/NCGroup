include theos/makefiles/common.mk

TWEAK_NAME = NCGroup
NCGroup_FILES = NCGroup.xm
NCGroup_FRAMEWORKS = UIKit CoreGraphics CoreImage Foundation CoreFoundation QuartzCore CydiaSubstrate
NCGroup_PRIVATE_FRAMEWORKS = 
NCGroup_CFLAGS = -fobjc-arc -std=c++11
NCGroup_LDFLAGS = -Wl,-segalign,4000 #-Wl,-undefined,dynamic_lookup
export ARCHS = armv7 arm64
NCGroup_ARCHS = armv7 arm64
include $(THEOS_MAKE_PATH)/tweak.mk

all::
	@echo "[+] Copying Files..."
	@ldid -S ./obj/NCGroup.dylib
	@cp ./obj/NCGroup.dylib //Library/MobileSubstrate/DynamicLibraries/NCGroup.dylib
	@cp ./NCGroup.plist //Library/MobileSubstrate/DynamicLibraries/NCGroup.plist
	@echo "DONE"
	#@killall SpringBoard

	
