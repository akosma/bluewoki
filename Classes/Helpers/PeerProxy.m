//
//  PeerProxy.m
//  bluewoki
//
//  Created by Adrian on 5/21/11.
//  Copyright 2011 akosma software. All rights reserved.
//

#import "PeerProxy.h"
#import "Protocol.h"
#import "MessageBroker.h"
#import "AsyncSocket.h"
#import "Message.h"

@interface PeerProxy ()

@property (readwrite, retain) AsyncSocket *listeningSocket;
@property (readwrite, retain) AsyncSocket *connectionSocket;
@property (nonatomic, retain) NSNetService *service;
@property (nonatomic, retain) AsyncSocket *socket;

@end


@implementation PeerProxy

@synthesize listeningSocket = _listeningSocket;
@synthesize connectionSocket = _connectionSocket;
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
        _service.delegate = self;
        
        NSError *myErr;
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&myErr];
        [audioSession setActive:YES error:&myErr];
        
        // Routing default audio to external speaker
        AudioSessionInitialize(NULL, NULL, NULL, NULL);
        UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
        AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute,
                                sizeof(audioRouteOverride),
                                &audioRouteOverride);
        AudioSessionSetActive(true);
        
        [GKVoiceChatService defaultVoiceChatService].client = self;
        
        NSString *sessionId = @"workgroup";
        NSString *name = [[UIDevice currentDevice] name];
        self.chatSession = [[[GKSession alloc] initWithSessionID:sessionId 
                                                     displayName:name 
                                                     sessionMode:GKSessionModePeer] autorelease];
        self.chatSession.delegate = self;
        self.chatSession.available = YES;
    }
    return self;
}

- (void)dealloc
{
    [self stopService];
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
    self.messageBroker.delegate = nil;
    self.messageBroker = nil;
    
    [self.netService stop];
    self.netService = nil;
}

- (void)sendVoiceCallRequest
{
    Message *newMessage = [[[Message alloc] init] autorelease];
    newMessage.kind = MessageKindVoiceCallRequest;
    newMessage.body = [self.chatSession.peerID dataUsingEncoding:NSUTF8StringEncoding];
    [self.messageBroker sendMessage:newMessage];
}

- (void)answerToCallFromPeerID:(NSString *)peerID
{
    [self.chatSession connectToPeer:peerID withTimeout:60];
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

#pragma mark - MessageBroker Delegate Methods

- (void)messageBroker:(MessageBroker *)server didReceiveMessage:(Message *)message 
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

#pragma mark - GKSessionDelegate methods

- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID
{
    if (session == self.chatSession)
    {
        [self.chatSession acceptConnectionFromPeer:peerID 
                                             error:nil];
        [self.chatSession connectToPeer:peerID withTimeout:60];
    }
}

- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state
{
    switch (state) 
    {
        case GKPeerStateAvailable:
            break;
            
        case GKPeerStateUnavailable:
            break;
            
        case GKPeerStateConnected:
        {
            [self.chatSession setDataReceiveHandler:self
                                        withContext:nil];
            [[GKVoiceChatService defaultVoiceChatService] startVoiceChatWithParticipantID:peerID 
                                                                                    error:nil];
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
            {
                [UIApplication sharedApplication].idleTimerDisabled = YES;
                [UIDevice currentDevice].proximityMonitoringEnabled = YES;
            }
            break;
        }
            
        case GKPeerStateDisconnected:
            break;
            
        case GKPeerStateConnecting:
            break;
            
        default:
            break;
    }
}

- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error
{
    if (session == self.chatSession)
    {
    }
}

#pragma mark - GKVoiceChatClient methods

- (NSString *)participantID
{
    return self.chatSession.peerID;
}

- (void)voiceChatService:(GKVoiceChatService *)voiceChatService sendData:(NSData *)data toParticipantID:(NSString *)participantID
{
    [self.chatSession sendData:data 
                       toPeers:[NSArray arrayWithObject:participantID] 
                  withDataMode:GKSendDataReliable 
                         error: nil];
}

- (void)receiveData:(NSData *)data fromPeer:(NSString *)peer inSession:(GKSession *)session context:(void *)context;
{
    [[GKVoiceChatService defaultVoiceChatService] receivedData:data 
                                             fromParticipantID:peer];
}

@end
