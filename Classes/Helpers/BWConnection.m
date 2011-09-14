//
//  BWConnection.m
//  bluewoki
//
//  Created by Adrian on 9/14/11.
//  Copyright 2011 akosma software. All rights reserved.
//

#import "BWConnection.h"

@implementation BWConnection

@synthesize delegate = _delegate;
@synthesize remotePeerID = _otherPeerID;
@synthesize chatSession = _chatSession;
@synthesize connected = _connected;
@dynamic otherPeerName;

+ (id)connection
{
    return [[[[self class] alloc] init] autorelease];
}

- (void)dealloc
{
    [_chatSession release];
    [_otherPeerID release];
    [super dealloc];
}

#pragma mark - Public methods

- (NSString *)otherPeerName
{
    return [self.chatSession displayNameForPeer:self.remotePeerID];
}

- (void)connect
{
    // Overridden by subclasses
}

- (void)disconnect
{
    // Overridden by subclasses
}

- (GKSession *)createChatSession
{
    NSString *sessionId = @"bluewoki";
    NSString *name = [[UIDevice currentDevice] name];
    GKSession* session = [[[GKSession alloc] initWithSessionID:sessionId 
                                                   displayName:name 
                                                   sessionMode:GKSessionModePeer] autorelease];
    return session;
}

#pragma mark - GKVoiceChatClient methods

- (NSString *)participantID
{
    return self.chatSession.peerID;
}

- (void)voiceChatService:(GKVoiceChatService *)voiceChatService 
                sendData:(NSData *)data
         toParticipantID:(NSString *)participantID
{
    [self.chatSession sendData:data 
                       toPeers:[NSArray arrayWithObject:participantID] 
                  withDataMode:GKSendDataReliable 
                         error:nil];
}

- (void)receiveData:(NSData *)data 
           fromPeer:(NSString *)peer
          inSession:(GKSession *)session
            context:(void *)context;
{
    [[GKVoiceChatService defaultVoiceChatService] receivedData:data 
                                             fromParticipantID:peer];
}

- (void)voiceChatService:(GKVoiceChatService *)voiceChatService
didStopWithParticipantID:(NSString *)participantID
                   error:(NSError *)error
{
    self.connected = NO;
    if ([self.delegate respondsToSelector:@selector(connectionDidDisconnect:)])
    {
        [self.delegate connectionDidDisconnect:self];
    }
}

-  (void)voiceChatService:(GKVoiceChatService *)voiceChatService 
didStartWithParticipantID:(NSString *)participantID
{
}

@end
