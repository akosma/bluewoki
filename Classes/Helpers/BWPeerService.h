//
//  BWPeerService.h
//  bluewoki
//
//  Created by Adrian on 5/21/11.
//  Copyright 2011 akosma software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BWMessageBrokerDelegate.h"
#import "BWPeerServiceDelegate.h"

@class BWMessageBroker;


@interface BWPeerService : NSObject <NSNetServiceDelegate,
                                     BWMessageBrokerDelegate>

@property (nonatomic, retain) NSNetService *netService;
@property (nonatomic, retain) BWMessageBroker *messageBroker;
@property (nonatomic, getter = isConnected) BOOL connected;
@property (nonatomic, assign) id<BWPeerServiceDelegate> delegate;

- (void)startService;
- (void)stopService;

@end
