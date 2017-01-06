//
//  XMPP.h
//  RNXMPP
//
//  Created by Pavlo Aksonov on 23.09.15.
//  Copyright © 2015 Pavlo Aksonov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>
#import <React/RCTBridge.h>
#import <React/RCTEventDispatcher.h>
#import <React/RCTConvert.h>
#import "RNXMPPService.h"

@interface RNXMPP : NSObject<RCTBridgeModule, RNXMPPServiceDelegate>

@end
