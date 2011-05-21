//
//  BluewokiAppDelegate.m
//  bluewoki
//
//  Created by Adrian on 6/29/09.
//  Copyright akosma software 2009. All rights reserved.
//

#import "BluewokiAppDelegate.h"
#import "BluewokiViewController.h"

@implementation BluewokiAppDelegate

@synthesize window = _window;
@synthesize controller = _controller;

- (void)applicationDidFinishLaunching:(UIApplication *)application 
{
    self.window.rootViewController = self.controller;
    [self.window makeKeyAndVisible];
}

- (void)dealloc 
{
    [_window release];
    [_controller release];
    [super dealloc];
}

@end
