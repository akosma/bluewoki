//
//  BWAppDelegate.h
//  bluewoki
//
//  Created by Adrian on 6/29/09.
//  Copyright akosma software 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BWRootController;

@interface BWAppDelegate : NSObject <UIApplicationDelegate>

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet BWRootController *controller;

@end

