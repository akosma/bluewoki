//
//  BluewokiViewController.h
//  bluewoki
//
//  Created by Adrian on 5/21/11.
//  Copyright 2011 akosma software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "PeersBrowserControllerDelegate.h"
#import "PeerProxyDelegate.h"
#import "PeerServiceDelegate.h"

@interface BluewokiViewController : UIViewController <GKPeerPickerControllerDelegate,
                                                      GKSessionDelegate,
                                                      GKVoiceChatClient,
                                                      PeersBrowserControllerDelegate,
                                                      PeerProxyDelegate,
                                                      PeerServiceDelegate>

@property (nonatomic, retain) IBOutlet UILabel *statusLabel;
@property (nonatomic, retain) IBOutlet UIButton *connectButton;

- (IBAction)showPeers:(id)sender;
- (IBAction)openWebsite:(id)sender;

@end
