//
//  BWBrowserController.h
//  bluewoki
//
//  Created by Adrian on 5/21/11.
//  Copyright 2011 akosma software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BWBrowserControllerDelegate.h"

@class BWPeerBrowser;

@interface BWBrowserController : UITableViewController

@property (nonatomic, retain) BWPeerBrowser *browser;
@property (nonatomic, assign) id<BWBrowserControllerDelegate> delegate;

@end
