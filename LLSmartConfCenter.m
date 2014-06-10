//
//  SmartConfCenter.m
//  Spark.IO SmartConfig for iOS Devices.
//
//
//  Created by Francisco Lobo on 6/10/14.
//  Copyright (c) 2014 LoboLabs. All rights reserved.
//  http://www.lobolabs.com   |   http://www.kikolobo.com
//
//   --- Improved & Based from original code in XX2xAPManager.h/m
//   --- Copyright � 2013, Texas Instruments Incorporated - http://www.ti.com/
//   --- NEEDS libFTC_DEBUG.a | libFTC_RELEASE.a  and FirstTimeConfig.h   from Texas Instrument CC3xAP Library.

#import "LLSmartConfCenter.h"
#import "FirstTimeConfig.h"


@interface LLSmartConfCenter()
@property (nonatomic, copy) SmartConfigStatusChangedBlock completionBlock;
//#if !(TARGET_IPHONE_SIMULATOR)
@property (strong, nonatomic) FirstTimeConfig *ftc;
//#endif
@end


@implementation LLSmartConfCenter
#pragma mark #pragma mark |-----------------------|>> Singleton Methods
+ (instancetype)sharedCenter {
    static dispatch_once_t once;
    static id sharedInstance;
    
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}




#pragma mark #pragma mark |-----------------------|>> Begin&Stop Smart Config Methods.


-(void)beginConfigForSSID:(NSString*)ssid
             withPassword:(NSString*)password
         andEncryptionKey:(NSString*)encryptionKeyString
          completionBlock:(SmartConfigStatusChangedBlock)completion
{
        self.completionBlock = completion;
#if !(TARGET_IPHONE_SIMULATOR)
    NSData *encryptKey = [encryptionKeyString dataUsingEncoding:NSUTF8StringEncoding];
    self.ftc = [[FirstTimeConfig alloc] initWithKey:password withEncryptionKey:encryptKey];
    
    _status = LLSmartConfSending;
    [self.ftc transmitSettings];
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        [self.ftc waitForAck];
        dispatch_async(dispatch_get_main_queue(), ^(void){
            _status = LLSmartConfStopped;
            if (self.completionBlock) self.completionBlock(_status);
        });
    });
#else
    NSLog(@"####WARNING####\n ---> [LLSmartConfCenter] Library is not supported on simulator. Will return -STOPPED- status in completion block.");
     if (self.completionBlock) self.completionBlock(_status);
#endif

}

-(void)stop
{
    if ([self.ftc isTransmitting]) {
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [self.ftc stopTransmitting];
          //  _status = LLSmartConfStopped;
          //  if (self.completionBlock) self.completionBlock(_status);
        });
    }
    
}




#pragma mark #pragma mark |-----------------------|>> Original Texas Instruments Code.
- (NSString *) displayAddressForAddress:(NSData *) address
{
    int         err;
    NSString *  result;
    char        hostStr[NI_MAXHOST];
    
    result = nil;
    
    if (address != nil) {
        err = getnameinfo([address bytes], (socklen_t) [address length], hostStr, sizeof(hostStr), NULL, 0, NI_DGRAM);
        if (err == 0) {
            result = [NSString stringWithCString:hostStr encoding:NSASCIIStringEncoding];
            assert(result != nil);
        }
    }
    
    return result;
}

- (NSString *)getIPAddress {
    
    NSString *address = @"";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String for IP
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                    
                    //                    NSLog(@"subnet mask == %@",[NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_netmask)->sin_addr)]);
                    //
                    //                    NSLog(@"dest mask == %@",[NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_dstaddr)->sin_addr)]);
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free/release memory
    freeifaddrs(interfaces);
    return address;
}

/*!!!!!!!!!!!!
 retriving the SSID of the connected network
 @return value: the SSID of currently connected wifi
 '!!!!!!!!!!*/
- (NSString*)ssidForConnectedNetwork{
    
    NSArray *interfaces = (__bridge NSArray*)CNCopySupportedInterfaces();
    NSDictionary *info = nil;
    for (NSString *ifname in interfaces) {
        info = (__bridge NSDictionary*)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifname);
        if (info && [info count]) {
            break;
        }
        info = nil;
    }
    
    //    NSLog(@"SSID == %@  info === %@",[info objectForKey:@"SSID"],info);
    
    NSString *ssid = nil;
    if ( info ){
        ssid = [info objectForKey:@"SSID"];//CFDictionaryGetValue((CFDictionaryRef)info, kCNNetworkInfoKeySSID);
    }
    return ssid ? ssid:@"";
}





@end
