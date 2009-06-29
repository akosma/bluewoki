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

@interface BluewokiAppDelegate (Private)

- (void)closeConnectionWithMessage:(NSString *)message;

@end


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
    statusLabel.text = NSLocalizedString(@"ready", @"Used when the application starts and after the peer disconnects");
    [connectButton setTitle:NSLocalizedString(@"connect", @"Shown on the connect button") forState:UIControlStateNormal];
}

- (void)dealloc 
{
    pickerController.delegate = nil;
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
    
    statusLabel.text = [NSString stringWithFormat:NSLocalizedString(@"connected with", @"Shows who we're talking to"), 
                                                    [chatSession displayNameForPeer:peerID]];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    [UIDevice currentDevice].proximityMonitoringEnabled = YES;
    connectButton.enabled = NO;
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
                break;
                
            case GKPeerStateUnavailable:
                break;
                
            case GKPeerStateConnected:
                break;

            case GKPeerStateDisconnected:
                [self closeConnectionWithMessage:NSLocalizedString(@"peer disconnected", @"Shown when the other user disconnects")];
                break;

            case GKPeerStateConnecting:
                statusLabel.text = NSLocalizedString(@"connecting", @"Shown while the connection is negotiated");
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
        [self closeConnectionWithMessage:NSLocalizedString(@"error", @"Shown when the connection generated an error")];
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
    [chatSession sendData:data 
                  toPeers:[NSArray arrayWithObject:participantID] 
             withDataMode:GKSendDataReliable error: nil];
}

- (void)receiveData:(NSData *)data fromPeer:(NSString *)peer inSession:(GKSession *)session context:(void *)context;
{
    [[GKVoiceChatService defaultVoiceChatService] receivedData:data 
                                             fromParticipantID:peer];
}

#pragma mark -
#pragma mark Private methods

- (void)closeConnectionWithMessage:(NSString *)message
{
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [UIDevice currentDevice].proximityMonitoringEnabled = NO;
    statusLabel.text = message;
    chatSession.delegate = nil;
    self.chatSession = nil;
    connectButton.enabled = YES;
    [self performSelector:@selector(resetInterface) 
               withObject:nil 
               afterDelay:3];
}

- (void)resetInterface
{
    statusLabel.text = NSLocalizedString(@"ready", @"Used when the application starts and after the peer disconnects");
}

@end
