//
//  BWPeerProxy.m
//  bluewoki
//
//  Created by Adrian on 5/21/11.
//  Copyright 2011 akosma software. All rights reserved.
//

#import "BWPeerProxy.h"
#import "BWProtocol.h"
#import "BWMessageBroker.h"
#import "AsyncSocket.h"
#import "BWMessageObject.h"

@interface BWPeerProxy ()

@property (nonatomic, retain) NSNetService *netService;
@property (nonatomic, retain) NSNetService *service;
@property (nonatomic, retain) AsyncSocket *socket;
@property (nonatomic, retain) BWMessageBroker *messageBroker;

@end


@implementation BWPeerProxy

@synthesize netService = _netService;
@synthesize messageBroker = _messageBroker;
@synthesize service = _service;
@synthesize connected = _connected;
@synthesize socket = _socket;
@synthesize chatSession = _chatSession;
@synthesize delegate = _delegate;
@dynamic serviceName;

+ (id)proxyWithService:(NSNetService *)service
{
    return [[[[self class] alloc] initWithService:service] autorelease];
}

- (id)initWithService:(NSNetService *)service
{
    self = [super init];
    if (self)
    {
        _connected = NO;
        
        _service = [service retain];
        [_service setDelegate:self];
    }
    return self;
}

- (void)dealloc
{
    [_chatSession release];
    [_messageBroker release];
    [_service release];
    [_socket release];
    
    _delegate = nil;
    
    [super dealloc];
}

#pragma mark - Public methods

- (NSString *)serviceName
{
    return [self.service name];
}

- (void)connect
{
    [self.service resolveWithTimeout:0];    
}

- (void)sendVoiceCallRequest
{
    BWMessageObject *newMessage = [[[BWMessageObject alloc] init] autorelease];
    newMessage.kind = MessageKindVoiceCallRequest;
    newMessage.body = [self.chatSession.peerID dataUsingEncoding:NSUTF8StringEncoding];
    [self.messageBroker sendMessage:newMessage];
}

- (void)answerToCallFromPeerID:(NSString *)peerID
{
    [self.chatSession connectToPeer:peerID withTimeout:60];
}

#pragma mark - NSNetServiceDelegate methods

- (void)netServiceDidResolveAddress:(NSNetService *)service 
{
    self.socket = [[[AsyncSocket alloc] init] autorelease];
    [self.socket setDelegate:self];
    [self.socket connectToAddress:service.addresses.lastObject error:nil];
}

- (void)netService:(NSNetService *)service didNotResolve:(NSDictionary *)errorDict 
{
    NSLog(@"Could not resolve: %@", errorDict);
}

#pragma mark - Socket Callbacks

-(void)onSocketDidDisconnect:(AsyncSocket *)sock 
{
    self.socket = nil;
    self.messageBroker = nil;
    self.connected = NO;
    
    if ([self.delegate performSelector:@selector(proxyDidDisconnect:)])
    {
        [self.delegate proxyDidDisconnect:self];
    }
}

-(BOOL)onSocketWillConnect:(AsyncSocket *)sock 
{
    if (self.messageBroker == nil) 
    {
        [sock retain];
        return YES;
    }
    return NO;
}

-(void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port 
{
    self.messageBroker = [[[BWMessageBroker alloc] initWithAsyncSocket:sock] autorelease];
    [sock release];
    self.messageBroker.delegate = self;
    self.connected = YES;
    
    if ([self.delegate performSelector:@selector(proxyDidConnect:)])
    {
        [self.delegate proxyDidConnect:self];
    }
}

#pragma mark - MessageBroker Delegate Methods

- (void)messageBroker:(BWMessageBroker *)server didReceiveMessage:(BWMessageObject *)message 
{
    switch (message.kind) 
    {
        case MessageKindVoiceCallRequest:
        {
            NSString *peerID = [[[NSString alloc] initWithData:message.body 
                                                      encoding:NSUTF8StringEncoding] autorelease];
            if ([self.delegate respondsToSelector:@selector(proxy:didReceiveCallRequestFromPeer:)])
            {
                [self.delegate proxy:self didReceiveCallRequestFromPeer:peerID];
            }
            break;
        }
            
        case MessageKindEndVoiceCall:
        {
            [self.chatSession disconnectFromAllPeers];
            self.chatSession = nil;
            break;
        }
            
        default:
            break;
    }
}

@end
