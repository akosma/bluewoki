//
//  BWBrowserControllerDelegate.h
//  bluewoki
//
//  Created by Adrian on 5/21/11.
//  Copyright 2011 akosma software. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BWBrowserController;
@class PeerProxy;


@protocol BWBrowserControllerDelegate <NSObject>

@optional
- (void)peersBrowserController:(BWBrowserController *)controller didSelectPeer:(PeerProxy *)peer;

@end
