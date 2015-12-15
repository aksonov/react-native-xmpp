//
//  RNXMPPService.h
//  RNXMPP
//
//  Created by Pavlo Aksonov on 24.09.15.
//  Copyright © 2015 Pavlo Aksonov. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "XMPP.h"
#import "XMPPReconnect.h"
#import "XMPPDateTimeProfiles.h"
#import "NSDate+XMPPDateTimeProfiles.h"
#import "XMPPMUC.h"
#import "XMPPRoom.h"
#import "XMPPRoster.h"
#import "XMPPRosterMemoryStorage.h"

@protocol RNXMPPServiceDelegate <NSObject>

-(void)onError:(NSError *)error;
-(void)onMessage:(XMPPMessage *)message;
-(void)onPresence:(XMPPPresence *)presence;
-(void)onIQ:(XMPPIQ *)iq;
-(void)onRosterReceived:(NSArray *)list;
-(void)onDisconnect:(NSError *)error;
-(void)onConnnect;
-(void)onLogin;
-(void)onLoginError:(NSError *)error;

@end

@interface RNXMPPService : NSObject
{
    XMPPStream *xmppStream;
    XMPPRoster *xmppRoster;
    XMPPRosterMemoryStorage *xmppRosterStorage;
    XMPPReconnect *xmppReconnect;
    XMPPMUC *xmppMUC;
    NSString *password;
    BOOL customCertEvaluation;
    BOOL isXmppConnected;
}

@property (nonatomic, strong, readonly) XMPPStream *xmppStream;
@property (nonatomic, strong, readonly) XMPPReconnect *xmppReconnect;
@property (nonatomic, weak) id<RNXMPPServiceDelegate> delegate;

+(RNXMPPService *) sharedInstance;
- (BOOL)connect:(NSString *)myJID withPassword:(NSString *)myPassword;
- (void)disconnect;
- (void)sendMessage:(NSString *)text to:(NSString *)username;

@end

