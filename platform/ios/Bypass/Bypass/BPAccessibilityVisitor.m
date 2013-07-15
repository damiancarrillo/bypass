//
//  BPAccessibilityVisitor.m
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

#import <UIKit/UIKit.h>
#import "BPAccessibilityElement.h"
#import "BPAccessibilityVisitor.h"
#import "BPElement.h"

@implementation BPAccessibilityVisitor
{
    NSUInteger      _elementIndex;
    id              _accessibilityContainer;
    NSMutableArray *_accumulatedAccessibilityElements;
    NSArray        *_accessibleElements;
    NSMutableArray *_accumulatedLinkIndices;
    NSArray        *_linkIndices;
}

- (id)init
{
    [NSException raise:@"Use initWithAccessibilityContainer:" format:@"Use initWithAccessibilityContainer:"];
    
    return self;
}

- (id)initWithAccessibilityContainer:(id)accessibilityContainer
{
    self = [super init];
    
    if (self != nil) {
        _elementIndex = 0;
        _accessibilityContainer = accessibilityContainer;
        _accumulatedAccessibilityElements = [[NSMutableArray alloc] init];
        _accumulatedLinkIndices = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)elementWalker:(BPElementWalker *)elementWalker
     willVisitElement:(BPElement *)element
        withTextRange:(NSRange)textRange
{
    // do nothing
}

- (int)elementWalker:(BPElementWalker *)elementWalker
      didVisitElement:(BPElement *)element
        withTextRange:(NSRange)textRange
{
    if ([element text] == nil) {
        // Element is structural and won't need an accessibility element
        return 0;
    }
        
    BPAccessibilityElement *accessibilityElement =
        [[BPAccessibilityElement alloc] initWithAccessibilityContainer:_accessibilityContainer];
    
    [accessibilityElement setTextRange:textRange];
    [accessibilityElement setAccessibilityValue:[element text]];
    [accessibilityElement setAccessibilityLabel:[element text]];

    // Determine appropriate accessibility traits based on the element type
    
    UIAccessibilityTraits accessibilityTraits = UIAccessibilityTraitStaticText;
    
    if ([element elementType] == BPLink) {
        accessibilityTraits |= UIAccessibilityTraitLink;
        [_accumulatedLinkIndices addObject:@(_elementIndex)];
    }
    
    if ([[element parentElement] elementType] == BPHeader) {
        // Header text has a parent element of type BPHeader
        accessibilityTraits |= UIAccessibilityTraitHeader;
    }
    
    [accessibilityElement setAccessibilityTraits:accessibilityTraits];
    [_accumulatedAccessibilityElements addObject:accessibilityElement];
    
    _elementIndex++;
    
    return 0;
}

- (NSArray *)accessibleElements
{
    if (_accessibleElements == nil) {
        _accessibleElements = [NSArray arrayWithArray:_accumulatedAccessibilityElements];
    }
    
    return _accessibleElements;
}

- (NSArray *)linkIndices
{
    if (_linkIndices == nil) {
        _linkIndices = [NSArray arrayWithArray:_accumulatedLinkIndices];
    }
    
    return _linkIndices;
}

@end
