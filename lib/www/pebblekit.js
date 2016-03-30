var exec = require('cordova/exec');

var CLASS_NAME = 'PebbleKitCordovaWrapper';

module.exports = {
  setupIos: setupIos,
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
};

function genericErrorHandler(errorMessage) {
  console.log(errorMessage);
}

function setupIos(uuid, successCallback, errorCallback) {
  if (!uuid) {
    console.error('uuid is a mandatory argument');
    return;
  }

  if (!successCallback) {
    console.error('successCallback is a mandatory argument');
    return;
  }

  if (!errorCallback) errorCallback = genericErrorHandler;
  exec(successCallback, errorCallback, CLASS_NAME, 'setupIos', [uuid]);
}

function isWatchConnected(successCallback, errorCallback) {
  if (!successCallback) {
    console.error('successCallback is a mandatory argument');
    return;
  }

  if (!errorCallback) errorCallback = genericErrorHandler;
  exec(successCallback, errorCallback, CLASS_NAME, 'isWatchConnected', []);
}

function registerPebbleConenctedReceiver(successCallback, errorCallback, keepAlive) {
  if (!successCallback) {
    console.error('successCallback is a mandatory argument');
    return;
  }

  if (!errorCallback) errorCallback = genericErrorHandler;
  if (!keepAlive) keepAlive = false;
  exec(successCallback, errorCallback, CLASS_NAME, 'registerPebbleConnectedReceiver', [keepAlive]);
}

function registerPebbleDisconnectedReceiver(successCallback, errorCallback, keepAlive) {
  if (!successCallback) {
    console.error('successCallback is a mandatory argument');
    return;
  }

  if (!errorCallback) errorCallback = genericErrorHandler;
  if (!keepAlive) keepAlive = false;
  exec(successCallback, errorCallback, CLASS_NAME, 'registerPebbleDisconnectedReceiver', [keepAlive]);
}

function unregisterPebbleConnectedReceiver(successCallback, errorCallback) {
  if (!errorCallback) errorCallback = genericErrorHandler;
  exec(successCallback, errorCallback, CLASS_NAME, 'unregisterPebbleConnectedReceiver', []);
}

function unregisterPebbleDisconnectedReceiver(successCallback, errorCallback) {
  if (!errorCallback) errorCallback = genericErrorHandler;
  exec(successCallback, errorCallback, CLASS_NAME, 'unregisterPebbleDisconnectedReceiver', []);
}

function startAppOnPebble(uuid, successCallback, errorCallback) {
  if (!errorCallback) errorCallback = genericErrorHandler;
  exec(successCallback, errorCallback, CLASS_NAME, 'startAppOnPebble', [uuid]);
}

function closeAppOnPebble(uuid, successCallback, errorCallback) {
  if (!errorCallback) errorCallback = genericErrorHandler;
  exec(successCallback, errorCallback, CLASS_NAME, 'closeAppOnPebble', [uuid]);
}

function areAppMessagesSupported(successCallback, errorCallback) {
  if (!successCallback) {
    console.error('successCallback is a mandatory argument');
    return;
  }
  if (!errorCallback) errorCallback = genericErrorHandler;
  exec(successCallback, errorCallback, CLASS_NAME, 'areAppMessagesSupported', []);
}

function sendAppMessage(uuid, data, ackHandler, nackHandler, errorCallback) {
  if (!uuid) {
    console.error('First argument must be uuid of watchface');
    return;
  }

  if (!data) {
    console.error('Second argument must be JSON to send to the watch');
    return;
  }

  if (!ackHandler) {
    console.error('third argument must be a function (ackHandler)');
    return;
  }

  if (!nackHandler) {
    console.error('fourth argument must be a function (nackHandler)');
    return;
  }

  if (!errorCallback) errorCallback = genericErrorHandler;

  function successCallback(response) {
    if (response.isAck) {
      ackHandler(response.transactionId);
    }  else {
      nackHandler(response.transactionId);
    }
  }

  exec(successCallback, errorCallback, CLASS_NAME, 'sendAppMessage', [uuid, data]);
}

function registerReceivedDataHandler(uuid, successCallback, errorCallback, keepAlive) {
  if (!uuid) {
    console.error('First argument must be uuid of watch app');
    return;
  }

  if (!successCallback) {
    console.error('Second argument must be a function to receive data');
    return;
  }

  if (!errorCallback) errorCallback = genericErrorHandler;
  if (!keepAlive) keepAlive = false;
  exec(successCallback, errorCallback, CLASS_NAME, 'registerReceivedDataHandler', [uuid, keepAlive]);
}

function unregisterReceivedDataHandler(successCallback, errorCallback) {
  if (!errorCallback) errorCallback = genericErrorHandler;
  exec(successCallback, errorCallback, CLASS_NAME, 'unregisterReceivedDataHandler', []);
}
