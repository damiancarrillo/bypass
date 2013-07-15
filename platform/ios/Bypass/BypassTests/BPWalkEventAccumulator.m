//
//  BPWalkEventAccumulator.m
//  Bypass
//
//  Created by Damian Carrillo on 3/22/13.
//  Copyright (c) 2013 Uncodin. All rights reserved.
//

#import "BPWalkEventAccumulator.h"

NSString *const BYPASS_ELEMENT    = @"BYPASS_ELEMENT";
NSString *const BYPASS_RANGE      = @"BYPASS_RANGE";
NSString *const BYPASS_EVENT_TYPE = @"BYPASS_EVENT_TYPE";

@implementation BPWalkEventAccumulator
{
    NSMutableArray *_accumulatedEvents;
}

- (id)init
{
    self = [super init];
    
    if (self != nil) {
        _accumulatedEvents = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)documentWalker:(BPDocumentWalker *)documentWalker
      willVisitElement:(BPElement *)element
         withTextRange:(NSRange)textRange
{
  [_accumulatedEvents addObject:@{
      BYPASS_ELEMENT:    element,
      BYPASS_RANGE:      [NSValue valueWithRange:textRange],
      BYPASS_EVENT_TYPE: @(BPEventTypeBefore)
  }];
}

- (void)documentWalker:(BPDocumentWalker *)documentWalker
       didVisitElement:(BPElement *)element
         withTextRange:(NSRange)textRange
{
    [_accumulatedEvents addObject:@{
        BYPASS_ELEMENT:    element,
        BYPASS_RANGE:      [NSValue valueWithRange:textRange],
        BYPASS_EVENT_TYPE: @(BPEventTypeAfter)
    }];
}

- (NSArray *)accumulatedEvents
{
    return [NSArray arrayWithArray:_accumulatedEvents];
}

@end
