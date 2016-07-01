// The MIT License (MIT)
//
// Copyright (c) 2016 Pebble Technology
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "PebbleKitCordovaWrapper.h"
#import <Cordova/CDVPlugin.h>
#import <PebbleKit/PebbleKit.h>

#define ERROR_MSG_NO_WATCH @"No watch connected"
#define ERROR_MSG_APP_UUID_MISSING @"App UUID is missing"

@interface PebbleKitCordovaWrapper () <PBPebbleCentralDelegate>

@property (strong, nonatomic) PBWatch *watch;
@property (strong, nonatomic) PBPebbleCentral *central;

@property (copy, nonatomic) NSString *setupCallbackId;
@property (copy, nonatomic) NSString *pebbleConnectedCallbackId;
@property (copy, nonatomic) NSString *pebbleDisconnectedCallbackId;

@property (assign, nonatomic) BOOL dataReceivedHandlerRegistered;
@property (assign, nonatomic) BOOL wasSetup;

@end

@implementation PebbleKitCordovaWrapper

#pragma mark - Exposed Cordova Functions

- (void)setup:(CDVInvokedUrlCommand *)command {
    if (self.wasSetup) {
        return;
    }

    if (self.watch) {
        [self sendErrorPluginResult:command.callbackId messageAsString:@"Already setup... This method should only be called once"];
        return;
    }

    self.setupCallbackId = command.callbackId;

    self.central = [PBPebbleCentral defaultCentral];
    NSString *uuidString = command.arguments.firstObject;
    if (!uuidString) {
        [self sendErrorPluginResult:command.callbackId messageAsString:ERROR_MSG_APP_UUID_MISSING];
        return;
    }

    self.central.appUUID = [[NSUUID alloc] initWithUUIDString:uuidString];
    if (!self.central.appUUID) {
        [self sendErrorPluginResult:command.callbackId messageAsString:@"Unknown or invalid app UUID"];
        return;
    }

    [self.central run];

    [self sendLongLivedPluginResult:command.callbackId];

    self.central.delegate = self;

    self.wasSetup = YES;
}

- (void)isWatchConnected:(CDVInvokedUrlCommand *)command {
    CDVPluginResult* pluginResult = nil;
    if (self.watch) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                           messageAsBool:[self.watch isConnected]];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                         messageAsString:ERROR_MSG_NO_WATCH];
    }

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)registerPebbleConnectedReceiver:(CDVInvokedUrlCommand *)command {
    if (self.pebbleConnectedCallbackId) {
        [self sendErrorPluginResult:command.callbackId messageAsString:@"Pebble connected receiver already registered"];
        return;
    }

    self.pebbleConnectedCallbackId = command.callbackId;
    [self sendLongLivedPluginResult:command.callbackId];
}

- (void)registerPebbleDisconnectedReceiver:(CDVInvokedUrlCommand *)command {
    if (self.pebbleDisconnectedCallbackId) {
        [self sendErrorPluginResult:command.callbackId messageAsString:@"Pebble disconnected receiver already registered"];
        return;
    }

    self.pebbleDisconnectedCallbackId = command.callbackId;
    [self sendLongLivedPluginResult:command.callbackId];
}

- (void)unregisterPebbleConnectedReceiver:(CDVInvokedUrlCommand *)command {
    CDVPluginResult *pluginResult;

    if (self.pebbleConnectedCallbackId) {
        self.pebbleConnectedCallbackId = nil;
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                         messageAsString:@"No Pebble connected receiver registered"];
    }

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)unregisterPebbleDisconnectedReceiver:(CDVInvokedUrlCommand *)command {
    CDVPluginResult *pluginResult;

    if (self.pebbleDisconnectedCallbackId) {
        self.pebbleDisconnectedCallbackId = nil;
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                         messageAsString:@"No Pebble disconnected receiver registered"];
    }

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)startAppOnPebble:(CDVInvokedUrlCommand *)command {
    if (!self.watch) {
        [self sendErrorPluginResult:command.callbackId messageAsString:ERROR_MSG_NO_WATCH];
        return;
    }

    NSString *uuidString = command.arguments.firstObject;
    if (!uuidString) {
        [self sendErrorPluginResult:command.callbackId messageAsString:ERROR_MSG_APP_UUID_MISSING];
        return;
    }
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:uuidString];

    [self.watch appMessagesLaunch:^(PBWatch * _Nonnull watch, NSError * _Nullable error) {
        CDVPluginResult *pluginResult;

        if (error) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                             messageAsString:error.localizedDescription];
        } else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        }

        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    } withUUID:uuid];

    [self sendLongLivedPluginResult:command.callbackId];
}

- (void)closeAppOnPebble:(CDVInvokedUrlCommand *)command {
    if (!self.watch) {
        [self sendErrorPluginResult:command.callbackId messageAsString:ERROR_MSG_NO_WATCH];
        return;
    }

    [self.watch appMessagesKill:^(PBWatch * _Nonnull watch, NSError * _Nullable error) {
        CDVPluginResult *pluginResult;
        if (error) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.localizedDescription];
        } else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        }
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];

    [self sendLongLivedPluginResult:command.callbackId];
}

- (void)areAppMessagesSupported:(CDVInvokedUrlCommand *)command {
    if (!self.watch) {
        [self sendErrorPluginResult:command.callbackId messageAsString:ERROR_MSG_NO_WATCH];
        return;
    }

    [self.watch getVersionInfo:^(PBWatch * _Nonnull watch, PBVersionInfo * _Nonnull versionInfo) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                            messageAsBool:versionInfo.appMessagesSupported];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

    } onTimeout:^(PBWatch * _Nonnull watch) {
        [self sendErrorPluginResult:command.callbackId messageAsString:@"Timeout while getting version info"];
    }];

    [self sendLongLivedPluginResult:command.callbackId];
}

