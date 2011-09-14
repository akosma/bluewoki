//
//  BWMessageBroker.h
//  bluewoki
//
//  Created by Adrian on 5/21/11.
//  Copyright 2011 akosma software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BWMessageBrokerDelegate.h"

@class AsyncSocket;
@class BWMessageObject;

@interface BWMessageBroker : NSObject 

@property (nonatomic, assign) id<BWMessageBrokerDelegate> delegate;

- (id)initWithAsyncSocket:(AsyncSocket *)socket;
- (void)sendMessage:(BWMessageObject *)newMessage;

@end
