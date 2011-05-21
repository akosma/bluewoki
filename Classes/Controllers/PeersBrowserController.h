//
//  PeersBrowserController.h
//  bluewoki
//
//  Created by Adrian on 5/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PeersBrowserControllerDelegate.h"

@class PeerBrowser;

@interface PeersBrowserController : UITableViewController

@property (nonatomic, retain) PeerBrowser *browser;
@property (nonatomic, assign) id<PeersBrowserControllerDelegate> delegate;

@end
