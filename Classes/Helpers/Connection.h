//
//  Connection.h
//  bluewoki
//
//  Created by Adrian on 9/14/11.
//  Copyright 2011 akosma software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import "ConnectionDelegate.h"
#import "PeersBrowserControllerDelegate.h"

@interface Connection : NSObject <GKPeerPickerControllerDelegate,
                                  GKSessionDelegate,
                                  GKVoiceChatClient,
                                  PeersBrowserControllerDelegate>

@property (nonatomic, assign) id<ConnectionDelegate> delegate;
@property (nonatomic, copy) NSString *otherPeerID;
@property (nonatomic, getter = isConnected) BOOL connected;
@property (nonatomic, readonly) NSString *otherPeerName;
@property (nonatomic, retain) GKSession *chatSession;

+ (id)connection;

- (void)connect;
- (void)disconnect;

@end
