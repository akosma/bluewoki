//
//  BWWifiConnection.h
//  bluewoki
//
//  Created by Adrian on 9/14/11.
//  Copyright 2011 akosma software. All rights reserved.
//

#import "BWConnection.h"
#import "BWPeerServiceDelegate.h"
#import "BWPeerProxyDelegate.h"

@interface BWWifiConnection : BWConnection <BWPeerServiceDelegate,
                                            BWPeerProxyDelegate>

@end
