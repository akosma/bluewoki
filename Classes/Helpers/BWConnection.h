//
//  BWConnection.h
//  bluewoki
//
//  Created by Adrian on 9/14/11.
//  Copyright 2011 akosma software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import "BWConnectionDelegate.h"
#import "BWBrowserControllerDelegate.h"

@interface BWConnection : NSObject <GKPeerPickerControllerDelegate,
                                    GKSessionDelegate,
                                    GKVoiceChatClient,
                                    BWBrowserControllerDelegate>

@property (nonatomic, assign) id<BWConnectionDelegate> delegate;
@property (nonatomic, copy) NSString *remotePeerID;
@property (nonatomic, getter = isConnected) BOOL connected;
@property (nonatomic, readonly) NSString *otherPeerName;
@property (nonatomic, retain) GKSession *chatSession;

+ (id)connection;

- (void)connect;
- (void)disconnect;
- (GKSession *)createChatSession;

@end
