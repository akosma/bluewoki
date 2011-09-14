//
//  BWPeerBrowser.m
//  bluewoki
//
//  Created by Adrian on 5/21/11.
//  Copyright 2011 akosma software. All rights reserved.
//

#import "BWPeerBrowser.h"
#import "BWProtocol.h"
#import "BWPeerProxy.h"

NSString * const PeerBrowserDidChangeCountNotification = @"PeerBrowserDidChangeCountNotification";


@implementation BWPeerBrowser

@synthesize peerArray = _peerArray;
@synthesize peerBrowser = _peerBrowser;

- (id)init
{
    self = [super init];
    if (self)
    {
        _peerArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [self stopSearchingForPeers];
    
    [_peerArray release];
    
    [super dealloc];
}

#pragma mark - Public methods

- (NSInteger)connectedPeersCount
{
    return [self.peerArray count];
}

- (void)startSearchingForPeers
{
    self.peerBrowser = [[[NSNetServiceBrowser alloc] init] autorelease];
    [self.peerBrowser setDelegate:self];
    [self.peerBrowser searchForServicesOfType:BLUEWOKI_PROTOCOL_NAME
                                       inDomain:@""];
}

- (void)stopSearchingForPeers
{
    [self.peerBrowser stop];
    self.peerBrowser = nil;
    [self.peerArray removeAllObjects];
    [[NSNotificationCenter defaultCenter] postNotificationName:PeerBrowserDidChangeCountNotification
                                                        object:self];
}

- (BWPeerProxy *)peerAtIndex:(NSUInteger)index
{
    return [self.peerArray objectAtIndex:index];
}

#pragma mark - NSNetServiceBrowser delegate methods

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser
           didFindService:(NSNetService *)service
               moreComing:(BOOL)more
{
    if (!more)
    {
        if (![[service name] isEqualToString:[UIDevice currentDevice].name])
        {
            BWPeerProxy *peer = [BWPeerProxy proxyWithService:service];
            [self.peerArray addObject:peer];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:PeerBrowserDidChangeCountNotification
                                                                object:self];
        }
    }
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser
         didRemoveService:(NSNetService *)service
               moreComing:(BOOL)more
{
    if (!more)
    {
        BWPeerProxy *peerToRemove = nil;
        for (BWPeerProxy *proxy in self.peerArray)
        {
            if ([proxy.serviceName isEqualToString:[service name]])
            {
                peerToRemove = proxy;
            }
        }
        
        if (peerToRemove != nil)
        {
            [self.peerArray removeObject:peerToRemove];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:PeerBrowserDidChangeCountNotification 
                                                            object:self];
    }
}

@end
