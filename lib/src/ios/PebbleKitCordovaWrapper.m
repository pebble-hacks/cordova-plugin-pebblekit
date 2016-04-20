#import "PebbleKitCordovaWrapper.h"
#import <Cordova/CDVPlugin.h>
#import <PebbleKit/PebbleKit.h>

#define ERROR_MSG_NO_WATCH @"No watch connected"

@interface PebbleKitCordovaWrapper () <PBPebbleCentralDelegate>

@property (weak, nonatomic) PBWatch *watch;
@property (weak, nonatomic) PBPebbleCentral *central;

@property (copy, nonatomic) NSString *setupCallbackId;
@property (copy, nonatomic) NSString *pebbleConnectedCallbackId;
@property (copy, nonatomic) NSString *pebbleDisconnectedCallbackId;

@property (assign, nonatomic) BOOL dataReceivedHandlerRegistered;

@end

@implementation PebbleKitCordovaWrapper

#pragma mark - Exposed Cordova Functions

- (void)setup:(CDVInvokedUrlCommand *)command {
    if (self.watch) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                                          messageAsString:@"Already setup... This method should only be called once"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }

    self.setupCallbackId = command.callbackId;

    self.central = [PBPebbleCentral defaultCentral];
    NSString *uuidString = [command.arguments objectAtIndex:0];
    self.central.appUUID = [[NSUUID alloc] initWithUUIDString:uuidString];
    [self.central run];

    [self sendLongLivedPluginResult:command.callbackId];

    self.central.delegate = self;
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
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                                          messageAsString:@"Pebble connected receiver already registered"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }

    self.pebbleConnectedCallbackId = command.callbackId;
    [self sendLongLivedPluginResult:command.callbackId];
}

- (void)registerPebbleDisconnectedReceiver:(CDVInvokedUrlCommand *)command {
    if (self.pebbleDisconnectedCallbackId) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                                          messageAsString:@"Pebble disconnected receiver already registered"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
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
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                                          messageAsString:ERROR_MSG_NO_WATCH];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }

    NSString *uuidString = [command.arguments objectAtIndex:0];
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
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                                          messageAsString:ERROR_MSG_NO_WATCH];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }

    NSString *uuidString = [command.arguments objectAtIndex:0];
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:uuidString];

    [self.watch appMessagesKill:^(PBWatch * _Nonnull watch, NSError * _Nullable error) {
        CDVPluginResult *pluginResult;
        if (error) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.localizedDescription];
        } else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        }
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    } withUUID:uuid];

    [self sendLongLivedPluginResult:command.callbackId];
}

- (void)areAppMessagesSupported:(CDVInvokedUrlCommand *)command {
    if (!self.watch) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                                          messageAsString:ERROR_MSG_NO_WATCH];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }

    [self.watch getVersionInfo:^(PBWatch * _Nonnull watch, PBVersionInfo * _Nonnull versionInfo) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                            messageAsBool:versionInfo.appMessagesSupported];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

    } onTimeout:^(PBWatch * _Nonnull watch) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                                          messageAsString:@"Timeout while getting version info"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];

    [self sendLongLivedPluginResult:command.callbackId];
}

- (void)sendAppMessage:(CDVInvokedUrlCommand *)command {
    if (!self.watch) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:ERROR_MSG_NO_WATCH];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }

    NSString *uuidString = [command.arguments objectAtIndex:0];
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:uuidString];

    NSDictionary *json = [command.arguments objectAtIndex:1];
    NSMutableDictionary *appMessage = [[NSMutableDictionary alloc] init];

    // JSON received by Cordova is not appropriate to send directly to PebbleKit,
    // recreate the dictionary with appropriate types before sending to PebbleKit.
    for (NSString *key in json) {
        id value = [json objectForKey:key];
        NSLog(@"{key=%@, value=%@} class=%@", key, value, [value class]);

        NSNumber *keyAsNumber = [NSNumber numberWithInteger:[key integerValue]];

        if ([value isKindOfClass:[NSNumber class]]) {
            NSNumber *valueAsInt32 = [NSNumber numberWithInt32:(int32_t)[value integerValue]];
            [appMessage setObject:valueAsInt32 forKey:keyAsNumber];

        } else if ([value isKindOfClass:[NSString class]]) {
            // No type conversion necessary
            [appMessage setObject:value forKey:keyAsNumber];

        } else if ([value isKindOfClass:[NSArray class]]) {
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:value];
            [appMessage setObject:data forKey:keyAsNumber];

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
            NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                [NSNumber numberWithBool:YES], @"isAck",
                [NSNumber numberWithInteger:-1], @"transactionId",
                nil
            ];

            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:data];
        }

        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];

    [self sendLongLivedPluginResult:command.callbackId];
}

- (void)registerReceivedDataHandler:(CDVInvokedUrlCommand *)command {
    if (!self.watch) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                                          messageAsString:ERROR_MSG_NO_WATCH];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }

    if (self.dataReceivedHandlerRegistered) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                                          messageAsString:@"Data received handler already registered"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }

    NSString *uuidString = [command.arguments objectAtIndex:0];
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:uuidString];

    [self.watch appMessagesAddReceiveUpdateHandler:^BOOL(PBWatch * _Nonnull watch, NSDictionary<NSNumber *,id> * _Nonnull update) {
        NSLog(@"received app message %@", update);
        NSMutableDictionary *appMessage = [[NSMutableDictionary alloc] init];

        // Repackage NSDictionary with correct types
        for (id key in update) {
            id value = [update objectForKey:key];

            if ([value isKindOfClass:[NSData class]]) {
                NSString *encodedData = [value base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
                [appMessage setObject:encodedData forKey:[key stringValue]];
            } else {
                [appMessage setObject:value forKey:[key stringValue]];
            }
        }

        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:appMessage];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

        return YES;
    } withUUID:uuid];

    self.dataReceivedHandlerRegistered = YES;
    [self sendLongLivedPluginResult:command.callbackId];
}

#pragma mark - PBPebbleCentralDelegate

- (void)pebbleCentral:(PBPebbleCentral *)central watchDidConnect:(PBWatch *)watch isNew:(BOOL)isNew {
    if (!self.watch) {
        self.watch = watch;
    }

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
}

- (void)pebbleCentral:(PBPebbleCentral *)central watchDidDisconnect:(PBWatch *)watch {
    if (self.pebbleDisconnectedCallbackId) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [pluginResult setKeepCallbackAsBool:YES];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.pebbleDisconnectedCallbackId];
    }

    if (self.watch == watch) {
        self.watch = nil;
    }
}

#pragma mark - Util Functions

- (void)sendLongLivedPluginResult:(NSString *)callbackId {
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_NO_RESULT];
    [pluginResult setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
}

@end
