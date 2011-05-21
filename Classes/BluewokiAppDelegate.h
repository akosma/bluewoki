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

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UILabel *statusLabel;
@property (nonatomic, retain) IBOutlet UIButton *connectButton;
@property (nonatomic, getter = isConnected) BOOL connected;

- (IBAction)showPeers:(id)sender;
- (IBAction)openWebsite:(id)sender;

@end

