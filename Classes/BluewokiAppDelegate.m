//
//  BluewokiAppDelegate.m
//  bluewoki
//
//  Created by Adrian on 6/29/09.
//  Copyright akosma software 2009. All rights reserved.
//

#import "BluewokiAppDelegate.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

@implementation BluewokiAppDelegate

@synthesize chatSession;

- (void)applicationDidFinishLaunching:(UIApplication *)application 
{
    [window makeKeyAndVisible];

    // Create a "peer picker"
    pickerController = [[GKPeerPickerController alloc] init];
    pickerController.delegate = self;
    // Search for peers only in the local bluetooth network
    pickerController.connectionTypesMask = GKPeerPickerConnectionTypeNearby;
    
    NSError *myErr;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&myErr];
    [audioSession setActive:YES error:&myErr];
    
    // Routing default audio to external speaker
    AudioSessionInitialize(NULL, NULL, NULL, NULL);
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute,
                            sizeof(audioRouteOverride),
                            &audioRouteOverride);
    AudioSessionSetActive(true);
    
    [GKVoiceChatService defaultVoiceChatService].client = self;
    
    statusLabel.text = @"ready";
}

- (void)dealloc 
{
    [pickerController release];
    [window release];
    [super dealloc];
}

#pragma mark -
#pragma mark IBAction methods

- (IBAction)showPeers:(id)sender
{
    [pickerController show];
}

- (IBAction)openWebsite:(id)sender
{
    NSURL *url = [NSURL URLWithString:@"http://bluewoki.com/"];
    [[UIApplication sharedApplication] openURL:url];
}

#pragma mark -
#pragma mark GKPeerPickerControllerDelegate methods

- (GKSession *)peerPickerController:(GKPeerPickerController *)picker sessionForConnectionType:(GKPeerPickerConnectionType)type
{
    NSString *sessionId = @"bluewoki";
    NSString *name = [[UIDevice currentDevice] name];
    GKSession* session = [[GKSession alloc] initWithSessionID:sessionId 
                                                  displayName:name 
                                                  sessionMode:GKSessionModePeer];
    [session autorelease];
    return session;
}

- (void)peerPickerController:(GKPeerPickerController *)picker didConnectPeer:(NSString *)peerID toSession:(GKSession *)session 
{
    self.chatSession = session;
    session.delegate = self;
    [session setDataReceiveHandler:self withContext:nil];
    picker.delegate = nil;
    [picker dismiss];
    
    [[GKVoiceChatService defaultVoiceChatService] startVoiceChatWithParticipantID:peerID 
                                                                            error:nil];
    
    statusLabel.text = [NSString stringWithFormat:@"connected to\n%@", peerID];
}

- (void)peerPickerControllerDidCancel:(GKPeerPickerController *)picker
{
    [picker dismiss];
}

#pragma mark -
#pragma mark GKSessionDelegate methods

- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state
{
    if (session == chatSession)
    {
        switch (state) 
        {
            case GKPeerStateAvailable:
                statusLabel.text = [NSString stringWithFormat:@"peer available:\n%@", peerID];
                break;
                
            case GKPeerStateUnavailable:
                break;
                
            case GKPeerStateConnected:
                break;

            case GKPeerStateDisconnected:
                statusLabel.text = @"peer disconnected";
                break;

            case GKPeerStateConnecting:
                break;
                
            default:
                break;
        }
    }
}

- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error
{
    if (session == chatSession)
    {
        statusLabel.text = @"error";
    }
}

#pragma mark -
#pragma mark GKVoiceChatClient methods

- (NSString *)participantID
{
    return chatSession.peerID;
}

- (void)voiceChatService:(GKVoiceChatService *)voiceChatService sendData:(NSData *)data toParticipantID:(NSString *)participantID
{
    statusLabel.text = @"sending...";
    [chatSession sendData:data toPeers:[NSArray arrayWithObject:participantID] withDataMode:GKSendDataReliable error: nil];
}

- (void)receiveData:(NSData *)data fromPeer:(NSString *)peer inSession:(GKSession *)session context:(void *)context;
{
    statusLabel.text = @"receiving...";
    [[GKVoiceChatService defaultVoiceChatService] receivedData:data fromParticipantID:peer];
}

@end
