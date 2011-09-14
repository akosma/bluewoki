//
//  BWMessageBrokerDelegate.h
//  bluewoki
//
//  Created by Adrian on 5/21/11.
//  Copyright 2011 akosma software. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BWMessageBroker;
@class BWMessageObject;

@protocol BWMessageBrokerDelegate <NSObject>

@optional

- (void)messageBroker:(BWMessageBroker *)server didSendMessage:(BWMessageObject *)message;

- (void)messageBroker:(BWMessageBroker *)server didReceiveMessage:(BWMessageObject *)message;

- (void)messageBrokerDidDisconnectUnexpectedly:(BWMessageBroker *)server;

@end
