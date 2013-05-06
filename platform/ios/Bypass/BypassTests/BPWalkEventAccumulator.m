//
//  BPWalkEventAccumulator.m
//  Bypass
//
//  Created by Damian Carrillo on 3/22/13.
//  Copyright 2013 Uncodin, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
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

- (void)elementWalker:(BPElementWalker *)elementWalker
     willVisitElement:(BPElement *)element
        withTextRange:(NSRange)textRange
{
  [_accumulatedEvents addObject:@{
      BYPASS_ELEMENT: element,
      BYPASS_RANGE: [NSValue valueWithRange:textRange],
      BYPASS_EVENT_TYPE: @(BPEventTypeBefore)
  }];
}

- (void)elementWalker:(BPElementWalker *)elementWalker
      didVisitElement:(BPElement *)element
        withTextRange:(NSRange)textRange
{
    [_accumulatedEvents addObject:@{
        BYPASS_ELEMENT: element,
        BYPASS_RANGE: [NSValue valueWithRange:textRange],
        BYPASS_EVENT_TYPE: @(BPEventTypeAfter)
    }];
}

- (NSArray *)accumulatedEvents
{
    return [NSArray arrayWithArray:_accumulatedEvents];
}

@end
