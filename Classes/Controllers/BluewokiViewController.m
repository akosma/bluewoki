//
//  BluewokiViewController.m
//  bluewoki
//
//  Created by Adrian on 5/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BluewokiViewController.h"


@interface BluewokiViewController ()

@property (nonatomic, retain) GKSession *chatSession;
@property (nonatomic, retain) GKPeerPickerController *pickerController;
@property (nonatomic, copy) NSString *otherPeerID;
@property (nonatomic, getter = isConnected) BOOL connected;

- (void)closeConnectionWithMessage:(NSString *)message;
- (void)disconnect;
- (GKSession *)createSession;

@end


@implementation BluewokiViewController

@synthesize chatSession = _chatSession;
@synthesize statusLabel = _statusLabel;
@synthesize connectButton = _connectButton;
@synthesize pickerController = _pickerController;
@synthesize connected = _connected;
@synthesize otherPeerID = _otherPeerID;

- (void)dealloc
{
    [_pickerController setDelegate:nil];
    [_pickerController release];
    [_chatSession release];
    [_chatSession setDelegate:nil];
    [_otherPeerID release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

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

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
    if (self.isConnected)
    {
        [self disconnect];
    }
    else
    {
        [self.pickerController show];
    }
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
            
        case GKPeerPickerConnectionTypeNearby:
        {
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
            session = [self createSession];
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
    
    [self.pickerController dismiss];
    self.pickerController = nil;
    
    [[GKVoiceChatService defaultVoiceChatService] startVoiceChatWithParticipantID:peerID 
                                                                            error:nil];
    
    self.statusLabel.text = [NSString stringWithFormat:NSLocalizedString(@"connected with", @"Shows who we're talking to"), 
                             [self.chatSession displayNameForPeer:peerID]];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    [UIDevice currentDevice].proximityMonitoringEnabled = YES;
    self.connected = YES;
    self.otherPeerID = peerID;
    [self.connectButton setTitle:NSLocalizedString(@"disconnect", @"Shown on the disconnect button") 
                        forState:UIControlStateNormal];
}

- (void)peerPickerControllerDidCancel:(GKPeerPickerController *)picker
{
    // Do nothing, but in particular, do not dismiss the picker!
    // Otherwise the app would crash...!
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
    [self closeConnectionWithMessage:NSLocalizedString(@"peer disconnected", @"Shown when the other user disconnects")];
}

#pragma mark - Private methods

- (void)closeConnectionWithMessage:(NSString *)message
{
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [UIDevice currentDevice].proximityMonitoringEnabled = NO;
    self.statusLabel.text = message;
    self.chatSession.delegate = nil;
    self.chatSession = nil;
    self.connected = NO;
    self.otherPeerID = nil;
    [self.connectButton setTitle:NSLocalizedString(@"connect", @"Shown on the connect button") 
                        forState:UIControlStateNormal];
    [self performSelector:@selector(resetInterface) 
               withObject:nil 
               afterDelay:3];
}

- (void)resetInterface
{
    self.statusLabel.text = NSLocalizedString(@"ready", @"Used when the application starts and after the peer disconnects");
}

- (void)disconnect
{
    [[GKVoiceChatService defaultVoiceChatService] stopVoiceChatWithParticipantID:self.otherPeerID];
    [self.chatSession disconnectFromAllPeers];
    self.chatSession.delegate = nil;
    self.chatSession = nil;
    self.connected = NO;
    [self.connectButton setTitle:NSLocalizedString(@"connect", @"Shown on the connect button") 
                        forState:UIControlStateNormal];
}

- (GKSession *)createSession
{
    NSString *sessionId = @"bluewoki";
    NSString *name = [[UIDevice currentDevice] name];
    GKSession *session = [[[GKSession alloc] initWithSessionID:sessionId 
                                                   displayName:name 
                                                   sessionMode:GKSessionModePeer] autorelease];
    return session;
}

@end
