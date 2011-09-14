//
//  BWMessageObject.m
//  bluewoki
//
//  Created by Adrian on 5/21/11.
//  Copyright 2011 akosma software. All rights reserved.
//

#import "BWMessageObject.h"


@implementation BWMessageObject

@synthesize kind = _kind;
@synthesize body = _body;

- (id)init
{
    self = [super init];
    if (self)
    {
        _kind = MessageKindNone;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder 
{
    self = [super init];
    if (self) 
    {
        _kind = (MessageKind)[coder decodeIntForKey:@"kind"];
        _body = [[coder decodeObjectForKey:@"body"] retain];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder 
{
    [coder encodeInt:self.kind forKey:@"kind"];
    [coder encodeObject:self.body forKey:@"body"];
}

- (void)dealloc
{
    [_body release];
    _body = nil;
    
    [super dealloc];
}

@end
