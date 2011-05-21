//
//  BluewokiViewController.m
//  bluewoki
//
//  Created by Adrian on 5/21/11.
//  Copyright 2011 akosma software. All rights reserved.
//

#import "BluewokiViewController.h"
#import "PeerService.h"
#import "PeersBrowserController.h"
#import "PeerProxy.h"

@interface BluewokiViewController ()

@property (nonatomic, retain) GKSession *chatSession;
@property (nonatomic, retain) GKPeerPickerController *pickerController;
@property (nonatomic, copy) NSString *otherPeerID;
@property (nonatomic, getter = isConnected) BOOL connected;
@property (nonatomic, retain) PeerService *service;
@property (nonatomic, retain) UINavigationController *navController;
@property (nonatomic, retain) PeerProxy *peerProxy;

- (void)closeConnectionWithMessage:(NSString *)message;
- (void)disconnect;
- (void)startChatWithPeerID:(NSString *)peerID;
- (GKSession *)createSession;

@end


@implementation BluewokiViewController

@synthesize chatSession = _chatSession;
@synthesize statusLabel = _statusLabel;
@synthesize connectButton = _connectButton;
@synthesize pickerController = _pickerController;
@synthesize connected = _connected;
@synthesize otherPeerID = _otherPeerID;
@synthesize service = _service;
@synthesize navController = _navController;
@synthesize peerProxy = _peerProxy;

- (void)dealloc
{
    [_pickerController setDelegate:nil];
    [_pickerController release];
    [_chatSession release];
    [_chatSession setDelegate:nil];
    [_otherPeerID release];
    [_service release];
    [_navController release];
    [_peerProxy release];
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

- (PeerService *)service
{
    if (_service == nil)
    {
        _service = [[PeerService alloc] init];
        _service.delegate = self;
    }
    return _service;
}

- (UINavigationController *)navController
{
    if (_navController == nil)
    {
        PeersBrowserController *peersBrowserController = [[[PeersBrowserController alloc] init] autorelease];
        peersBrowserController.delegate = self;
        _navController = [[UINavigationController alloc] initWithRootViewController:peersBrowserController];
    }
    return _navController;
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
        self.chatSession = [self createSession];
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

            [self.service startService];
            [self presentModalViewController:self.navController animated:YES];
            break;
        }
            
        case GKPeerPickerConnectionTypeNearby:
        {
            [self.service stopService];
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
            session = self.chatSession;
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
    self.chatSession.delegate = self;
    
    [self.pickerController dismiss];
    self.pickerController = nil;
    
    [self startChatWithPeerID:peerID];

}

- (void)peerPickerControllerDidCancel:(GKPeerPickerController *)picker
{
    // Do nothing, but in particular, do not dismiss the picker!
    // Otherwise the app would crash...!
}

#pragma mark - GKSessionDelegate methods

- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID
{
    if (session == self.chatSession)
    {
        [self.chatSession acceptConnectionFromPeer:peerID 
                                             error:nil];
        [self.chatSession connectToPeer:peerID withTimeout:60];
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
                [self startChatWithPeerID:peerID];
                break;
            }
                
            case GKPeerStateDisconnected:
            {
                [self closeConnectionWithMessage:NSLocalizedString(@"peer disconnected", @"Shown when the other user disconnects")];
                break;
            }
                
            case GKPeerStateConnecting:
            {
                self.statusLabel.text = NSLocalizedString(@"connecting", @"Shown while the connection is negotiated");
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

#pragma mark - PeersBrowserControllerDelegate methods

- (void)peersBrowserController:(PeersBrowserController *)controller didSelectPeer:(PeerProxy *)peer
{
    self.peerProxy = peer;
    self.peerProxy.delegate = self;
    [self.navController dismissModalViewControllerAnimated:YES];
    [self.peerProxy connect];
}

#pragma mark - PeerProxyDelegate methods

- (void)proxyDidConnect:(PeerProxy *)proxy
{
    if (proxy == self.peerProxy)
    {
        self.peerProxy.chatSession = self.chatSession;
        [self.peerProxy sendVoiceCallRequest];
    }
}

#pragma mark - PeerServiceDelegate methods

- (void)peerService:(PeerService *)service didReceiveCallRequestFromPeer:(NSString *)peerID
{
    if (service == self.service)
    {
        [self.navController dismissModalViewControllerAnimated:YES];
        [self.chatSession connectToPeer:peerID withTimeout:60];
    }
}

#pragma mark - Private methods

- (void)closeConnectionWithMessage:(NSString *)message
{
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [UIDevice currentDevice].proximityMonitoringEnabled = NO;
    self.statusLabel.text = message;
    [self disconnect];
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
    [self.service stopService];
    self.service = nil;

    [[GKVoiceChatService defaultVoiceChatService] stopVoiceChatWithParticipantID:self.otherPeerID];
    [self.chatSession disconnectFromAllPeers];
    self.chatSession.delegate = nil;
    self.chatSession = nil;
    self.connected = NO;
    self.otherPeerID = nil;
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
    session.delegate = self;
    session.available = YES;
    [session setDataReceiveHandler:self withContext:nil];
    return session;
}

- (void)startChatWithPeerID:(NSString *)peerID
{
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

@end
