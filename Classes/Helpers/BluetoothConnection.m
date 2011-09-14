//
//  BluetoothConnection.m
//  bluewoki
//
//  Created by Adrian on 9/14/11.
//  Copyright 2011 akosma software. All rights reserved.
//

#import "BluetoothConnection.h"

@interface BluetoothConnection ()

@property (nonatomic, retain) GKPeerPickerController *pickerController;

@end


@implementation BluetoothConnection

@synthesize pickerController = _pickerController;

- (void)dealloc
{
    [_pickerController release];
    [super dealloc];
}

#pragma mark - Public methods

- (void)connect
{
    self.connected = NO;
    self.pickerController = [[[GKPeerPickerController alloc] init] autorelease];
    self.pickerController.delegate = self;
    self.pickerController.connectionTypesMask = GKPeerPickerConnectionTypeNearby;
    [self.pickerController show];
    
    [GKVoiceChatService defaultVoiceChatService].client = self;
}

#pragma mark - GKPeerPickerControllerDelegate methods

- (void)peerPickerController:(GKPeerPickerController *)picker 
              didConnectPeer:(NSString *)peerID 
                   toSession:(GKSession *)session 
{
    if (picker == self.pickerController)
    {
        self.otherPeerID = peerID;
        self.chatSession = session;
        self.chatSession.delegate = self;
        [self.chatSession setDataReceiveHandler:self withContext:nil];
        
        self.pickerController.delegate = nil;
        [self.pickerController dismiss];
        
        [[GKVoiceChatService defaultVoiceChatService] startVoiceChatWithParticipantID:self.otherPeerID 
                                                                                error:nil];

        self.connected = YES;
        if ([self.delegate respondsToSelector:@selector(connectionDidConnect:)])
        {
            [self.delegate connectionDidConnect:self];
        }
    }
}

- (void)peerPickerControllerDidCancel:(GKPeerPickerController *)picker
{
    if (picker == self.pickerController)
    {
        self.connected = NO;
        [self.pickerController dismiss];
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
