//
//  BPWalkEventAccumulator.h
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

#import <Foundation/Foundation.h>
#import "BPElementWalker.h"

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
