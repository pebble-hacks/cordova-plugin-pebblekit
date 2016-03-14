# Cordova-plugin-pebblekit

Create native applications with PebbleKit support using
[Cordova](https://cordova.apache.org/).

No need for Java or Objective C to create mobile apps that communicate with your
Pebble application.  Use one framework and the vast set of existing Cordova
[plugins](https://cordova.apache.org/plugins/) to extend the functionality of
your watch app/face.

## Available APIs

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
* [`registerDataLogReceiver`](#registerdatalogreceiveruuid-successcallback-errorcallback-keepalive)
* [`unregisterDataLogReceiver`](#unregisterdatalogreceiversuccesscallback-errorcallback)

## Usage

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
phone app has gone to in to the background.  (See [here](#keepAlive) for more
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

| JS Type | C Type  |
|---------|---------|
| String  | cstring |
| Number  | int32   |
| Array   | data    |
| Boolean | int16   |

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
phone app has gone to in to the background.  (See [here](#keepAlive) for more
detail)

__note__ - Acking and Nacking the message is taken care of for you.

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
    "2": "AAECAwQFBgcJ"
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

### registerDataLogReceiver(uuid, successCallback, [errorcallback], [keepAlive])

Register a callback for [data logging](https://developer.pebble.com/guides/communication/datalogging/).

__Arguments__

* `uuid` - The UUID of the pebble app in which to be receiving data from
* `successCallback` - A callback which is called when new data is available
* `errorCallback` - *Optional* A callback which is called if an error has
occurred
* `keepAlive` - *Optional* set to `true` to keep the receiver alive after the
phone app has gone to in to the background.  (See [here](#keepAlive) for more
detail)

__note__ Data will be passed in to the `successCallback` in the following
format:

```js
{
  "logUuid": "<uuid of log>",
  "timestamp": <value>,
  "tag": "<tag of transaction>",
  "sessionFinished": true|false,
  "value": <value> // either a String, Number, or String representation of
                   // binary data.
}
```

__Example__

Logging from the C side:

```C
#define LOG_TAG 42

static DataLoggingSessionRef s_session_ref;

static void log_data() {
  const int value = 16;
  const uint32_t num_values = 1;

  // Log a single value
  DataLoggingResult result = data_logging_log(s_session_ref, &value, num_values);

  // Was the value successfully stored? If it failed, print the reason
  if(result != DATA_LOGGING_SUCCESS) {
    APP_LOG(APP_LOG_LEVEL_ERROR, "Error logging data: %d", (int)result);
  }
}

static void init() {
  // ...

  bool continue_session = false;
  s_session_ref = data_logging_create(
      LOG_TAG,
      DATA_LOGGING_INT,
      sizeof(int),
      continue_session
  );

  // ...
}
```

For more information on logging data with the Pebble SDK, see the
[documentation](https://developer.pebble.com/guides/communication/datalogging/)

Reading the data on the JS side:

```js
var uuid = "ebc92429-483e-4b91-b5f2-ead22e7e002d";
var keepAlive = false;
window.pebblekit.registerDataLogReceiver(uuid, function (data) {
  console.log('Received data', JSON.stringify(data));

  /*
  Received data {
    "logUuid": "20dab442-c6d9-4e7f-afe3-a733bd261699",
    "timestamp": 1457982310,
    "tag": 42,
    "sessionFinished": false,
    "value": 16
  }
  */
}, function (err) {
  // error
}, keepAlive);
```

### unregisterDataLogReceiver([successCallback], [errorCallback])

Stop listening for data logging messages.

__Arguments__

* `successCallback` - *Optional* A callback which is called once the receiver
has been unregistered
* `errorCallback` - *Optional* A callback which is called if an error has
occurred

__Example__

```js
window.pebblekit.unregisterDataLogReceiver(function() {
  // receiver has been unregistered
}, function (err) {
  // error
});
```

### keepAlive
Some functions have a `keepAlive` parameter.  By default, this plugin will take
care of unregistering receivers for you when the app goes into the background
in order to avoid memory leaks.

If you set this option to `true`, you should make sure to call the
corresponding `unregisterX()` function when you are done with it.

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
4. `make run` (or `cordova run android --device`).  Make sure you have an Android
device plugged in.  Congrats.  You are now running the companion app for your
application

__note__  Running `make` with no dependencies will overwrite the source files of
the plugin with the corresponding files in the built android directory.  Read
[here](#android-1) to understand why.

### Build the Pebble Application
1. `cd example/cordova`
2. `pebble build && pebble install --phone <PHONE_IP>`
For more help, see the [documentation](https://developer.pebble.com/guides/tools-and-resources/pebble-tool/)

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
`execute()`.  The arguments to the JS side of the `exec()` call are as follows

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
`example/cordova/platforms/android/com/pebble/cordovapebblekit/`.

You can open Android Studio to the `example/cordova/platforms/android` directory
and you will be able to explore the source code, set breakpoints, and view
the logcat just like any other Android project.

With this, you have the full power of the IDE, including code completion,
refactoring, formatting, etc.  The only caveat is that you are editing the
built files instead of the source files of the plugin.  Because of this, the
makefile has been setup to copy the Plugin files from the
`example/cordova/platforms/android` directory to the `lib/src/android`
This way, changes made to the plugin source files through the IDE will not be
lost.

Running `make` with no arugments will copy the files over, read the plugin,
and the run the project on a plugged in android device.
