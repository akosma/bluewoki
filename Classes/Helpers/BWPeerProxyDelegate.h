//
//  BWPeerProxyDelegate.h
//  bluewoki
//
//  Created by Adrian on 5/21/11.
//  Copyright 2011 akosma software. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BWPeerProxy;

@protocol BWPeerProxyDelegate <NSObject>

@optional

- (void)proxyDidConnect:(BWPeerProxy *)proxy;
- (void)proxyDidDisconnect:(BWPeerProxy *)proxy;
- (void)proxy:(BWPeerProxy *)proxy didReceiveCallRequestFromPeer:(NSString *)peerID;

@end
