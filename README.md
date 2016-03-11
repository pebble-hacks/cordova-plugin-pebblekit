# cordova-plugin-pebblekit

Create native applications with PebbleKit support using Cordova.

## Running the example

### Dependencies
1. `adb` should be in your path
2. install cordova, `npm install -g cordova`

### Build the Cordova Application
1. `cd example/cordova`
2. `make init` (or `cordova platform add android`, this tells cordova that the
project should include Android as a build target)
3. `make build` (or `cordova plugin add ../../lib`)
4. `make run` (or `cordova run android --device`).  Make sure you have an Android
device plugged in.  Congrats.  You are now running the companion app for your
application

*note*: Running `make` with no dependencies will overwrite the source files of
the plugin with the corresponding files in the built android directory.  Read
[here](#android-1) to understand why

### Build the Pebble Application
1. `cd example/cordova`
2. `pebble build && pebble install --phone <PHONE_IP>`
For more help, see the [documentation](https://developer.pebble.com/guides/tools-and-resources/pebble-tool/)

When changes are made to the plugin javascript files,

## Development
### Project structure
All of the source code for the plugin resides in the `lib` directory.

`lib/www` contains a javascript `pebblekit.js` file in which whatever gets
exported through the `module.exports` object is callable by users who had
added the plugin.

`lib/src/android` contains the java files that get copied to the built project
when users run `cordova build` or `cordova run` for a project that uses this
plugin.

### Native Binding
The way the binding works between the javascript and the native code is like
this:

#### JS
In the `pebblekit.js` file, a function `exec` is made available
`exec(successCallback, errorCallback, className, action, [args])`

Calling this function will call a function in the native code, aptly named
`execute()`.  The arguments to the js side of the `exec()` call are as follows

- `successCallback` is a function which is executed if the corresponding native
component deems the method call a success
- `errorCallback` is a function which is executed if the corresponding native
component deems the method call a failure
- `className` is the name of the native class that you want to call a method from
- `action` a string that is passed `exec` method on the native side.  Used in the
native side to determine what functionality the user is expecting.  Usually
corresponds to the
- `[args]` Javascript array of arguments to pass to the native side.

#### Android
Extending the `CordovaPlugin` class requires you implement the function

```java
@Override
public boolean execute(String action, JSONArray args, CallbackContext callbackContext) {}
```

Returning `true` indicates that there IS a corresponding method for the passed
in `action`.  Returning false will indiciate to the user that there is no
functionality corresponding to the passed in `action`.

The arguments correspond to what is passed into `exec()` on the js side.

The `CallbackContext` object is used for communicating back to the JS side of
the plugin.

##### Callbacks
Calling `callbackContext.success()` will call the `successCallback` function
on the JS side
Calling `callbackContext.error()` will call the `errorCallback` function on the
JS side

Sometimes, you don't want to return something right away.  e.g. registering for
`PebbleConnected` and `PebbleDisconnected` events.  In this case, you would
use the following syntax to prevent the callback context from being cleaned up.

```java
PluginResult immediatePluginResult = new PluginResult(PluginResult.Status.NO_RESULT);
immediatePluginResult.setKeepCallback(true);
callbackContext.sendPluginResult(immediatePluginResult);
```

Likewise, if you want to trigger one of the `successCallback` or
`errorCallback` methods multiple times, use `pluginResult.setKeepCallback(true)`
to prevent the object from being cleaned up.

### Viewing logs

#### JS
You can use Google Chrome in order to view the logs printed from the js side

1. Open Google Chrome
2. Visit [`chrome://inspect`](chrome://inspect)
3. Make sure your device is plugged in
4. Hit the `inspect` button.  This will bring up a new window which provides
you with all the native google chrome developer tools, just hooked into the
webview running on the phone.

#### Android
When you build/run the project with Cordova, the source files of the plugin
are copied to the directory
`example/cordova/platforms/android/com/pebble/cordovapebblekit/`

You can open Android Studio to the `example/cordova/platforms/android` directory
and you will be able to explore the source code, set breakpoints, and view
the logcat just like any other Android project.

With this, you have the full power of the IDE, including code completion,
refactoring, formatting, etc.  The only caveat is that you are editing the
built files instead of the source files of the plugin.  Because of this, I
have the makefile setup to copy the Plugin files from the
`example/cordova/platforms/android` directory to the `lib/src/android`
This way, you will not lose the changes you made to the plugin source files.

Running `make` with no arugments will copy the files over, read the plugin,
and the run the project on a plugged in android device.
