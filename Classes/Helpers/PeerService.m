//
//  PeerService.m
//  bluewoki
//
//  Created by Adrian on 5/21/11.
//  Copyright 2011 akosma software. All rights reserved.
//

#import "PeerService.h"
#import "Protocol.h"
#import "MessageBroker.h"
#import "AsyncSocket.h"
#import "Message.h"


@interface PeerService ()

@property (readwrite, retain) AsyncSocket *listeningSocket;
@property (readwrite, retain) AsyncSocket *connectionSocket;

@end


@implementation PeerService

@synthesize messageBroker = _messageBroker;
@synthesize listeningSocket = _listeningSocket;
@synthesize connectionSocket = _connectionSocket;
@synthesize netService = _netService;
@synthesize connected = _connected;

- (void)dealloc
{
    [self stopService];
    [_messageBroker release];

    [super dealloc];
}

#pragma mark - Public methods

-(void)startService 
{
    NSError *error;
    self.listeningSocket = [[[AsyncSocket alloc] init] autorelease];
    [self.listeningSocket setDelegate:self];
    if (![self.listeningSocket acceptOnPort:0 error:&error]) 
    {
        NSLog(@"Failed to create listening socket");
        return;
    }
    
    self.netService = [[[NSNetService alloc] initWithDomain:@"" 
                                                       type:BLUEWOKI_PROTOCOL_NAME 
                                                       name:[UIDevice currentDevice].name
                                                       port:self.listeningSocket.localPort] autorelease];
    self.netService.delegate = self;
    [self.netService publish];
}

-(void)stopService 
{
    self.listeningSocket = nil;
    self.connectionSocket = nil;
    
    [self.netService stop];
    self.netService = nil;
}

#pragma mark - Socket Callbacks

- (BOOL)onSocketWillConnect:(AsyncSocket *)sock 
{
    if (self.connectionSocket == nil) 
    {
        self.connectionSocket = sock;
        return YES;
    }
    return NO;
}

-(void)onSocketDidDisconnect:(AsyncSocket *)sock 
{
    if (sock == self.connectionSocket)
    {
        self.connectionSocket = nil;
        self.messageBroker = nil;
        self.connected = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UPDATE_SCREEN" object:nil];
    }
}

-(void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port 
{
    self.messageBroker = [[[MessageBroker alloc] initWithAsyncSocket:sock] autorelease];
    self.messageBroker.delegate = self;
    self.connected = YES;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UPDATE_SCREEN" object:nil];
}

#pragma mark - Net Service Delegate Methods

- (void)netService:(NSNetService *)aNetService didNotPublish:(NSDictionary *)dict 
{
    NSLog(@"Failed to publish: %@", dict);
}

@end
