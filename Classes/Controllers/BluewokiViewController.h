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
#import "ConnectionDelegate.h"

@interface BluewokiViewController : UIViewController <ConnectionDelegate,
                                                      GKPeerPickerControllerDelegate>

@property (nonatomic, retain) IBOutlet UILabel *statusLabel;
@property (nonatomic, retain) IBOutlet UIButton *connectButton;

- (IBAction)showConnectionKinds:(id)sender;
- (IBAction)openWebsite:(id)sender;

@end
