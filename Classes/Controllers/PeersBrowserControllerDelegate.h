//
//  PeersBrowserControllerDelegate.h
//  bluewoki
//
//  Created by Adrian on 5/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PeersBrowserController;
@class PeerProxy;


@protocol PeersBrowserControllerDelegate <NSObject>

@optional
- (void)peersBrowserController:(PeersBrowserController *)controller didSelectPeer:(PeerProxy *)peer;

@end
