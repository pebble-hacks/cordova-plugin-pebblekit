package com.pebble.cordovapebblekit;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.util.Log;

import com.getpebble.android.kit.util.PebbleDictionary;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.UUID;

public class Util {

    private static final String TAG = "Util";

    // The app UUID will always be the first argument in the `args` JSONArray
    private static final int ARGS_INDEX_APP_UUID = 0;

    public static JSONObject pebbleDictionaryToAppMessageJson(PebbleDictionary pebbleDictionary) {

        JSONObject appMessage = new JSONObject();
        JSONArray pebbleKitAppMessage;

        try {
            pebbleKitAppMessage = new JSONArray(pebbleDictionary.toJsonString());
        } catch (JSONException e) {
            Log.e(TAG, "Couldn't parse pebble dictionary");
            return null;
        }

        JSONObject currentItem;
        String key;
        String type;
        for (int i = 0; i < pebbleKitAppMessage.length(); i++) {

            try {
                currentItem = pebbleKitAppMessage.getJSONObject(i);
            } catch (JSONException e) {
                Log.e(TAG, String.format(
                        "Couldn't parse item %d of %s",
                        i,
                        pebbleKitAppMessage.toString()
                ), e);
                return null;
            }

            try {
                key = String.valueOf(currentItem.getInt("key"));
            } catch (JSONException e) {
                Log.e(TAG, String.format("Couldn't get key for %s", currentItem.toString()), e);
                return null;
            }

            try {
                type = currentItem.getString("type");
            } catch (JSONException e) {
                Log.e(TAG, String.format("Couldn't get type for %s", currentItem.toString()), e);
                return null;
            }

            if (type.equals("uint") || type.equals("int")) {
                try {
                    appMessage.put(key, currentItem.get("value"));
                } catch (JSONException e) {
                    Log.e(TAG, String.format("Couldn't get int value for %s", currentItem.toString()), e);
                    return null;
                }

            } else if (type.equals("string")) {
                try {
                    appMessage.put(key, currentItem.getString("value"));
                } catch (JSONException e) {
                    Log.e(TAG, String.format("Couldn't get string value for %s", currentItem.toString()), e);
                    return null;
                }

            } else if (type.equals("bytes")) {
                try {

                    // Already base64 encoded into a string via PebbleDictionary
                    appMessage.put(key, currentItem.getString("value"));
                } catch (JSONException e) {
                    Log.e(TAG, String.format("Couldn't get bytes for %s", currentItem.toString()), e);
                    return null;
                }

            } else {
                Log.e(TAG, String.format("Unrecognized type %s", type));
                return null;
            }
        }

        try {
            Log.d(TAG, "Got data");
            Log.d(TAG, pebbleKitAppMessage.toString(2));
        } catch (JSONException e) {
            Log.e(TAG, "Couldn't format pebblekit app message");
        }

        try {
            Log.d(TAG, "transformed into");
            Log.d(TAG, appMessage.toString(2));
        } catch (JSONException e) {
            Log.e(TAG, "Couldn't format transformed app message");
        }

        return appMessage;
    }

    public static JSONObject buildDataLogJson(UUID logUuid, Long timestamp, Long tag, boolean sessionFinished) {
        JSONObject jsonData = new JSONObject();

        try {
            jsonData.put("logUuid", logUuid.toString());
            jsonData.put("timestamp", timestamp);
            jsonData.put("tag", tag);
            jsonData.put("sessionFinished", sessionFinished);
        } catch (JSONException e) {
            Log.e(TAG, String.format(
                    "Couldn't pack data: uuid=%s, timestamp=%d, tag=%d",
                    logUuid.toString(),
                    timestamp,
                    tag
            ));
            return null;
        }

        return jsonData;
    }

    public static PebbleDictionary jsonToPebbleDictionary(JSONObject data, CallbackContext callbackContext) {
        Iterator<String> keys = data.keys();
        PebbleDictionary pebbleDictionary = new PebbleDictionary();

        while (keys.hasNext()) {
            String keyString = keys.next();
            int key;

            try {
                key = Integer.parseInt(keyString);
            } catch (NumberFormatException e) {
                callbackContext.error(String.format("Key must be an integer, instead found %s", keyString));
                return null;
            }

            Object value;

            try {
                value = data.get(keyString);
            } catch (JSONException e) {
                Log.e(TAG, String.format("Failed to extract value with key %s", keyString), e);
                callbackContext.error(String.format("Failed to extract value with key %s", keyString));
                return null;
            }

            if (value instanceof Integer) {
                pebbleDictionary.addInt32(key, (Integer) value);

            } else if (value instanceof JSONArray) {
                pebbleDictionary.addBytes(key, jsonArrayToBytes((JSONArray) value));

            } else if (value instanceof String) {
                pebbleDictionary.addString(key, (String) value);
            }
        }

        return pebbleDictionary;
    }

    private static byte[] jsonArrayToBytes(JSONArray jsonArray) {

        // Must use a list since we do not know what the size of the byte array is
        // This is because the arrays in javascript are not type-strict.  Users can pass
        // a mix of numbers and strings into the array.
        List<Byte> bytesList = new ArrayList<Byte>();

        for (int i = 0; i < jsonArray.length(); i++) {
            Object value;

            try {
                value = jsonArray.get(i);
            } catch (JSONException e) {
                Log.e(TAG, String.format("Failed to get value %d from jsonArray %s", i, jsonArray.toString()), e);
                return null;
            }

            if (value instanceof Integer) {
                bytesList.add(((Integer) value).byteValue());

            } else if (value instanceof String) {
                String stringValue = (String) value;
                for (byte byteValue : stringValue.getBytes()) {
                    bytesList.add(byteValue);
                }

            } else {
                Log.e(TAG, String.format("Unknown type in sendAppMessage %s", value.toString()));
            }
        }

        // Convert to primitive byte array
        byte[] bytes = new byte[bytesList.size()];

        for (int i = 0; i < bytesList.size(); i++) {
            bytes[i] = bytesList.get(i);
        }

        return bytes;
    }

    public static void tryUnregisterReceiver(Context context, BroadcastReceiver broadcastReceiver) {
        try {
            context.unregisterReceiver(broadcastReceiver);
        } catch (IllegalArgumentException e) {
            // TODO: Figure out why this exception is being thrown for receivers that _are_ registered
        }
    }

    public static void sendLongLivedPluginResult(CallbackContext callbackContext) {
        PluginResult immediatePluginResult = new PluginResult(PluginResult.Status.NO_RESULT);
        immediatePluginResult.setKeepCallback(true);
        callbackContext.sendPluginResult(immediatePluginResult);
    }

    public static UUID getUuidFromArgs(JSONArray args, CallbackContext callbackContext) {
        String stringUuid = args.optString(ARGS_INDEX_APP_UUID);
        if (stringUuid == null) {
            callbackContext.error("Expected first argument to be app uuid");
            return null;
        }

        try {
            return UUID.fromString(stringUuid);

        } catch (IllegalArgumentException e) {
            callbackContext.error(String.format("Invalid uuid: %s", stringUuid));
            return null;
        }
    }

    public static Boolean getKeepAliveFromArgs(JSONArray args, int argumentIndex, CallbackContext callbackContext) {
        try {
            return args.getBoolean(argumentIndex);

        } catch (JSONException e) {
            callbackContext.error("Illegal value for keepAlive");
            return null;
        }
    }
}
