//
//  BluewokiAppDelegate.h
//  bluewoki
//
//  Created by Adrian on 6/29/09.
//  Copyright akosma software 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>

@interface BluewokiAppDelegate : NSObject <UIApplicationDelegate, 
                                           GKPeerPickerControllerDelegate,
                                           GKSessionDelegate,
                                           GKVoiceChatClient> 
{
    IBOutlet UIWindow *window;
    IBOutlet UILabel *statusLabel;
    IBOutlet UIButton *connectButton;
    GKPeerPickerController *pickerController;
    GKSession *chatSession;
}

@property (nonatomic, retain) GKSession *chatSession;

- (IBAction)showPeers:(id)sender;
- (IBAction)openWebsite:(id)sender;

@end

