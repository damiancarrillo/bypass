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

#import <CoreText/CoreText.h>
#import <UIKit/UIKit.h>
#import "BPAccessibilityElement.h"
#import "BPAccessibilityVisitor.h"
#import "BPElement.h"

@implementation BPAccessibilityVisitor
{
    NSUInteger      _elementIndex;
    NSUInteger      _characterIndex;
    id              _accessibilityContainer;
    NSMutableArray *_accumulatedAccessibleElements;
    NSArray        *_accessibleElements;
    NSMutableArray *_accumulatedLinkIndices;
    NSArray        *_linkIndices;
    BPElement      *_previousElement;
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
        _characterIndex = 0;
        _accessibilityContainer = accessibilityContainer;
        _accumulatedAccessibleElements = [[NSMutableArray alloc] init];
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
    NSString *trimmedText = [[element text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([trimmedText length] == 0) {
        
        // Element is structural and won't need an accessibility element
        
        return 0;
    }
    
    if ([self element:element canBeCombinedWithElement:_previousElement]) {
        BPAccessibilityElement *acessibilityElement = [_accumulatedAccessibleElements lastObject];
        NSString *concatenatedLabel = [@[[acessibilityElement accessibilityLabel], trimmedText] componentsJoinedByString:@" "];
        [acessibilityElement setAccessibilityLabel:concatenatedLabel];
        
        CFRange textRange = [acessibilityElement textRange];
        textRange.length += [trimmedText length];
    } else {
        BPAccessibilityElement *accessibilityElement = [[BPAccessibilityElement alloc] initWithAccessibilityContainer:_accessibilityContainer];
        [accessibilityElement setElementType:[element elementType]];
        [accessibilityElement setAccessibilityLabel:trimmedText];
        
        CFRange textRange;
        textRange.location = _characterIndex;
        textRange.length = [trimmedText length];
        
        [accessibilityElement setTextRange:textRange];
        
        UIAccessibilityTraits accessibilityTraits = UIAccessibilityTraitStaticText;
        
        if ([[element parentElement] elementType] == BPHeader) {
            
            // Header text has a parent element of type BPHeader
            
            accessibilityTraits |= UIAccessibilityTraitHeader;
        }
        
        if ([element elementType] == BPLink || [element elementType] == BPAutoLink) {
            accessibilityTraits |= UIAccessibilityTraitLink;
            
            [_accumulatedLinkIndices addObject:@(_elementIndex)];
        }
        
        [accessibilityElement setAccessibilityTraits:accessibilityTraits];
        [_accumulatedAccessibleElements addObject:accessibilityElement];
    }

    _characterIndex += [trimmedText length];
    _previousElement = element;
    
    return 0;
}

- (BOOL)element:(BPElement *)a canBeCombinedWithElement:(BPElement *)b
{
    BOOL elementsCanBeCombined = NO;
    
    if ([a elementType] != BPLink
        && [b elementType] != BPLink
        && ![a isBlockElement]
        && ![b isBlockElement]
        && [[a parentElement] elementType] == [[b parentElement] elementType]
        && [[a parentElement] elementType] != BPListItem) {
        
        elementsCanBeCombined = YES;
        
        for (id ak in [[[a parentElement] attributes] allKeys]) {
            if (![[[b parentElement] attributes][ak] isEqual:[[a parentElement] attributes][ak]]) {
                elementsCanBeCombined = NO;
                break;
            }
        }
    }
    
    return elementsCanBeCombined;
}

- (NSArray *)accessibleElements
{
    if (_accessibleElements == nil) {
        _accessibleElements = [NSArray arrayWithArray:_accumulatedAccessibleElements];
        
        NSLog(@"%@", _accessibleElements);
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
