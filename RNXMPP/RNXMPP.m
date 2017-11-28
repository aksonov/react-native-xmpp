//
//  XMPP.m
//  RNXMPP
//
//  Created by Pavlo Aksonov on 23.09.15.
//  Copyright © 2015 Pavlo Aksonov. All rights reserved.
//

#import "RNXMPP.h"
#import "RNXMPPConstants.h"

const NSString *PLAIN_AUTH = @"PLAIN";
const NSString *SCRAMSHA1_AUTH = @"SCRAMSHA1";
const NSString *DigestMD5_AUTH = @"DigestMD5";

@implementation RCTConvert (AuthMethod)
RCT_ENUM_CONVERTER(AuthMethod, (@{ PLAIN_AUTH : @(Plain),
                                             SCRAMSHA1_AUTH : @(SCRAM),
                                             DigestMD5_AUTH : @(MD5)}),
                                          SCRAM, integerValue)
@end


@implementation RNXMPP {
    RCTResponseSenderBlock onError;
    RCTResponseSenderBlock onConnect;
    RCTResponseSenderBlock onMessage;
    RCTResponseSenderBlock onIQ;
    RCTResponseSenderBlock onPresence;
}

@synthesize bridge = _bridge;

RCT_EXPORT_MODULE();


-(void)onError:(NSError *)error {
    NSString *message = [error localizedDescription];
    [self.bridge.eventDispatcher sendAppEventWithName:@"RNXMPPError" body:message];
}

-(void)onLoginError:(NSError *)error {
    [self.bridge.eventDispatcher sendAppEventWithName:@"RNXMPPLoginError" body:[error localizedDescription]];
}

-(id)contentOf:(XMPPElement *)element{
    NSMutableDictionary *res = [NSMutableDictionary dictionary];
    if ([element respondsToSelector:@selector(attributesAsDictionary)]){
        res = [element attributesAsDictionary];
    }
    if (element.children){
        for (XMPPElement *child in element.children){
            if (res[child.name] && ![res[child.name] isKindOfClass:[NSArray class]]){
                res[child.name] = [NSMutableArray arrayWithObjects:res[child.name], nil];
            }
            if (res[child.name]){
                [res[child.name] addObject:[self contentOf:child]];
            } else {
                if ([child.name isEqualToString:@"text"]){
                    if ([res count]){
                        res[@"#text"] = [self contentOf:child];
                    } else {
                        return [self contentOf:child];
                    }
                } else {
                    res[child.name] = [self contentOf:child];
                }
            }
        }
    }
    if ([res count]){
        return res;
    } else {
        return [element stringValue];
    }
}

-(void)onMessage:(XMPPMessage *)message {
    NSDictionary *res = [self contentOf:message];
    [self.bridge.eventDispatcher sendAppEventWithName:@"RNXMPPMessage" body:res];

}

-(void)onRosterReceived:(NSArray *)list {
    [self.bridge.eventDispatcher sendAppEventWithName:@"RNXMPPRoster" body:list];
}

-(void)onIQ:(XMPPIQ *)iq {
    NSDictionary *res = [self contentOf:iq];
    [self.bridge.eventDispatcher sendAppEventWithName:@"RNXMPPIQ" body:res];
}

-(void)onPresence:(XMPPPresence *)presence {
    NSDictionary *res = [self contentOf:presence];
    [self.bridge.eventDispatcher sendAppEventWithName:@"RNXMPPPresence" body:res];
}

-(void)onConnnect:(NSString *)username password:(NSString *)password {
    [self.bridge.eventDispatcher sendAppEventWithName:@"RNXMPPConnect" body:@{@"username":username, @"password":password}];
}

-(void)onDisconnect:(NSError *)error {
    [self.bridge.eventDispatcher sendAppEventWithName:@"RNXMPPDisconnect" body:[error localizedDescription]];
    if ([error localizedDescription]){
        [self.bridge.eventDispatcher sendAppEventWithName:@"RNXMPPLoginError" body:[error localizedDescription]];
    }
}

-(void)onLogin:(NSString *)username password:(NSString *)password {
    [self.bridge.eventDispatcher sendAppEventWithName:@"RNXMPPLogin" body:@{@"username":username, @"password":password}];
}

RCT_EXPORT_METHOD(trustHosts:(NSArray *)hosts){
    [RNXMPPService sharedInstance].delegate = self;
    [[RNXMPPService sharedInstance] trustHosts:hosts];
}

RCT_EXPORT_METHOD(connect:(NSString *)jid password:(NSString *)password auth:(AuthMethod) auth hostname:(NSString *)hostname port:(int)port){
    [RNXMPPService sharedInstance].delegate = self;
    [[RNXMPPService sharedInstance] connect:jid withPassword:password auth:auth hostname:hostname port:port];
}

RCT_EXPORT_METHOD(message:(NSString *)text to:(NSString *)to thread:(NSString *)threadId){
    [RNXMPPService sharedInstance].delegate = self;
    [[RNXMPPService sharedInstance] sendMessage:text to:to thread:threadId];
}

RCT_EXPORT_METHOD(presence:(NSString *)to type:(NSString *)type){
    [RNXMPPService sharedInstance].delegate = self;
    [[RNXMPPService sharedInstance] sendPresence:to type:type];
}

RCT_EXPORT_METHOD(removeRoster:(NSString *)to){
    [RNXMPPService sharedInstance].delegate = self;
    [[RNXMPPService sharedInstance] removeRoster:to];
}

RCT_EXPORT_METHOD(disconnect){
    [RNXMPPService sharedInstance].delegate = self;
    [[RNXMPPService sharedInstance] disconnect];
}

RCT_EXPORT_METHOD(disconnectAfterSending){
    [RNXMPPService sharedInstance].delegate = self;
    [[RNXMPPService sharedInstance] disconnectAfterSending];
}

RCT_EXPORT_METHOD(fetchRoster){
    [RNXMPPService sharedInstance].delegate = self;
    [[RNXMPPService sharedInstance] fetchRoster];
}

RCT_EXPORT_METHOD(sendStanza:(NSString *)stanza){
    [RNXMPPService sharedInstance].delegate = self;
    [[RNXMPPService sharedInstance] sendStanza:stanza];
}

- (NSDictionary *)constantsToExport
{
    return @{ PLAIN_AUTH : @(Plain),
              SCRAMSHA1_AUTH: @(SCRAM),
              DigestMD5_AUTH: @(MD5)
              };
};


@end
