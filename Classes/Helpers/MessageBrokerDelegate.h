//
//  MessageBrokerDelegate.h
//  bluewoki
//
//  Created by Adrian on 5/21/11.
//  Copyright 2011 akosma software. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MessageBroker;
@class MessageObject;

@protocol MessageBrokerDelegate <NSObject>

@optional

- (void)messageBroker:(MessageBroker *)server didSendMessage:(MessageObject *)message;

- (void)messageBroker:(MessageBroker *)server didReceiveMessage:(MessageObject *)message;

- (void)messageBrokerDidDisconnectUnexpectedly:(MessageBroker *)server;

@end
