//
//  PeerServiceDelegate.h
//  bluewoki
//
//  Created by Adrian on 5/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@class PeerService;

@protocol PeerServiceDelegate <NSObject>

@optional
- (void)peerService:(PeerService *)service didReceiveCallRequestFromPeer:(NSString *)peerID;

@end
