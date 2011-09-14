//
//  BWMessageObject.h
//  bluewoki
//
//  Created by Adrian on 5/21/11.
//  Copyright 2011 akosma software. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum {
    BWMessageKindNone = 0,
    BWMessageKindVoiceCallRequest = 1,
    BWMessageKindVoiceCallRequestDenied = 2
} BWMessageKind;

@interface BWMessageObject : NSObject <NSCoding>

@property (nonatomic) BWMessageKind kind;
@property (nonatomic, retain) NSData *body;

@end
