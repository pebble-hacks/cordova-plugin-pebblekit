var exec = require('cordova/exec');

var CLASS_NAME = 'PebbleKitCordovaWrapper';

module.exports = {
  isWatchConnected: isWatchConnected,
  registerPebbleConnectedReceiver: registerPebbleConenctedReceiver,
  registerPebbleDisconnectedReceiver: registerPebbleDisconnectedReceiver,
  unregisterPebbleConnectedReceiver: unregisterPebbleConnectedReceiver,
  unregisterPebbleDisconnectedReceiver: unregisterPebbleDisconnectedReceiver,
  startAppOnPebble: startAppOnPebble,
  closeAppOnPebble: closeAppOnPebble,
  areAppMessagesSupported: areAppMessagesSupported,
  sendAppMessage: sendAppMessage,
  registerReceivedDataHandler: registerReceivedDataHandler,
  unregisterReceivedDataHandler: unregisterReceivedDataHandler,
  registerDataLogReceiver: registerDataLogReceiver,
  unregisterDataLogReceiver: unregisterDataLogReceiver
};

function genericErrorHandler(errorMessage) {
  console.log(errorMessage);
}

function isWatchConnected(successHandler, error) {
  if (!error) error = genericErrorHandler;
  exec(successHandler, error, CLASS_NAME, 'isWatchConnected', []);
}

function registerPebbleConenctedReceiver(successHandler, error, keepAlive) {
  if (!error) error = genericErrorHandler;
  if (!keepAlive) keepAlive = false;
  exec(successHandler, error, CLASS_NAME, 'registerPebbleConnectedReceiver', [keepAlive]);
}

function registerPebbleDisconnectedReceiver(successHandler, error, keepAlive) {
  if (!error) error = genericErrorHandler;
  if (!keepAlive) keepAlive = false;
  exec(successHandler, error, CLASS_NAME, 'registerPebbleDisconnectedReceiver', [keepAlive]);
}

function unregisterPebbleConnectedReceiver(successHandler, error) {
  if (!error) error = genericErrorHandler;
  exec(successHandler, error, CLASS_NAME, 'unregisterPebbleConnectedReceiver', []);
}

function unregisterPebbleDisconnectedReceiver(successHandler, error) {
  if (!error) error = genericErrorHandler;
  exec(successHandler, error, CLASS_NAME, 'unregisterPebbleDisconnectedReceiver', []);
}

function startAppOnPebble(uuid, successHandler, error) {
  if (!error) error = genericErrorHandler;
  exec(successHandler, error, CLASS_NAME, 'startAppOnPebble', [uuid]);
}

function closeAppOnPebble(uuid, successHandler, error) {
  if (!error) error = genericErrorHandler;
  exec(successHandler, error, CLASS_NAME, 'closeAppOnPebble', [uuid]);
}

function areAppMessagesSupported(successHandler, error) {
  if (!error) error = genericErrorHandler;
  exec(successHandler, error, CLASS_NAME, 'areAppMessagesSupported', []);
}

function sendAppMessage(uuid, data, ackHandler, nackHandler, error) {
  if (!error) error = genericErrorHandler;

  function successCallback(response) {
    if (response.isAck && ackHandler) ackHandler(response.transactionId);
    else if (!response.isAck && nackHandler) nackHandler(response.transactionId);
  }

  exec(successCallback, error, CLASS_NAME, 'sendAppMessage', [uuid, data]);
}

function registerReceivedDataHandler(uuid, successHandler, error, keepAlive) {
  if (!error) error = genericErrorHandler;
  if (!keepAlive) keepAlive = false;
  exec(successHandler, error, CLASS_NAME, 'registerReceivedDataHandler', [uuid, keepAlive]);
}

function unregisterReceivedDataHandler(successHandler, error, keepAlive) {
  if (!error) error = genericErrorHandler;
  exec(successHandler, error, CLASS_NAME, 'unregisterReceivedDataHandler', []);
}

function registerDataLogReceiver(uuid, successHandler, error, keepAlive) {
  if (!error) error = genericErrorHandler;
  if (!keepAlive) keepAlive = false;
  exec(successHandler, error, CLASS_NAME, 'registerDataLogReceiver', [uuid, keepAlive]);
}

function unregisterDataLogReceiver(successHandler, error) {
  if (!error) error = genericErrorHandler;
  exec(successHandler, error, CLASS_NAME, 'unregisterDataLogReceiver', []);
}
