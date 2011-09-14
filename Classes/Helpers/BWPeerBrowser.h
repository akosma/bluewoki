//
//  BWPeerBrowser.h
//  bluewoki
//
//  Created by Adrian on 5/21/11.
//  Copyright 2011 akosma software. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const PeerBrowserDidChangeCountNotification;

@class BWPeerProxy;

@interface BWPeerBrowser : NSObject <NSNetServiceBrowserDelegate>

@property (nonatomic, retain) NSMutableArray *peerArray;
@property (nonatomic, retain) NSNetServiceBrowser *peerBrowser;

- (void)startSearchingForPeers;
- (void)stopSearchingForPeers;
- (NSInteger)connectedPeersCount;
- (BWPeerProxy *)peerAtIndex:(NSUInteger)index;

@end
