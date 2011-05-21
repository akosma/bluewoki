//
//  MessageBroker.h
//  bluewoki
//
//  Created by Adrian on 5/21/11.
//  Copyright 2011 akosma software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessageBrokerDelegate.h"

@class AsyncSocket;
@class MessageObject;

@interface MessageBroker : NSObject 

@property (nonatomic, assign) id<MessageBrokerDelegate> delegate;

- (id)initWithAsyncSocket:(AsyncSocket *)socket;
- (void)sendMessage:(MessageObject *)newMessage;

@end
