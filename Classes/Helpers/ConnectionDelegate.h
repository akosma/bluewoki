//
//  ConnectionDelegate.h
//  bluewoki
//
//  Created by Adrian on 9/14/11.
//  Copyright 2011 akosma software. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Connection;


@protocol ConnectionDelegate <NSObject>

@optional

- (void)connection:(Connection *)connection didFailWithError:(NSError *)error;
- (void)connectionIsConnecting:(Connection *)connection;
- (void)connectionDidConnect:(Connection *)connection;
- (void)connectionDidDisconnect:(Connection *)connection;

@end
