//
//  MessageBroker.m
//  bluewoki
//
//  Created by Adrian on 5/21/11.
//  Copyright 2011 akosma software. All rights reserved.
//

#import "MessageBroker.h"
#import "AsyncSocket.h"
#import "MessageObject.h"

static const unsigned int MESSAGE_HEADER_SIZE = sizeof(UInt64);
static const float SOCKET_TIMEOUT = -1.0;

@interface MessageBroker ()

@property (nonatomic, retain) AsyncSocket *socket;
@property (nonatomic) BOOL connectionLostUnexpectedly;
@property (nonatomic, retain) NSMutableArray *messageQueue;
@property (nonatomic, getter = isPaused) BOOL paused;

@end


@implementation MessageBroker

@synthesize delegate = _delegate;
@synthesize socket = _socket;
@synthesize connectionLostUnexpectedly = _connectionLostUnexpectedly;
@synthesize messageQueue = _messageQueue;
@synthesize paused = _paused;

-(id)initWithAsyncSocket:(AsyncSocket *)newSocket 
{
    self = [super init];
    if (self) 
    {
        _socket = [newSocket retain];
        [_socket setDelegate:self];
        _messageQueue = [[NSMutableArray alloc] init];
        [_socket readDataToLength:MESSAGE_HEADER_SIZE 
                      withTimeout:SOCKET_TIMEOUT
                              tag:0];
    }
    return self;
}

- (void)dealloc
{
    _delegate = nil;
    
    [_socket setDelegate:nil];
    if ([_socket isConnected]) 
    {
        [_socket disconnect];
    }
    [_socket release];
    _socket = nil;
    
    [_messageQueue release];
    _messageQueue = nil;
    
    [super dealloc];
}

#pragma mark - Public methods

-(void)sendMessage:(MessageObject *)message 
{
    [self.messageQueue addObject:message];
    NSData *messageData = [NSKeyedArchiver archivedDataWithRootObject:message];
    
    UInt64 header[1];
    header[0] = [messageData length]; 
    header[0] = CFSwapInt64HostToLittle(header[0]);
    
    NSData *headerData = [NSData dataWithBytes:header 
                                        length:MESSAGE_HEADER_SIZE];
    [self.socket writeData:headerData
               withTimeout:SOCKET_TIMEOUT 
                       tag:(long)0];
    
    [self.socket writeData:messageData
               withTimeout:SOCKET_TIMEOUT
                       tag:(long)1];
}

#pragma mark - AsyncSocket delegate methods

- (void)onSocketDidDisconnect:(AsyncSocket *)sock 
{
    if (self.connectionLostUnexpectedly) 
    {
        if ([self.delegate respondsToSelector:@selector(messageBroker:didDisconnectUnexpectedly:)])
        {
            [self.delegate messageBrokerDidDisconnectUnexpectedly:self];
        }
    }
}

- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err 
{
    self.connectionLostUnexpectedly = YES;
}

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag 
{
    switch (tag) 
    {
        case 0:
        {
            // Header
            UInt64 header = *((UInt64*)[data bytes]);
            header = CFSwapInt64LittleToHost(header);  // Convert from little endian to native
            [self.socket readDataToLength:(CFIndex)header 
                              withTimeout:SOCKET_TIMEOUT
                                      tag:(long)1];
            break;
        }
            
        case 1:
        {
            // Message body. Pass to delegate
            if ([self.delegate respondsToSelector:@selector(messageBroker:didReceiveMessage:)] ) 
            {
                MessageObject *message = [NSKeyedUnarchiver unarchiveObjectWithData:data];
                [self.delegate messageBroker:self didReceiveMessage:message];
            }
            
            // Begin listening for next message
            if (!self.isPaused)
            {
                [self.socket readDataToLength:MESSAGE_HEADER_SIZE 
                                  withTimeout:SOCKET_TIMEOUT
                                          tag:(long)0];
            }
            break;
        }
            
        default:
        {
            NSLog(@"Unknown tag in read of socket data %d", (int)tag);
            break;
        }
    }
}

- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag 
{
    if (tag == 1) 
    {
        // If the message is now complete, remove from queue, and tell the delegate
        MessageObject *message = [[[self.messageQueue objectAtIndex:0] retain] autorelease];
        [self.messageQueue removeObjectAtIndex:0];
        if ([self.delegate respondsToSelector:@selector(messageBroker:didSendMessage:)])
        {
            [self.delegate messageBroker:self didSendMessage:message];
        }
    }
}

@end
