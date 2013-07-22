//
//  BPAccessibilityElement.m
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

#import "BPAccessibilityElement.h"

@implementation BPAccessibilityElement

- (id)initWithAccessibilityContainer:(id)container
{
    self = [super initWithAccessibilityContainer:container];
    
    if (self) {
        [self setAccessibilityFrame:CGRectNull];
    }
    
    return self;
}

- (BOOL)isAccessibilityElement
{
    return YES;
}

- (NSString *)description
{
    NSMutableArray *items = [NSMutableArray array];
    [items addObject:[NSString stringWithFormat:@"{%ld, %ld}", _textRange.location, _textRange.length]];
    
    if ([self accessibilityLabel]) {
        [items addObject:[NSString stringWithFormat:@"%@ = '%@'", @"accessibilityLabel", [self accessibilityLabel]]];
    }
    
    if ([self accessibilityValue]) {
        [items addObject:[NSString stringWithFormat:@"%@ = '%@'", @"accessibilityValue", [self accessibilityValue]]];
    }
    
    if ([self accessibilityHint]) {
        [items addObject:[NSString stringWithFormat:@"%@ = '%@'", @"accessibilityHint", [self accessibilityHint]]];
    }
    
    [items addObject:[NSString stringWithFormat:@"%@ = %@", @"accessibilityFrame", NSStringFromCGRect([self accessibilityFrame])]];
    [items addObject:[NSString stringWithFormat:@"%@ = %@", @"accessibilityTraits", @([self accessibilityTraits])]];
    
    NSString *description = [items componentsJoinedByString:@", "];
    description = [NSString stringWithFormat:@"{%@}", description];
    
    return description;
}

@end
