//
//  PeerService.h
//  bluewoki
//
//  Created by Adrian on 5/21/11.
//  Copyright 2011 akosma software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessageBrokerDelegate.h"

@class MessageBroker;


@interface PeerService : NSObject <NSNetServiceDelegate,
                                   MessageBrokerDelegate>

@property (nonatomic, retain) NSNetService *netService;
@property (nonatomic, retain) MessageBroker *messageBroker;
@property (nonatomic, getter = isConnected) BOOL connected;

- (void)startService;
- (void)stopService;

@end
