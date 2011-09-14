//
//  BWWifiConnection.m
//  bluewoki
//
//  Created by Adrian on 9/14/11.
//  Copyright 2011 akosma software. All rights reserved.
//

#import "BWWifiConnection.h"
#import "BWPeerService.h"
#import "BWPeerProxy.h"

@interface BWWifiConnection ()

@property (nonatomic, retain) BWPeerService *service;
@property (nonatomic, retain) BWPeerProxy *peerProxy;

@end


@implementation BWWifiConnection

@synthesize service = _service;
@synthesize peerProxy = _peerProxy;

- (void)dealloc
{
    _service.delegate = nil;
    [_service release];
    [_peerProxy release];
    [super dealloc];
}

#pragma mark - Public methods

- (void)connect
{
    [GKVoiceChatService defaultVoiceChatService].client = self;
    self.connected = NO;

    self.chatSession = [self createChatSession];
    self.chatSession.delegate = self;
    self.chatSession.available = YES;
    [self.chatSession setDataReceiveHandler:self withContext:nil];

    self.service = [[[BWPeerService alloc] init] autorelease];
    self.service.delegate = self;
    [self.service startService];
}

- (void)disconnect
{
    [[GKVoiceChatService defaultVoiceChatService] stopVoiceChatWithParticipantID:self.remotePeerID];
    [GKVoiceChatService defaultVoiceChatService].client = nil;
    
    [self.chatSession disconnectFromAllPeers];
    self.chatSession.delegate = nil;
    self.chatSession = nil;
    self.connected = NO;
    self.remotePeerID = nil;
    
    self.service.delegate = nil;
    [self.service stopService];
}

- (void)answerIncomingCall
{
    [self.chatSession connectToPeer:self.remotePeerID
                        withTimeout:60];
}

#pragma mark - GKSessionDelegate methods

- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID
{
    if (session == self.chatSession)
    {
        // This method is only called in the device that receives a call
        [self.chatSession acceptConnectionFromPeer:peerID 
                                             error:nil];
    }
}

- (void)session:(GKSession *)session 
           peer:(NSString *)peerID
 didChangeState:(GKPeerConnectionState)state
{
    if (session == self.chatSession)
    {
        switch (state) 
        {
            case GKPeerStateAvailable:
                break;
                
            case GKPeerStateUnavailable:
                break;
                
            case GKPeerStateConnected:
            {
                self.connected = YES;
                
                // The PeerID changes during the process... we have to get it again here
                // otherwise the display of the remote device name is wrong!
                self.remotePeerID = peerID;
                [[GKVoiceChatService defaultVoiceChatService] startVoiceChatWithParticipantID:peerID 
                                                                                        error:nil];

                if ([self.delegate respondsToSelector:@selector(connectionDidConnect:)])
                {
                    [self.delegate connectionDidConnect:self];
                }
                break;
            }
                
            case GKPeerStateDisconnected:
            {
                self.connected = NO;
                if ([self.delegate respondsToSelector:@selector(connectionDidDisconnect:)])
                {
                    [self.delegate connectionDidDisconnect:self];
                }
                break;
            }
                
            case GKPeerStateConnecting:
            {
                break;
            }
                
            default:
                break;
        }
    }
}

-          (void)session:(GKSession *)session 
connectionWithPeerFailed:(NSString *)peerID
               withError:(NSError *)error
{
    if (session == self.chatSession)
    {
        self.connected = NO;
        if ([self.delegate respondsToSelector:@selector(connectionDidDisconnect:)])
        {
            [self.delegate connectionDidDisconnect:self];
        }
    }
}

#pragma mark - BWPeerServiceDelegate methods

- (void)peerService:(BWPeerService *)service didReceiveCallRequestFromPeer:(NSString *)peerID
{
    if (service == self.service)
    {
        // Called when another device is calling this one.
        if ([self.delegate respondsToSelector:@selector(connectionIsConnecting:)])
        {
            [self.delegate connectionIsConnecting:self];
        }
        
        self.remotePeerID = peerID;
        if ([self.delegate respondsToSelector:@selector(connectionDidReceiveCall:)])
        {
            [self.delegate connectionDidReceiveCall:self];
        }
    }
}

#pragma mark - BWBrowserControllerDelegate methods

- (void)peersBrowserController:(BWBrowserController *)controller didSelectPeer:(BWPeerProxy *)peer
{
    self.peerProxy = peer;
    self.peerProxy.delegate = self;
    
    // Upon success, the method proxyDidConnect: below will be called
    [self.peerProxy connect];
    
    if ([self.delegate respondsToSelector:@selector(connectionIsConnecting:)])
    {
        [self.delegate connectionIsConnecting:self];
    }
}

#pragma mark - BWPeerProxyDelegate methods

- (void)proxyDidConnect:(BWPeerProxy *)proxy
{
    if (proxy == self.peerProxy)
    {
        // Called when the current device has an open socket with 
        // the remote device selected by the current user.
        [self.peerProxy sendVoiceCallRequestWithPeerID:self.chatSession.peerID];
    }
}

@end
