//
//  BPWalkEventAccumulator.h
//  Bypass
//
//  Created by Damian Carrillo on 3/22/13.
//  Copyright (c) 2013 Uncodin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BPDocumentWalker.h"

OBJC_EXPORT NSString *const BYPASS_ELEMENT;
OBJC_EXPORT NSString *const BYPASS_RANGE;
OBJC_EXPORT NSString *const BYPASS_EVENT_TYPE;

NS_ENUM(NSUInteger, BPEventType)
{
    BPEventTypeBefore,
    BPEventTypeAfter
};

@interface BPWalkEventAccumulator : NSObject <BPElementVisitor>

/*
 * An array of NSDictionaries.
 */
- (NSArray *)accumulatedEvents;

@end
