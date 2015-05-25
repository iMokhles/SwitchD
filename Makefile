GO_EASY_ON_ME = 1
TARGET=iphone:clang:latest:7.0
ADDITIONAL_CFLAGS = -fobjc-arc

include theos/makefiles/common.mk

TWEAK_NAME = SwitchD
SwitchD_FILES = Tweak.xm $(wildcard iCarousel/*.m)
SwitchD_FRAMEWORKS = UIKit Foundation CoreGraphics QuartzCore CoreImage Accelerate AVFoundation AudioToolbox MobileCoreServices Social Accounts MediaPlayer ImageIO CoreMedia MessageUI AssetsLibrary Security LocalAuthentication CoreData WebKit CoreText
SwitchD_LIBRARIES = MobileGestalt

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
