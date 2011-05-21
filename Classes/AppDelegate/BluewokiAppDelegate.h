//
//  BluewokiAppDelegate.h
//  bluewoki
//
//  Created by Adrian on 6/29/09.
//  Copyright akosma software 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BluewokiViewController;

@interface BluewokiAppDelegate : NSObject <UIApplicationDelegate>

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet BluewokiViewController *controller;

@end

