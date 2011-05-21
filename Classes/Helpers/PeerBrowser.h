//
//  PeerBrowser.h
//  bluewoki
//
//  Created by Adrian on 5/21/11.
//  Copyright 2011 akosma software. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PeerProxy;

@interface PeerBrowser : NSObject <NSNetServiceBrowserDelegate>

@property (nonatomic, retain) NSMutableArray *peerArray;
@property (nonatomic, retain) NSNetServiceBrowser *peerBrowser;

- (void)startSearchingForPeers;
- (void)stopSearchingForPeers;
- (NSInteger)connectedPeersCount;
- (PeerProxy *)peerAtIndex:(NSUInteger)index;

@end
