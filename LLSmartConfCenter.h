//
//  SmartConfCenter.h
//  WhiteNoise
//
//  Created by Francisco Lobo on 6/10/14.
//  Copyright (c) 2014 LoboLabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#include <sys/socket.h>
#include <netdb.h>
#include <AssertMacros.h>
#import <CFNetwork/CFNetwork.h>
#include <netinet/in.h>
#include <errno.h>
#include <ifaddrs.h>
#include <arpa/inet.h>
#import <SystemConfiguration/CaptiveNetwork.h>

typedef enum {
    LLSmartConfSending = 1,
    LLSmartConfStopped
} LLSmartConfStatus;

typedef void (^SmartConfigStatusChangedBlock)(LLSmartConfStatus status);


@interface LLSmartConfCenter : NSObject

@property (nonatomic, readonly) LLSmartConfStatus status;

+ (instancetype)sharedCenter;

#pragma mark #pragma mark
#pragma mark #pragma mark

//|-----------------------|>> Begin&Stop Smart Config Methods.
-(void)beginConfigForSSID:(NSString*)ssid
             withPassword:(NSString*)password
         andEncryptionKey:(NSString*)encryptionKeyString
          completionBlock:(SmartConfigStatusChangedBlock)completion;

-(void)stop;

//
//|-----------------------|>> Original Texas Instruments Code.
//
//|-----------------------|>> Printing the address of pinged AP // @param destination address
- (NSString *)displayAddressForAddress:(NSData *) address;

//|-----------------------|>> Retrieving the IP Address from the connected WiFi
- (NSString *)getIPAddress ;

//|-----------------------|>> Retriving the SSID of the connected network
- (NSString*)ssidForConnectedNetwork;
@end
