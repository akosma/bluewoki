//
//  BWConnectionDelegate.h
//  bluewoki
//
//  Created by Adrian on 9/14/11.
//  Copyright 2011 akosma software. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BWConnection;


@protocol BWConnectionDelegate <NSObject>

@optional

- (void)connection:(BWConnection *)connection didFailWithError:(NSError *)error;
- (void)connectionIsConnecting:(BWConnection *)connection;
- (void)connectionDidConnect:(BWConnection *)connection;
- (void)connectionDidDisconnect:(BWConnection *)connection;
- (void)connectionDidReceiveCall:(BWConnection *)connection;

@end
