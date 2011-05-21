//
//  BluewokiViewController.h
//  bluewoki
//
//  Created by Adrian on 5/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface BluewokiViewController : UIViewController <GKPeerPickerControllerDelegate,
                                                      GKSessionDelegate,
                                                      GKVoiceChatClient>

@property (nonatomic, retain) IBOutlet UILabel *statusLabel;
@property (nonatomic, retain) IBOutlet UIButton *connectButton;
@property (nonatomic, getter = isConnected) BOOL connected;

- (IBAction)showPeers:(id)sender;
- (IBAction)openWebsite:(id)sender;

@end
