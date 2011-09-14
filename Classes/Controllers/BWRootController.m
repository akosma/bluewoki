//
//  BWRootController.m
//  bluewoki
//
//  Created by Adrian on 5/21/11.
//  Copyright 2011 akosma software. All rights reserved.
//

#import "BWRootController.h"
#import "BWBrowserController.h"
#import "BWBluetoothConnection.h"
#import "BWWifiConnection.h"

@interface BWRootController ()

@property (nonatomic, retain) BWConnection *connection;
@property (nonatomic, retain) UINavigationController *navController;

- (void)closeConnectionWithMessage:(NSString *)message;

@end


@implementation BWRootController

@synthesize statusLabel = _statusLabel;
@synthesize connectButton = _connectButton;
@synthesize navController = _navController;
@synthesize connection = _connection;

- (void)dealloc
{
    [_connection release];
    [_navController release];
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

#pragma mark - IBAction methods

- (IBAction)showConnectionKinds:(id)sender
{
    if (self.connection.isConnected)
    {
        [self closeConnectionWithMessage:NSLocalizedString(@"disconnected", @"Shown when the other user disconnects")];
        self.connection = nil;
    }
    else
    {
        // Create a peer picker to select Bluetooth vs. Wifi connection
        GKPeerPickerController *pickerController = [[[GKPeerPickerController alloc] init] autorelease];
        pickerController.delegate = self;
        pickerController.connectionTypesMask = GKPeerPickerConnectionTypeNearby 
                                                | GKPeerPickerConnectionTypeOnline;
        [pickerController show];
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
    [picker dismiss];
    switch (type) 
    {
        case GKPeerPickerConnectionTypeOnline:
        {
            self.connection = [BWWifiConnection connection];

            if (self.navController == nil)
            {
                BWBrowserController *peersBrowserController = [[[BWBrowserController alloc] init] autorelease];
                peersBrowserController.delegate = self.connection;
                self.navController = [[[UINavigationController alloc] initWithRootViewController:peersBrowserController] autorelease];
            }

            [self presentModalViewController:self.navController animated:YES];
            break;
        }
            
        case GKPeerPickerConnectionTypeNearby:
        {
            self.connection = [BWBluetoothConnection connection];
            break;
        }
            
        default:
            break;
    }
    self.connection.delegate = self;
    [self.connection connect];
}

#pragma mark - BWConnectionDelegate methods

- (void)connection:(BWConnection *)connection didFailWithError:(NSError *)error
{
    [self closeConnectionWithMessage:NSLocalizedString(@"error", @"Shown when the connection generated an error")];
}

- (void)connectionIsConnecting:(BWConnection *)connection
{
    if (self.navController != nil)
    {
        [self.navController dismissModalViewControllerAnimated:YES];
    }
    self.statusLabel.text = NSLocalizedString(@"connecting", @"Shown while the connection is negotiated");
}

- (void)connectionDidConnect:(BWConnection *)connection
{
    self.statusLabel.text = [NSString stringWithFormat:NSLocalizedString(@"connected with", @"Shows who we're talking to"), 
                             self.connection.otherPeerName];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    [UIDevice currentDevice].proximityMonitoringEnabled = YES;
    [self.connectButton setTitle:NSLocalizedString(@"disconnect", @"Shown on the disconnect button") 
                        forState:UIControlStateNormal];
}

- (void)connectionDidDisconnect:(BWConnection *)connection
{
    [self closeConnectionWithMessage:NSLocalizedString(@"peer disconnected", @"Shown when the other user disconnects")];
}

#pragma mark - Private methods

- (void)closeConnectionWithMessage:(NSString *)message
{
    [self.connection disconnect];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [UIDevice currentDevice].proximityMonitoringEnabled = NO;
    self.statusLabel.text = message;
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

@end
