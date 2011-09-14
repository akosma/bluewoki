//
//  BWBrowserController.m
//  bluewoki
//
//  Created by Adrian on 5/21/11.
//  Copyright 2011 akosma software. All rights reserved.
//

#import "BWBrowserController.h"
#import "BWPeerBrowser.h"
#import "BWPeerProxy.h"

@interface BWBrowserController ()

@property (nonatomic, retain) UIBarButtonItem *cancelItem;

@end


@implementation BWBrowserController

@synthesize browser = _browser;
@synthesize cancelItem = _cancelItem;
@synthesize delegate = _delegate;

- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self)
    {
    }
    return self;
}

- (void)dealloc
{
    [_browser release];
    [_cancelItem release];
    _delegate = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self.tableView
                                             selector:@selector(reloadData) 
                                                 name:PeerBrowserDidChangeCountNotification
                                               object:nil];

    self.cancelItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
                                                                     target:self
                                                                     action:@selector(cancel:)] autorelease];
    self.navigationItem.rightBarButtonItem = self.cancelItem;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.title = @"bluewoki online";
    self.tableView.backgroundColor = [UIColor darkGrayColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)cancel:(id)sender
{
    [self.browser stopSearchingForPeers];
    [self dismissModalViewControllerAnimated:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.browser = [[[BWPeerBrowser alloc] init] autorelease];
    [self.browser startSearchingForPeers];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.browser stopSearchingForPeers];
    self.browser = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.browser connectedPeersCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) 
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:CellIdentifier] autorelease];
    }
    
    BWPeerProxy *peer = [self.browser peerAtIndex:indexPath.row];
    cell.textLabel.text = peer.serviceName;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BWPeerProxy *peer = [self.browser peerAtIndex:indexPath.row];
    if ([self.delegate respondsToSelector:@selector(peersBrowserController:didSelectPeer:)])
    {
        [self.delegate peersBrowserController:self didSelectPeer:peer];
    }
}

@end
