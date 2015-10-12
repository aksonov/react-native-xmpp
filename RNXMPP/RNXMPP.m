//
//  XMPP.m
//  RNXMPP
//
//  Created by Pavlo Aksonov on 23.09.15.
//  Copyright © 2015 Pavlo Aksonov. All rights reserved.
//

#import "RNXMPP.h"
#import "RCTBridge.h"
#import "RCTEventDispatcher.h"

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
                    return [self contentOf:child];
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

-(void)onIQ:(XMPPIQ *)iq {
    NSDictionary *res = [self contentOf:iq];
    [self.bridge.eventDispatcher sendAppEventWithName:@"RNXMPPIQ" body:res];
}

-(void)onPresence:(XMPPPresence *)presence {
    NSDictionary *res = [self contentOf:presence];
    [self.bridge.eventDispatcher sendAppEventWithName:@"RNXMPPPresence" body:res];
}

-(void)onConnnect {
    [self.bridge.eventDispatcher sendAppEventWithName:@"RNXMPPConnect" body:@{}];
}

-(void)onDisconnect:(NSError *)error {
    [self.bridge.eventDispatcher sendAppEventWithName:@"RNXMPPDisconnect" body:[error localizedDescription]];
}

-(void)onLogin {
    [self.bridge.eventDispatcher sendAppEventWithName:@"RNXMPPLogin" body:@{}];
}


RCT_EXPORT_METHOD(connect:(NSString *)jid password:(NSString *)password){
    [RNXMPPService sharedInstance].delegate = self;
    [[RNXMPPService sharedInstance] connect:jid withPassword:password];
}

RCT_EXPORT_METHOD(message:(NSString *)text to:(NSString *)to){
    [RNXMPPService sharedInstance].delegate = self;
    [[RNXMPPService sharedInstance] sendMessage:text to:to];
}

RCT_EXPORT_METHOD(disconnect){
    [RNXMPPService sharedInstance].delegate = self;
    [[RNXMPPService sharedInstance] disconnect];
}

@end