- (void)sendAppMessage:(CDVInvokedUrlCommand *)command {
    if (!self.watch) {
        [self sendErrorPluginResult:command.callbackId messageAsString:ERROR_MSG_NO_WATCH];
        return;
    }

    NSString *uuidString = command.arguments.firstObject;
    if (!uuidString) {
        [self sendErrorPluginResult:command.callbackId messageAsString:ERROR_MSG_APP_UUID_MISSING];
        return;
    }
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:uuidString];

    NSDictionary *json = (command.arguments.count > 1 ? command.arguments[1] : nil);
    NSMutableDictionary *appMessage = [[NSMutableDictionary alloc] init];

    // JSON received by Cordova is not appropriate to send directly to PebbleKit,
    // recreate the dictionary with appropriate types before sending to PebbleKit.
    for (NSString *key in json) {
        id value = json[key];
        NSLog(@"{key=%@, value=%@} class=%@", key, value, [value class]);

        NSNumber *keyAsNumber = [NSNumber numberWithInteger:[key integerValue]];

        if ([value isKindOfClass:[NSNumber class]]) {
            NSNumber *valueAsInt32 = [NSNumber numberWithInt32:(int32_t)[value integerValue]];
            [appMessage setObject:valueAsInt32 forKey:keyAsNumber];

        } else if ([value isKindOfClass:[NSString class]]) {
            // No type conversion necessary
            [appMessage setObject:value forKey:keyAsNumber];

        } else {
            NSString *errorMessage = [NSString stringWithFormat:@"Unsupported type %@ for key %@", [value class], key];
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                                              messageAsString:errorMessage];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            return;
        }
    }

    [self.watch appMessagesPushUpdate:appMessage withUUID:uuid
                               onSent:^(PBWatch * _Nonnull watch, NSDictionary * _Nonnull update, NSError * _Nonnull error) {
        CDVPluginResult *pluginResult;

        if (error) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.localizedDescription];

        } else {
            NSDictionary *data = @{
                @"isAck": @YES,
                @"transactionId": @(-1)
            };

            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:data];
        }

        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];

    [self sendLongLivedPluginResult:command.callbackId];
}

- (void)registerReceivedDataHandler:(CDVInvokedUrlCommand *)command {
    if (!self.watch) {
        [self sendErrorPluginResult:command.callbackId messageAsString:ERROR_MSG_NO_WATCH];
        return;
    }

    if (self.dataReceivedHandlerRegistered) {
        [self sendErrorPluginResult:command.callbackId messageAsString:@"Data received handler already registered"];
        return;
    }

    NSString *uuidString = command.arguments.firstObject;
    if (!uuidString) {
        [self sendErrorPluginResult:command.callbackId messageAsString:ERROR_MSG_APP_UUID_MISSING];
        return;
    }
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:uuidString];

    [self.watch appMessagesAddReceiveUpdateHandler:^BOOL(PBWatch * _Nonnull watch, NSDictionary<NSNumber *,id> * _Nonnull update) {
        NSLog(@"received app message %@", update);
        NSMutableDictionary *appMessage = [[NSMutableDictionary alloc] init];

        // Repackage NSDictionary with correct types
        for (NSNumber *key in update) {
            id value = update[key];

            if ([value isKindOfClass:[NSData class]]) {
                NSString *encodedData = [value base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
                appMessage[key.stringValue] = encodedData;
            } else {
                appMessage[key.stringValue] = value;
            }
        }

        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:appMessage];
        [pluginResult setKeepCallbackAsBool:YES];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

        return YES;
    } withUUID:uuid];

    self.dataReceivedHandlerRegistered = YES;
    [self sendLongLivedPluginResult:command.callbackId];
}

#pragma mark - PBPebbleCentralDelegate

- (void)pebbleCentral:(PBPebbleCentral *)central watchDidConnect:(PBWatch *)watch isNew:(BOOL)isNew {
    if (self.watch) {
        return;
    }
    
    self.watch = watch;

    [self.watch getVersionInfo:^(PBWatch * _Nonnull watch, PBVersionInfo * _Nonnull versionInfo) {
        NSLog(@"appMessagesSupported: %@", versionInfo.appMessagesSupported ? @"YES" : @"NO");

        if (self.setupCallbackId) {
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:self.setupCallbackId];
            self.setupCallbackId = nil;
            return;
        }

        if (self.pebbleConnectedCallbackId) {
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            [pluginResult setKeepCallbackAsBool:YES];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:self.pebbleConnectedCallbackId];
        }

    } onTimeout:^(PBWatch * _Nonnull watch) {
        NSLog(@"Failed to get version info.");
    }];

}

- (void)pebbleCentral:(PBPebbleCentral *)central watchDidDisconnect:(PBWatch *)watch {
    if (self.pebbleDisconnectedCallbackId) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [pluginResult setKeepCallbackAsBool:YES];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.pebbleDisconnectedCallbackId];
    }

    if (self.watch == watch) {
        return;
    }

    self.watch = nil;
}

#pragma mark - Util Functions

- (void)sendLongLivedPluginResult:(NSString *)callbackId {
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_NO_RESULT];
    [pluginResult setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
}

- (void)sendErrorPluginResult:(NSString *)callbackId messageAsString:(NSString *)message {
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                                    messageAsString:message];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
}

@end
