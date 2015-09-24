//
//  XMPP.h
//  RNXMPP
//
//  Created by Pavlo Aksonov on 23.09.15.
//  Copyright © 2015 Pavlo Aksonov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCTBridgeModule.h"
#import "RNXMPPService.h"

@interface RNXMPP : NSObject<RCTBridgeModule, RNXMPPServiceDelegate>

@end
