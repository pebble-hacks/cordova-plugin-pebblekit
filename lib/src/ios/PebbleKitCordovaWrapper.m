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

@property (assign, nonatomic) BOOL pebbleConnectedKeepAlive;
@property (assign, nonatomic) BOOL pebbleDisconnectedKeepAlive;

@end

@implementation PebbleKitCordovaWrapper

-(void)pebbleCentral:(PBPebbleCentral *)central watchDidConnect:(PBWatch *)watch isNew:(BOOL)isNew {
    NSLog(@"watch did connect");
    if (self.setupCallbackId) {
        NSLog(@"Responding to setup");
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

    if (self.watch) {
        return;
    }
    self.watch = watch;
}

-(void)pebbleCentral:(PBPebbleCentral *)central watchDidDisconnect:(PBWatch *)watch {
    if (self.pebbleDisconnectedCallbackId) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [pluginResult setKeepCallbackAsBool:YES];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.pebbleDisconnectedCallbackId];
    }

    if (self.watch == watch) {
        self.watch = nil;
    }
}

-(void)setupIos:(CDVInvokedUrlCommand *)command {
    self.setupCallbackId = command.callbackId;

    self.central = [PBPebbleCentral defaultCentral];
    self.central.delegate = self;

    NSString *uuidString = [command.arguments objectAtIndex:0];
    self.central.appUUID = [[NSUUID alloc] initWithUUIDString:uuidString];

    [self.central run];

    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_NO_RESULT];
    [pluginResult setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

-(void)isWatchConnected:(CDVInvokedUrlCommand *)command {
    CDVPluginResult* pluginResult = nil;
    if (self.watch) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:[self.watch isConnected]];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:ERROR_MSG_NO_WATCH];
    }

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

-(void)registerPebbleConnectedReceiver:(CDVInvokedUrlCommand *)command {
    if (self.pebbleConnectedCallbackId) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Pebble connected receiver already registered"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }

    self.pebbleConnectedKeepAlive = [command.arguments objectAtIndex:0];
    self.pebbleConnectedCallbackId = command.callbackId;

    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_NO_RESULT];
    [pluginResult setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.pebbleConnectedCallbackId];
}

-(void)registerPebbleDisconnectedReceiver:(CDVInvokedUrlCommand *)command {
    if (self.pebbleDisconnectedCallbackId) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Pebble disconnected receiver already registered"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }

    self.pebbleDisconnectedKeepAlive = [command.arguments objectAtIndex:0];
    self.pebbleDisconnectedCallbackId = command.callbackId;

    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_NO_RESULT];
    [pluginResult setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.pebbleDisconnectedCallbackId];
}

-(void)unregisterPebbleConnectedReceiver:(CDVInvokedUrlCommand *)command {
    CDVPluginResult *pluginResult;

    if (self.pebbleConnectedCallbackId) {
        self.pebbleConnectedCallbackId = nil;
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"No Pebble connected receiver registered"];
    }

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

-(void)unregisterPebbleDisconnectedReceiver:(CDVInvokedUrlCommand *)command {
    CDVPluginResult *pluginResult;

    if (self.pebbleDisconnectedCallbackId) {
        self.pebbleDisconnectedCallbackId = nil;
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"No Pebble disconnected receiver registered"];
    }

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

@end
