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
#import "RNXMPPConstants.h"

@protocol RNXMPPServiceDelegate <NSObject>

-(void)onError:(NSError *)error;
-(void)onMessage:(XMPPMessage *)message;
-(void)onPresence:(XMPPPresence *)presence;
-(void)onIQ:(XMPPIQ *)iq;
-(void)onRosterReceived:(NSArray *)list;
-(void)onDisconnect:(NSError *)error;
-(void)onConnnect:(NSString *)username password:(NSString *)password;
-(void)onLogin:(NSString *)username password:(NSString *)password;
-(void)onLoginError:(NSError *)error;

@end

@interface RNXMPPService : NSObject
{
    XMPPStream *xmppStream;
    XMPPRoster *xmppRoster;
    XMPPRosterMemoryStorage *xmppRosterStorage;
    XMPPReconnect *xmppReconnect;
    XMPPMUC *xmppMUC;
    NSArray *trustedHosts;
    NSString *username;
    NSString *password;
    AuthMethod authMethod;
    BOOL customCertEvaluation;
    BOOL isXmppConnected;
}

@property (nonatomic, strong, readonly) XMPPStream *xmppStream;
@property (nonatomic, strong, readonly) XMPPReconnect *xmppReconnect;
@property (nonatomic, weak) id<RNXMPPServiceDelegate> delegate;

+(RNXMPPService *) sharedInstance;
- (void)trustHosts:(NSArray *)hosts;
- (BOOL)connect:(NSString *)myJID withPassword:(NSString *)myPassword auth:(AuthMethod)auth hostname:(NSString *)hostname port:(int)port;
- (void)disconnect;
- (void)sendMessage:(NSString *)text to:(NSString *)username thread:(NSString *)thread;
- (void)sendPresence:(NSString *)to type:(NSString *)type;
- (void)removeRoster:(NSString *)to;
-(void)fetchRoster;
-(void)sendStanza:(NSString *)stanza;

@end

