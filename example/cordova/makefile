all: full

full: clean build run

build: copy
	cordova plugin add ../../lib

clean: copy
	cordova plugin remove cordova-plugin-pebblekit

run:
	# cordova run ios --device

init:
	cordova platform add android
	cordova platform add ios
	cordova plugin add cordova-plugin-calendar

copy:
	# android
	-cp platforms/android/src/com/pebble/cordovapebblekit/PebbleKitCordovaWrapper.java ../../lib/src/android/PebbleKitCordovaWrapper.java
	-cp platforms/android/src/com/pebble/cordovapebblekit/Util.java ../../lib/src/android/Util.java

  # ios
	-cp "platforms/ios/PebbleKit Example/Plugins/cordova-plugin-pebblekit/PebbleKitCordovaWrapper.h" ../../lib/src/ios/PebbleKitCordovaWrapper.h
	-cp "platforms/ios/PebbleKit Example/Plugins/cordova-plugin-pebblekit/PebbleKitCordovaWrapper.m" ../../lib/src/ios/PebbleKitCordovaWrapper.m

