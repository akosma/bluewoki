//
//  BWPeerServiceDelegate.h
//  bluewoki
//
//  Created by Adrian on 5/21/11.
//  Copyright 2011 akosma software. All rights reserved.
//

#import <Foundation/Foundation.h>


@class BWPeerService;

@protocol BWPeerServiceDelegate <NSObject>

@optional
- (void)peerService:(BWPeerService *)service didReceiveCallRequestFromPeer:(NSString *)peerID;

@end
