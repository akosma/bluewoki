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
@synthesize otherPeerID = _otherPeerID;
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
    return [self.chatSession displayNameForPeer:self.otherPeerID];
}

- (void)connect
{
    // To be overridden by subclasses
}

- (void)disconnect
{
    // Can be overridden by subclasses
    // but remember to call this method!
    [[GKVoiceChatService defaultVoiceChatService] stopVoiceChatWithParticipantID:self.otherPeerID];
    [self.chatSession disconnectFromAllPeers];
    self.chatSession.delegate = nil;
    self.chatSession = nil;
    self.connected = NO;
    self.otherPeerID = nil;
}

#pragma mark - GKPeerPickerControllerDelegate methods

- (GKSession *)peerPickerController:(GKPeerPickerController *)picker 
           sessionForConnectionType:(GKPeerPickerConnectionType)type
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
                  withDataMode:GKSendDataReliable error: nil];
}

- (void)receiveData:(NSData *)data 
           fromPeer:(NSString *)peer
          inSession:(GKSession *)session
            context:(void *)context;
{
    [[GKVoiceChatService defaultVoiceChatService] receivedData:data 
                                             fromParticipantID:peer];
}

@end
