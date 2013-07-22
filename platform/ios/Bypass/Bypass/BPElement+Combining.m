//
//  BPElement+Combining.m
//  Bypass
//
//  Created by Damian Carrillo on 7/19/13.
//  Copyright (c) 2013 Uncodin. All rights reserved.
//

#import "BPElement+Combining.h"

@implementation BPElement (Combining)

- (BOOL)canBeCombinedWithElement:(BPElement *)otherElement
{
    BOOL elementsCanBeCombined = NO;
    
    if ([self elementType] != BPLink
        && [otherElement elementType] != BPLink
        && ![self isBlockElement]
        && ![otherElement isBlockElement]
        && [[self parentElement] elementType] == [[otherElement parentElement] elementType]
        && [[self parentElement] elementType] != BPListItem) {
        
        elementsCanBeCombined = YES;
        
        for (id key in [[[self parentElement] attributes] allKeys]) {
            if (![[[otherElement parentElement] attributes][key] isEqual:[[self parentElement] attributes][key]]) {
                elementsCanBeCombined = NO;
                break;
            }
        }
    }
    
    return elementsCanBeCombined;
}

@end
