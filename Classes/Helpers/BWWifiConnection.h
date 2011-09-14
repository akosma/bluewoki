//
//  BWWifiConnection.h
//  bluewoki
//
//  Created by Adrian on 9/14/11.
//  Copyright 2011 akosma software. All rights reserved.
//

#import "BWConnection.h"
#import "PeerServiceDelegate.h"
#import "PeerProxyDelegate.h"

@interface BWWifiConnection : BWConnection <PeerServiceDelegate,
                                            PeerProxyDelegate>

@end
