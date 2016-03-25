#import <Foundation/Foundation.h>
#import <Cordova/CDVPlugin.h>

@interface PebbleKitCordovaWrapper : CDVPlugin

-(void)isWatchConnected:(CDVInvokedUrlCommand *)command;

@end
