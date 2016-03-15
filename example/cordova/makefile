all: full

full: clean build run

build: copy
	cordova plugin add ../../lib

clean: copy
	cordova plugin remove cordova-plugin-pebblekit

run:
	cordova run android --device

init:
	cordova platform add android

copy:
	-cp platforms/android/src/com/pebble/cordovapebblekit/PebbleKitCordovaWrapper.java ../../lib/src/android/PebbleKitCordovaWrapper.java
	-cp platforms/android/src/com/pebble/cordovapebblekit/Util.java ../../lib/src/android/Util.java

