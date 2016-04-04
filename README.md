# Cordova-plugin-pebblekit

Create native applications with PebbleKit support using
[Cordova](https://cordova.apache.org/).

No need for Java or Objective C to create mobile apps that communicate with your
Pebble application.  Use one framework and the vast set of existing Cordova
[plugins](https://cordova.apache.org/plugins/) to extend the functionality of
your watch app/face.

1. [Install](#install)
2. [Available APIs](#available-apis)
3. [Usage](#usage)
    1. [About the `keep alive` Parmeter](#keepalive);
4. [Running the Example](#running-the-example)
5. [Development](#development)
    1. [Project Structure](#project-structure)
    2. [Native Binding Explanation](#native-binding-explanation)
    3. [Viewing Logs](#viewing-logs)

## Install
cordova plugin add <published-url>

__note__ If supporting iOS, the following steps are required to build the
 application for the first time.

1. Open up XCode and open your project's `xcodeproj` file
   (`<project-directory>/platforms/ios/<project-name>.xcodeproj`)
2. Click on your project's name on the left pane
3. Select `Build Phases`
3. Expand the `Embed Frameworks` tab, and select `PebbleKit.Framework`

If you run into an `Invalid Provisioning Profile` error:

1. Navgiate to `Build Phases` in XCode again, as described in the above steps
2. Tick the checkmark box next to `Code Sign On Copy` for `PebbleKit.Framework`

## Available APIs

* [`setupIos`](#setupiosuuid-successcallback-errorcallback)
* [`isWatchConnected`](#iswatchconnectedsuccesscallback-errorcallback)
* [`registerPebbleConnectedReceiver`](#registerpebbleconnectedreceiversuccesscallback-errorcallback-keepalive)
* [`registerPebbleDisconnectedReceiver`](#registerpebbledisconnectedreceiversuccesscallback-errorcallback-keepalive)
* [`unregisterPebbleConnectedReceiver`](#unregisterpebbleconnectedreceiversuccesscallback-errorcallback)
* [`unregisterPebbleDisconnectedReceiver`](#unregisterpebbledisconnectedreceiversuccesscallback-errorcallback)
* [`startAppOnPebble`](#startapponpebbleuuid-successcallback-errorcallback)
* [`closeAppOnPebble`](#closeapponpebbleuuid-successcallback-errorcallback)
* [`areAppMessagesSupported`](#areappmessagessupportedsuccesscallback-errorcallback)
* [`sendAppMessage`](#sendappmessageuuid-data-ackhandler-nackhandler-errorcallback)
* [`registerReceivedDataHandler`](#registerreceiveddatahandleruuid-successcallback-errorcallback-keepalive)
* [`unregisterReceivedDataHandler`](#unregisterreceiveddatahandlersuccesscallback-errorcallback)

## Usage

### setupIos(uuid, successCallback, [errorCallback])
Users __must__ wait for the success callback of this function to be called
before calling the following methods on iOS.

* `startAppOnPebble`
* `closeAppOnPebble`
* `areAppMessagesSupported`
* `sendAppMessage`
* `registerReceivedDataHandler`

__Arguments__

* `uuid` - The UUID of the Pebble application to be interacted with
* `successCallback` - A callback which is called once the connection is setup
on the iOS device.  Called immediately if running on an Android device.
* `errorCallback` - *Optional* A callback which is called if an error has
occured.

__Example__

```js
window.pebblekit.setupIos(uuid, function () {
  console.log('ready');
}, function (err) {
  // error
});
```

### isWatchConnected(successCallback, [errorCallback])
Determine if a Pebble watch is currently connected to the phone.

__Arguments__

* `successCallback` - A callback which is called when the status of the
connection has been deteremined
* `errorCalback` - *Optional* A callback which is called if an error has
occurred.

__Example__

```js
window.pebblekit.isWatchConnected(function(connected) {
  console.log('Watch is connected', connected);
}, function(err) {
  // error
});
```

### registerPebbleConnectedReceiver(successCallback, [errorCallback], [keepAlive])

Register to be notified when a Pebble has been connected to the phone.

__Arguments__

* `successCallback` - A callback which is called when the watch is connected
* `errorCallback` - *Optional* A callback which is called if an error has
occurred
* `keepAlive` - *Optional* set to `true` to keep the receiver alive after the
phone app has gone to in to the background.  (See [here](#keepalive) for more
detail)

__Example__

```js
var keepAlive = false;
window.pebblekit.registerPebbleConnectedReceiver(function() {
  // pebble connected
}, function(err) {
  // error
}, keepAlive);
```

### registerPebbleDisconnectedReceiver(successCallback, [errorCallback], [keepAlive])

Register to be notified when a Pebble has been disconnected from the phone.

__Arguments__

* `successCallback` - A callback which is called when the watch is disconnected
* `errorCallback` - *Optional* A callback which is called if an error has
occurred
* `keepAlive` - *Optional* set to `true` to keep the receiver alive after the
phone app has gone to in to the background.  (See [here](#keepalive) for more
detail)

__Example__

```js
var keepAlive = false;
window.pebblekit.registerPebbleDisconnectedReceiver(function() {
  // pebble disconnected
}, function(err) {
  // error
}, keepAlive);
```

### unregisterPebbleConnectedReceiver([successCallback], [errorCallback])

Stop being notified about when a pebble is connected to the phone.

__Arguments__

* `successCallback` - *Optional* A callback which is called once the receiver
has been unregistered
* `errorCallback` - *Optional* A callback which is called if an error has
occurred

__Example__

```js
window.pebblekit.unregisterPebbleConnectedReceiver(function() {
  // receiver unregistered
}, function (err) {
  // error
});
```

### unregisterPebbleDisconnectedReceiver([successCallback], [errorCallback])

Stop being notified about when a pebble is disconnected to the phone.

__Arguments__

* `successCallback` - *Optional* A callback which is called once the receiver
has been unregistered
* `errorCallback` - *Optional* A callback which is called if an error has
occurred

__Example__

```js
window.pebblekit.unregisterPebbleDisconnectedReceiver(function() {
  // receiver unregistered
}, function (err) {
  // error
});
```

### startAppOnPebble(uuid, [successCallback], [errorCallback])

Start an application on the pebble with the specified `uuid`.

__Arguments__

* `uuid` - The UUID of the application to start on the watch
* `successCallback` - *Optional* A callback which is called once the app has
been started
* `errorCallback` - *Optional* A callback which is called if an error has
occurred

__Example__

```js
window.pebblekit.startAppOnPebble('ebc92429-483e-4b91-b5f2-ead22e7e002d', function() {
  // app started on pebble
}, function (err) {
  // error
});
```

### closeAppOnPebble(uuid, [successCallback], [errorCallback])

Close an app on the watch with the specified `uuid`.

__Arguments__

* `uuid` - The UUID of the application to close on the watch
* `successCallback` - *Optional* A callback which is callled once the app
has been started
* `errorCallback` - *Optional* A callback which is called if an error has
occurred

__Example__

```js
window.pebblekit.closeAppOnPebble('ebc92429-483e-4b91-b5f2-ead22e7e002d', function() {
  // App closed on pebble
}, function (err) {
  // error
});
```

### areAppMessagesSupported(successCallback, [errorCallback])

Determine whether or not the currently connected watch supports
[`AppMessages`](https://developer.pebble.com/docs/c/Foundation/AppMessage/).

__Arguments__

* `successCallback` - A callback which is called, containing the result of
whether appmesages
* `errorCallback` - *Optional* A callback which is called if an error has
occurred

__Example__

```c
window.pebblekit.areAppMessagesSupported(function(supported) {
  console.log('AppMessages supported:', supported);
}, function(err) {
  // error
});
```

### sendAppMessage(uuid, data, ackHandler, nackHandler, [errorCallback])

Send an AppMessage to the watch.

__Arguments__

* `uuid` - The UUID of the pebble application the `AppMessage` should be sent
to
* `data` - An `Object` containing data to send to the watch.
* `ackHandler` - A callback that is called if the `AppMessage` is `ack`ed
* `nackHandler` - A callback that is called if the `AppMessage` is `nack`ed
* `errorCallback` - *Optional* A callback that is called if there was a problem
sending the `AppMessage`

__note__ - Depending on the type of the item in the object to be sent, the C
app will be able to read the value (from the `Tuple.value` union) according to
the table below:

__note__ - If running on the Android platform, a `transactionId` will be passed
to the `successCallback` and `errorCallback`, represention the transaction id
of that particular app message.  This value will be `-1` if on the iOS
platform.

| JS Type | C Type  |
|---------|---------|
| String  | cstring |
| Number  | int32   |
| Array   | data    |
| Boolean | int16   |

__note__ - If running on the iOS platform, the `Boolean` type will actually be
`int32` type on the C side, however, you may still interpret it as `int16` in
the C code without any problems.

__Example__

Sending from the JS side:

```js
var uuid = "ebc92429-483e-4b91-b5f2-ead22e7e002d";
var data = {
  '0': 'String value',
  '1': 42,
  '2': [0, 1, 2, 3, 4, 5, 6, 7, 8, 9] // Byte array,
  '3': true
}

window.pebblekit.sendAppMessage(uuid, data, function() {
  // app message has been acked
}, function() {
  // app message has been nacked
}, function(err) {
  // err
})
```

Reading the data on the C side:

```C
#define APP_KEY_STRING_VALUE 0

static void inbox_received_callback(DictionaryIterator *iter, void *context) {
  Tuple *tuple;

  tuple = dict_find(iter, APP_KEY_STRING_VALUE)
  if (tuple) {
    char* value_string = tuple->value->cstring;
    APP_LOG(APP_LOG_LEVEL_DEBUG, value_string); // 'String value'
  }
}
```

To read more about reading `AppMessage`s on the C side, see the
[documentation](https://developer.pebble.com/guides/communication/sending-and-receiving-data/)

### registerReceivedDataHandler(uuid, successCallback, [errorCallback], [keepAlive])

Register a callback for when the specified watch app with the given `uuid`
sends an `AppMessage`.

__Arguments__

* `uuid` - The UUID of the pebble app in which to be receiving messages from
* `successCallback` - A callback which is called when a new app message is
received from the application with the given `uuid`
* `errorCallback` - *Optional* A callback which is called if an error has
occurred
* `keepAlive` - *Optional* set to `true` to keep the receiver alive after the
phone app has gone to in to the background.  (See [here](#keepalive) for more
detail)

__note__ - Acking and Nacking the message is taken care of for you.  If sending
data, the base64 representation will be received on the JS side.

__Example__

Sending from the C side:

```C
typedef enum {
  AppKeyInt = 0,
  AppKeyString = 1,
  AppKeyData = 2
} AppKeys

static void send_app_msg() {
  DictionaryIterator *out_iter;
  AppMessageResult result = app_message_outbox_begin(&out_iter);

  if (result != APP_MSG_OK) {
    APP_LOG(APP_LOG_LEVEL_ERROR, "Error preparing outbox: %d", (int) result);
    return;
  }

  int value_int = 42;
  char* value_string = "Message from C";
  uint8_t value_data[] = {0, 1, 2, 3, 4, 5, 6, 7, 9};

  dict_write_int(out_iter, AppKeyInt, &value, sizeof(int), true);
  dict_write_cstring(out_iter, AppKeyString, "message from C");
  dict_write_data(out_iter, AppKeyData, data, sizeof(data));
  result = app_message_outbox_send();

  if (result != APP_MSG_OK) {
    APP_LOG(APP_LOG_LEVEL_ERROR, "Error sending the outbox: %d", (int) result);
  }
}
```

Receiving on the JS side:

```js
var uuid = "ebc92429-483e-4b91-b5f2-ead22e7e002d";
var keepAlive = false;
window.pebblekit.registerReceivedDataHandler(uuid, function(data) {
  console.log('Received data', JSON.stringify(data));

  /*
  Received data {
    "0": 0,
    "1": "message from C",
    "2": "AAECAwQFBgcICQ=="
  }
  */

}, function (err) {
  // error
}, keepAlive);
```

### unregisterReceivedDataHandler([successCallback], [errorCallback])

Stop listening for `AppMessage`s sent from the watch.

__Arguments__

* `successCallback` - A callback that is called once the data handler has been
unregistered
* `errorCallback` - *Optional* A callback that is called if an error has
occurred

__Example__

```js
window.pebblekit.unregisterReceivedDataHandler(function() {
  // received data handler unregistered
}, function (err) {
  // error
});
```

### keepAlive
Some functions have a `keepAlive` parameter.  By default, this plugin will take
care of unregistering receivers for you when the app goes into the background
in order to avoid memory leaks.

If you set this option to `true`, you should make sure to call the
corresponding `unregisterX()` function when you are done with it.  The receiver
will stay active until the application is killed by the OS.  This feature is
only available for Android.

## Running the example

### Dependencies
1. Ensure [`adb`](http://developer.android.com/tools/help/adb.html) is in your
PATH.
2. Install Cordova, `npm install -g cordova`

### Build the Cordova Application
1. `cd example/cordova`
2. `make init` (or `cordova platform add android`, this tells cordova that the
   project should include Android as a build target)
3. `make build` (or `cordova plugin add ../../lib`)
4. `make run` (or `cordova run android --device`).  Make sure you have an
   Android device plugged in.  Congrats.  You are now running the companion app
   for your application

__note__  Running `make` with no dependencies will overwrite the source files of
the plugin with the corresponding files in the built android directory.  Read
[here](#android-1) to understand why.

### Build the Pebble Application
1. `cd example/cordova`
2. `pebble build && pebble install --phone <PHONE_IP>` For more help, see the
   [documentation](https://developer.pebble.com/guides/tools-and-resources/pebble-tool/)

## Development
### Project structure
All of the source code for the plugin resides in the `lib` directory.

`lib/www` contains a javascript `pebblekit.js` file in which whatever gets
exported through the `module.exports` object is callable by users who had
added the plugin.

`lib/src/android` contains the java files that get copied to the built project
when users run `cordova build` or `cordova run` for a project that uses this
plugin.

### Native Binding Explanation
The way the binding works between the javascript and the native code is like
this:

#### JS
In the `pebblekit.js` file, a function `exec` is made available
`exec(successCallback, errorCallback, className, action, [args])`

- `successCallback` is a function which is executed if the corresponding native
component deems the method call a success
- `errorCallback` is a function which is executed if the corresponding native
component deems the method call a failure
- `className` is the name of the native class that you want to call a method from
- `action` The name of the method to call on the native side
- `[args]` Javascript array of arguments to pass to the native side

#### Android
Extend the `CordovaPlugin` class.  This requires you to implement the function

```java
@Override
public boolean execute(String action, JSONArray args, CallbackContext callbackContext) {}
```

Returning `true` indicates that there IS a corresponding method for the passed
in `action` (i.e., there is no magic happening here, you manually map the
passed in `action` string to java methods yourself).  Returning false will
indiciate to the user that there is no functionality corresponding to the
passed in `action`.

The `args` argument is a JSONArray, holding the arguments passed into the
`exec` function on the js side

The `CallbackContext` object is used for communicating back to the JS side of
the plugin.

##### Callbacks
Calling `callbackContext.success()` will call the `successCallback` function
on the JS side
Calling `callbackContext.error()` will call the `errorCallback` function on the
JS side

Sometimes, you don't want to return something right away.  e.g. registering for
`PebbleConnected` and `PebbleDisconnected` events (you would wait for those
events to happen before calling one of the callback methods).  In this case,
you would use the following syntax to prevent the callback context from being
cleaned up.

```java
PluginResult immediatePluginResult = new PluginResult(PluginResult.Status.NO_RESULT);
immediatePluginResult.setKeepCallback(true);
callbackContext.sendPluginResult(immediatePluginResult);
```

Likewise, if you want to trigger one of the `successCallback` or
`errorCallback` methods multiple times, use
`pluginResult.setKeepCallback(true)` to prevent the object from being cleaned
up.

#### iOS
The class should extends the `CDVPlugin` class.

Cordova provides some magic here.  Simply create method names that match the
`action` strings passed into the `exec` function on the JS side.  When they are
called, the corresponding iOS function will be called.  One example could look
like this

```objectivec
- (void)exampleMethod:(CDVInvokedUrlCommand *)command {
  // called when `exampleMethod` is passed as the action
  // to the `exec` function on the JS side.
}
```

Arguments are obtained by calling `[command.arguments objectAtIndex:<index>]`

##### Callbacks
```objectivec
CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                          messase:@"Message from native side"];
[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
```

As explained in the [callbacks section above](#callbacks), sometimes a response
isn't needed immediately.

```objectivec
CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_NO_RESULT]
[pluginResult setKeepCallbackAsBool:YES]
[self.commandDelegate sendPluginResult callbackId:command.callbackId];
```

Unlike in the Android implementation, there is no need to save the `command`
variable, only the [command.callbackId] so that it may be used in the
`sendPluginResult` method.

### Viewing logs

#### JS
You can use a browser to view the logs in the webview of the phone app.

If you're running the app on an Android device:

1. Open Google Chrome
2. Visit [`chrome://inspect`](chrome://inspect)
3. Make sure your device is plugged in, and that `USB Debugging` is enabled
4. Hit the `inspect` button.  This will bring up a new window which provides
you with all the native google chrome developer tools, just hooked into the
webview running on the phone.

If you're running the app on an iOS device:

1. Open safari
2. Make sure the `Develop` menu item is available in the menu bar
    1. `Preferences`
    2. `Advanced`
    3. Check the `show Develop menu in the menu bar` checkbox
3. Open the web inspector for your application
    1. `Develop`
    2. `<Name of iOS device>`
    3. `<Name of html page running in webview>` (likely `index.html`)

#### Android
1. If you haven't already, add Android as a platform to the Cordova project
   (`cordova platform add android`)
2. Open Android Studio to the generated project's directory
   (`<directory>/platforms/android`)

#### iOS
1. If you haven't already, add iOS as a platform to the Cordova project
   (`cordova platform add ios`)
2. Open XCode to the Cordova projet's directory
   (`<directory>/platforms/ios`)

### Makefile
Cordova copies the source files of the plugin over to the generated
application.  However, this means you are usually editing the source files out
of context of a full project, meaning that using an IDE to edit the source
files will not be very helpful.  If you would like to use an IDE for refactoring,
code code completion, etc, it would be beneficial to edit the files *after*
they've been copied to the generated project.

The makefile in `example/cordova` will copy the plugin files from the generated
project to the source directory of the plugin
(`lib/src/<platform-specific-directory>`).  This way, the following workflow
can be achieved

1. Edit native plugin files in generated project using IDE
2. run `make` (copies the plugin files from the generated project back to the
   source directory, builds the project, and runs the project)
