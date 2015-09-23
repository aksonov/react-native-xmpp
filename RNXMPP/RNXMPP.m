//
//  XMPP.m
//  RNXMPP
//
//  Created by Pavlo Aksonov on 23.09.15.
//  Copyright © 2015 Pavlo Aksonov. All rights reserved.
//

#import "RNXMPP.h"

@implementation RNXMPP

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(connect:(NSString *)jid location:(NSString *)password)
{
    RCTLogInfo(@"Pretending to create an event %@ at %@", name, location);
}

@end
