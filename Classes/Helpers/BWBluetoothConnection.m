//
//  BWBluetoothConnection.m
//  bluewoki
//
//  Created by Adrian on 9/14/11.
//  Copyright 2011 akosma software. All rights reserved.
//

#import "BWBluetoothConnection.h"

@interface BWBluetoothConnection ()

@property (nonatomic, retain) GKPeerPickerController *pickerController;

@end


@implementation BWBluetoothConnection

@synthesize pickerController = _pickerController;

- (void)dealloc
{
    [_pickerController release];
    [super dealloc];
}

#pragma mark - Public methods

- (void)connect
{
    [GKVoiceChatService defaultVoiceChatService].client = self;
    self.connected = NO;

    self.pickerController = [[[GKPeerPickerController alloc] init] autorelease];
    self.pickerController.delegate = self;
    self.pickerController.connectionTypesMask = GKPeerPickerConnectionTypeNearby;
    [self.pickerController show];
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
}

#pragma mark - GKPeerPickerControllerDelegate methods

- (void)peerPickerController:(GKPeerPickerController *)picker 
              didConnectPeer:(NSString *)peerID 
                   toSession:(GKSession *)session 
{
    if (picker == self.pickerController)
    {
        self.remotePeerID = peerID;
        self.chatSession = session;
        self.chatSession.delegate = self;
        [self.chatSession setDataReceiveHandler:self withContext:nil];
        
        self.pickerController.delegate = nil;
        [self.pickerController dismiss];
        self.pickerController = nil;
        
        [[GKVoiceChatService defaultVoiceChatService] startVoiceChatWithParticipantID:self.remotePeerID 
                                                                                error:nil];

        self.connected = YES;
        if ([self.delegate respondsToSelector:@selector(connectionDidConnect:)])
        {
            [self.delegate connectionDidConnect:self];
        }
    }
}

- (GKSession *)peerPickerController:(GKPeerPickerController *)picker 
           sessionForConnectionType:(GKPeerPickerConnectionType)type
{
    return [self createChatSession];
}

- (void)peerPickerControllerDidCancel:(GKPeerPickerController *)picker
{
    if (picker == self.pickerController)
    {
        self.connected = NO;
    }
}

#pragma mark - GKSessionDelegate methods

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
                break;
                
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
                if ([self.delegate respondsToSelector:@selector(connectionIsConnecting:)])
                {
                    [self.delegate connectionIsConnecting:self];
                }
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
        if ([self.delegate respondsToSelector:@selector(connection:didFailWithError:)])
        {
            [self.delegate connection:self didFailWithError:error];
        }
    }
}

@end
