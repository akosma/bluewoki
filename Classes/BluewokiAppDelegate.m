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

@interface BluewokiAppDelegate ()

@property (nonatomic, retain) GKSession *chatSession;
@property (nonatomic, retain) GKPeerPickerController *pickerController;

- (void)closeConnectionWithMessage:(NSString *)message;

@end


@implementation BluewokiAppDelegate

@synthesize chatSession = _chatSession;
@synthesize window = _window;
@synthesize statusLabel = _statusLabel;
@synthesize connectButton = _connectButton;
@synthesize pickerController = _pickerController;

- (void)applicationDidFinishLaunching:(UIApplication *)application 
{
    [self.window makeKeyAndVisible];
    
    NSError *myErr;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&myErr];
    [audioSession setActive:YES 
                      error:&myErr];
    
    // Routing default audio to external speaker
    AudioSessionInitialize(NULL, NULL, NULL, NULL);
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute,
                            sizeof(audioRouteOverride),
                            &audioRouteOverride);
    AudioSessionSetActive(true);
    
    [GKVoiceChatService defaultVoiceChatService].client = self;
    self.statusLabel.text = NSLocalizedString(@"ready", @"Used when the application starts and after the peer disconnects");
    [self.connectButton setTitle:NSLocalizedString(@"connect", @"Shown on the connect button") 
                        forState:UIControlStateNormal];
}

- (void)dealloc 
{
    [_pickerController setDelegate:nil];
    [_pickerController release];
    [_chatSession release];
    [_chatSession setDelegate:nil];
    [_window release];
    [super dealloc];
}

#pragma mark - Overridden properties

- (GKPeerPickerController *)pickerController
{
    if (_pickerController == nil)
    {
        // Create a "peer picker"
        _pickerController = [[GKPeerPickerController alloc] init];
        _pickerController.delegate = self;
        
        // Search for peers only in the local bluetooth network
        _pickerController.connectionTypesMask = GKPeerPickerConnectionTypeNearby 
                                                | GKPeerPickerConnectionTypeOnline;
    }
    return [[_pickerController retain] autorelease];
}

#pragma mark - IBAction methods

- (IBAction)showPeers:(id)sender
{
    [self.pickerController show];
}

- (IBAction)openWebsite:(id)sender
{
    NSURL *url = [NSURL URLWithString:@"http://bluewoki.com/"];
    [[UIApplication sharedApplication] openURL:url];
}

#pragma mark - GKPeerPickerControllerDelegate methods

- (void)peerPickerController:(GKPeerPickerController *)picker 
     didSelectConnectionType:(GKPeerPickerConnectionType)type
{
    switch (type) 
    {
        case GKPeerPickerConnectionTypeOnline:
        {
            [self.pickerController dismiss];
            self.pickerController = nil;
            // Display your own user interface here.
            break;
        }

        default:
            break;
    }
}

- (GKSession *)peerPickerController:(GKPeerPickerController *)picker 
           sessionForConnectionType:(GKPeerPickerConnectionType)type
{
    GKSession* session = nil;
    switch (type) 
    {
        case GKPeerPickerConnectionTypeNearby:
        {
            NSString *sessionId = @"bluewoki";
            NSString *name = [[UIDevice currentDevice] name];
            session = [[[GKSession alloc] initWithSessionID:sessionId 
                                                displayName:name 
                                                sessionMode:GKSessionModePeer] autorelease];
            break;
        }
            
        case GKPeerPickerConnectionTypeOnline:
        {
            break;
        }
            
        default:
        {
            break;
        }
    }
    return session;
}

- (void)peerPickerController:(GKPeerPickerController *)picker 
              didConnectPeer:(NSString *)peerID
                   toSession:(GKSession *)session 
{
    self.chatSession = session;
    session.delegate = self;
    [session setDataReceiveHandler:self withContext:nil];

    [picker dismiss];
    
    [[GKVoiceChatService defaultVoiceChatService] startVoiceChatWithParticipantID:peerID 
                                                                            error:nil];
    
    self.statusLabel.text = [NSString stringWithFormat:NSLocalizedString(@"connected with", @"Shows who we're talking to"), 
                             [self.chatSession displayNameForPeer:peerID]];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    [UIDevice currentDevice].proximityMonitoringEnabled = YES;
    self.connectButton.enabled = NO;
}

- (void)peerPickerControllerDidCancel:(GKPeerPickerController *)picker
{
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
                [self closeConnectionWithMessage:NSLocalizedString(@"peer disconnected", @"Shown when the other user disconnects")];
                break;

            case GKPeerStateConnecting:
                self.statusLabel.text = NSLocalizedString(@"connecting", @"Shown while the connection is negotiated");
                break;
                
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
        [self closeConnectionWithMessage:NSLocalizedString(@"error", @"Shown when the connection generated an error")];
    }
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

#pragma mark - Private methods

- (void)closeConnectionWithMessage:(NSString *)message
{
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [UIDevice currentDevice].proximityMonitoringEnabled = NO;
    self.statusLabel.text = message;
    self.chatSession.delegate = nil;
    self.chatSession = nil;
    self.connectButton.enabled = YES;
    [self performSelector:@selector(resetInterface) 
               withObject:nil 
               afterDelay:3];
}

- (void)resetInterface
{
    self.statusLabel.text = NSLocalizedString(@"ready", @"Used when the application starts and after the peer disconnects");
}

@end
