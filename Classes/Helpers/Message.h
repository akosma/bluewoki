//
//  Message.h
//  bluewoki
//
//  Created by Adrian on 5/21/11.
//  Copyright 2011 akosma software. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum {
    MessageKindNone = 0,
    MessageKindVoiceCallRequest = 1,
    MessageKindEndVoiceCall = 2
} MessageKind;

@interface Message : NSObject <NSCoding>

@property (nonatomic) MessageKind kind;
@property (nonatomic, retain) NSData *body;

@end
