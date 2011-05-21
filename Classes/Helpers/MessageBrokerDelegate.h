//
//  MessageBrokerDelegate.h
//  bluewoki
//
//  Created by Adrian on 5/21/11.
//  Copyright 2011 akosma software. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MessageBroker;
@class Message;

@protocol MessageBrokerDelegate <NSObject>

@optional

- (void)messageBroker:(MessageBroker *)server didSendMessage:(Message *)message;

- (void)messageBroker:(MessageBroker *)server didReceiveMessage:(Message *)message;

- (void)messageBrokerDidDisconnectUnexpectedly:(MessageBroker *)server;

@end
