package com.pebble.cordovapebblekit;


import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.util.Log;

import com.getpebble.android.kit.PebbleKit;
import com.getpebble.android.kit.util.PebbleDictionary;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.UUID;

public class PebbleKitCordovaWrapper extends CordovaPlugin {

    private static final String TAG = "PebbleKit";

    private static final int ARGS_INDEX_APP_MESSAGE_DATA = 1;

    private CallbackContext mPebbleConnectedCallbackContext;
    private CallbackContext mPebbleDisconnectedCallbackContext;
    private CallbackContext mPebbleSendAppMessageCallbackContext;
    private CallbackContext mPebbleDataReceivedCallbackContext;

    private BroadcastReceiver mPebbleConnectedBroadcastReceiver;
    private BroadcastReceiver mPebbleDisconnectedBroadcastReceiver;
    private PebbleKit.PebbleAckReceiver mPebbleAckReceiver;
    private PebbleKit.PebbleNackReceiver mPebbleNackReceiver;
    private PebbleKit.PebbleDataReceiver mPebbleDataReceiver;

    private final Map<BroadcastReceiver, Boolean> mKeepReceiversAliveMap = new HashMap<BroadcastReceiver, Boolean>();

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) {

        if (action.equals("setup")) {
            // iOS specific method, no Android implementation necessary.
            callbackContext.success();
            return true;

        } else if (action.equals("isWatchConnected")) {
            isWatchConnected(callbackContext);
            return true;

        } else if (action.equals("registerPebbleConnectedReceiver")) {
            registerPebbleConnectedReceiver(args, callbackContext);
            return true;

        } else if (action.equals("registerPebbleDisconnectedReceiver")) {
            registerPebbleDisconnectedReceiver(args, callbackContext);
            return true;

        } else if (action.equals("unregisterPebbleConnectedReceiver")) {
            unregisterPebbleConnectedReceiver(callbackContext);
            return true;

        } else if (action.equals("unregisterPebbleDisconnectedReceiver")) {
            unregisterPebbleDisconnectedReceiver(callbackContext);
            return true;

        } else if (action.equals("startAppOnPebble")) {
            startAppOnPebble(args, callbackContext);
            return true;

        } else if (action.equals("closeAppOnPebble")) {
            closeAppOnPebble(args, callbackContext);
            return true;

        } else if (action.equals("areAppMessagesSupported")) {
            areAppMessagesSupported(callbackContext);
            return true;

        } else if (action.equals("sendAppMessage")) {
            sendAppMessage(args, callbackContext);
            return true;

        } else if (action.equals("registerReceivedDataHandler")) {
            registerReceivedDataHandler(args, callbackContext);
            return true;

        } else if (action.equals("unregisterReceivedDataHandler")) {
            unregisterReceivedDataHandler(callbackContext);
            return true;
        }

        return false;
    }

    @Override
    public void onPause(boolean multitasking) {
        super.onPause(multitasking);

        Iterator<Map.Entry<BroadcastReceiver, Boolean>> iterator = mKeepReceiversAliveMap.entrySet().iterator();

        while (iterator.hasNext()) {
            Map.Entry<BroadcastReceiver, Boolean> entry = iterator.next();

            boolean keepAlive = entry.getValue();
            if (keepAlive) continue;

            Util.tryUnregisterReceiver(cordova.getActivity(), entry.getKey());
            iterator.remove();
        }
    }

    private void isWatchConnected(CallbackContext callbackContext) {
        boolean connected = PebbleKit.isWatchConnected(cordova.getActivity());
        PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, connected);
        callbackContext.sendPluginResult(pluginResult);
    }

    private void registerPebbleConnectedReceiver(JSONArray args, CallbackContext callbackContext) {
        if (mPebbleConnectedBroadcastReceiver != null) {
            callbackContext.error("Pebble connected receiver already registered");
            return;
        }

        Boolean keepAlive = Util.getKeepAliveFromArgs(args, 0, callbackContext);
        if (keepAlive == null) return;

        mPebbleConnectedBroadcastReceiver = getPebbleConnectedBroadcastreceiver();
        mPebbleConnectedCallbackContext = callbackContext;
        mKeepReceiversAliveMap.put(mPebbleConnectedBroadcastReceiver, keepAlive);

        PebbleKit.registerPebbleConnectedReceiver(cordova.getActivity(), mPebbleConnectedBroadcastReceiver);
        Util.sendLongLivedPluginResult(callbackContext);
    }

    private void registerPebbleDisconnectedReceiver(JSONArray args, CallbackContext callbackContext) {
        if (mPebbleDisconnectedBroadcastReceiver != null) {
            callbackContext.error("Pebble connected receiver already registered");
            return;
        }

        Boolean keepAlive = Util.getKeepAliveFromArgs(args, 0, callbackContext);
        if (keepAlive == null) return;

        mPebbleDisconnectedBroadcastReceiver = getPebbleDisconnectedBroadcastReceiver();
        mPebbleDisconnectedCallbackContext = callbackContext;
        mKeepReceiversAliveMap.put(mPebbleDisconnectedBroadcastReceiver, keepAlive);

        PebbleKit.registerPebbleDisconnectedReceiver(cordova.getActivity(), mPebbleDisconnectedBroadcastReceiver);
        Util.sendLongLivedPluginResult(callbackContext);
    }

    private void unregisterPebbleConnectedReceiver(CallbackContext callbackContext) {
        if (mPebbleConnectedBroadcastReceiver == null) {
            callbackContext.error("No pebble connected receiver registered");
            return;
        }

        Util.tryUnregisterReceiver(cordova.getActivity(), mPebbleConnectedBroadcastReceiver);
        mPebbleConnectedBroadcastReceiver = null;
        mPebbleConnectedCallbackContext = null;
        callbackContext.success();
    }

    private void unregisterPebbleDisconnectedReceiver(CallbackContext callbackContext) {
        if (mPebbleDisconnectedBroadcastReceiver == null) {
            callbackContext.error("No pebble connected receiver registered");
            return;
        }

        Util.tryUnregisterReceiver(cordova.getActivity(), mPebbleDisconnectedBroadcastReceiver);
        mPebbleDisconnectedBroadcastReceiver = null;
        mPebbleDisconnectedCallbackContext = null;
        callbackContext.success();
    }

    private void startAppOnPebble(JSONArray args, CallbackContext callbackContext) {
        UUID appUuid = Util.getUuidFromArgs(args, callbackContext);
        if (appUuid == null) return;

        PebbleKit.startAppOnPebble(cordova.getActivity(), appUuid);
        callbackContext.success();
    }

    private void closeAppOnPebble(JSONArray args, CallbackContext callbackContext) {
        UUID appUuid = Util.getUuidFromArgs(args, callbackContext);
        if (appUuid == null) return;

        PebbleKit.closeAppOnPebble(cordova.getActivity(), appUuid);
        callbackContext.success();
    }

    private void areAppMessagesSupported(CallbackContext callbackContext) {
        boolean supported = PebbleKit.areAppMessagesSupported(cordova.getActivity());
        PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, supported);
        callbackContext.sendPluginResult(pluginResult);
    }

    private void sendAppMessage(JSONArray args, CallbackContext callbackContext) {
        UUID appUuid = Util.getUuidFromArgs(args, callbackContext);
        if (appUuid == null) return;

        JSONObject data;
        try {
            data = args.getJSONObject(ARGS_INDEX_APP_MESSAGE_DATA);
        } catch (JSONException e) {
            callbackContext.error("Second argument must be JSON Object containing data");
            return;
        }

        PebbleDictionary pebbleDictionary = Util.jsonToPebbleDictionary(data, callbackContext);
        if (pebbleDictionary == null) return;

        mPebbleSendAppMessageCallbackContext = callbackContext;

        mPebbleAckReceiver = getPebbleAckReceiver(appUuid);
        mPebbleNackReceiver = getPebbleNackReceiver(appUuid);
        PebbleKit.registerReceivedAckHandler(cordova.getActivity(), mPebbleAckReceiver);
        PebbleKit.registerReceivedNackHandler(cordova.getActivity(), mPebbleNackReceiver);
        PebbleKit.sendDataToPebble(cordova.getActivity(), appUuid, pebbleDictionary);
        Util.sendLongLivedPluginResult(mPebbleSendAppMessageCallbackContext);
    }

    private void registerReceivedDataHandler(JSONArray args, CallbackContext callbackContext) {
        if (mPebbleDataReceiver != null) {
            callbackContext.error("Received data handler already registered");
            return;
        }

        UUID uuid = Util.getUuidFromArgs(args, callbackContext);
        if (uuid == null) return;

        Boolean keepAlive = Util.getKeepAliveFromArgs(args, 1, callbackContext);
        if (keepAlive == null) return;

        mPebbleDataReceivedCallbackContext = callbackContext;
        mPebbleDataReceiver = getPebbleDataReceiver(uuid);
        mKeepReceiversAliveMap.put(mPebbleDataReceiver, keepAlive);

        PebbleKit.registerReceivedDataHandler(cordova.getActivity(), mPebbleDataReceiver);
        Util.sendLongLivedPluginResult(mPebbleDataReceivedCallbackContext);
    }

    private void unregisterReceivedDataHandler(CallbackContext callbackContext) {
        if (mPebbleDataReceiver == null) {
            callbackContext.error("No data receiver registered");
            return;
        }

        Util.tryUnregisterReceiver(cordova.getActivity(), mPebbleDataReceiver);
        mKeepReceiversAliveMap.remove(mPebbleDataReceiver);
        mPebbleDataReceiver = null;
        callbackContext.success();
    }

    private BroadcastReceiver getPebbleConnectedBroadcastreceiver() {
        if (mPebbleConnectedBroadcastReceiver != null)  return mPebbleConnectedBroadcastReceiver;

        return new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                if (mPebbleConnectedCallbackContext == null) {
                    Log.e(TAG, "mPebbleConnectedCallbackContext is null");
                    return;
                }

                PluginResult pluginResult = new PluginResult(PluginResult.Status.OK);
                pluginResult.setKeepCallback(true);
                mPebbleConnectedCallbackContext.sendPluginResult(pluginResult);
            }
        };
    }

    private BroadcastReceiver getPebbleDisconnectedBroadcastReceiver() {
        if (mPebbleDisconnectedBroadcastReceiver != null) return mPebbleDisconnectedBroadcastReceiver;

        return new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                if (mPebbleDisconnectedCallbackContext == null) {
                    Log.e(TAG, "mPebbleDisconnectedCallbackContext is null");
                    return;
                }

                PluginResult pluginResult = new PluginResult(PluginResult.Status.OK);
                pluginResult.setKeepCallback(true);
                mPebbleDisconnectedCallbackContext.sendPluginResult(pluginResult);
            }
        };
    }

    private PebbleKit.PebbleAckReceiver getPebbleAckReceiver(UUID appUuid) {
        if (mPebbleAckReceiver != null) return mPebbleAckReceiver;

        return new PebbleKit.PebbleAckReceiver(appUuid) {
            @Override
            public void receiveAck(Context context, int transactionId) {
                handleAckNackResponse(true, transactionId);
            }
        };
    }

    private PebbleKit.PebbleNackReceiver getPebbleNackReceiver(UUID appUuid) {
        if (mPebbleNackReceiver != null) return mPebbleNackReceiver;

        return new PebbleKit.PebbleNackReceiver(appUuid) {
            @Override
            public void receiveNack(Context context, int transactionId) {
                handleAckNackResponse(false, transactionId);
            }
        };
    }

    private void handleAckNackResponse(boolean isAck, int transactionId) {
        if (mPebbleSendAppMessageCallbackContext == null) {
            Log.e(TAG, "mPebbleSendAppMessageCallbackContext is null");
            return;
        }

        JSONObject data = new JSONObject();
        try {
            data.put("isAck", isAck);
            data.put("transactionId", transactionId);
        } catch (JSONException e) {
            mPebbleSendAppMessageCallbackContext.error("Failed to create ackNack response");
            return;
        }

        PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, data);
        mPebbleSendAppMessageCallbackContext.sendPluginResult(pluginResult);
        cordova.getActivity().unregisterReceiver(mPebbleAckReceiver);
        cordova.getActivity().unregisterReceiver(mPebbleNackReceiver);
        mPebbleAckReceiver = null;
        mPebbleNackReceiver = null;
    }

    private PebbleKit.PebbleDataReceiver getPebbleDataReceiver(UUID appUuid) {
        if (mPebbleDataReceiver != null) return mPebbleDataReceiver;

        return new PebbleKit.PebbleDataReceiver(appUuid) {
            @Override
            public void receiveData(Context context, int transactionId, PebbleDictionary data) {
                if (mPebbleDataReceivedCallbackContext == null) {
                    Log.e(TAG, "mPebbleDataReceivedCallbackContext is null");
                    return;
                }

                JSONObject jsonData = Util.pebbleDictionaryToAppMessageJson(data);
                if (jsonData == null) {
                    mPebbleDataReceivedCallbackContext.error(String.format(
                            "Failed to read app message for transaction %d",
                            transactionId
                    ));
                    PebbleKit.sendNackToPebble(cordova.getActivity(), transactionId);
                    return;
                }

                PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, jsonData);
                pluginResult.setKeepCallback(true);
                mPebbleDataReceivedCallbackContext.sendPluginResult(pluginResult);
                PebbleKit.sendAckToPebble(cordova.getActivity(), transactionId);
            }
        };
    }
}
