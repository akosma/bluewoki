//
//  PeerProxy.h
//  bluewoki
//
//  Created by Adrian on 5/21/11.
//  Copyright 2011 akosma software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "MessageBrokerDelegate.h"
#import "PeerProxyDelegate.h"

@interface PeerProxy : NSObject <NSNetServiceDelegate,
                                 MessageBrokerDelegate,
                                 GKPeerPickerControllerDelegate,
                                 GKSessionDelegate,
                                 GKVoiceChatClient>

@property (nonatomic, retain) NSNetService *netService;
@property (nonatomic, retain) GKSession *chatSession;
@property (nonatomic, getter = isConnected) BOOL connected;
@property (nonatomic, retain) MessageBroker *messageBroker;
@property (nonatomic, assign) id<PeerProxyDelegate> delegate;
@property (nonatomic, readonly) NSString *serviceName;

+ (id)proxyWithService:(NSNetService *)service;
- (id)initWithService:(NSNetService *)service;
- (void)connect;
- (void)startService;
- (void)stopService;
- (void)sendVoiceCallRequest;
- (void)answerToCallFromPeerID:(NSString *)peerID;

@end
