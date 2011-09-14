//
//  WifiConnection.h
//  bluewoki
//
//  Created by Adrian on 9/14/11.
//  Copyright 2011 akosma software. All rights reserved.
//

#import "Connection.h"
#import "PeerServiceDelegate.h"
#import "PeerProxyDelegate.h"

@interface WifiConnection : Connection <PeerServiceDelegate,
                                        PeerProxyDelegate>

@end
