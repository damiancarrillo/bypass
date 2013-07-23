//
//  BPElement+AccessibilityCombining.m
//  Bypass
//
//  Created by Damian Carrillo on 7/19/13.
//  Copyright (c) 2013 Uncodin. All rights reserved.
//

#import "BPElement+AccessibilityCombining.h"

@implementation BPElement (AccessibilityCombining)

- (BOOL)canBeCombinedWithElement:(BPElement *)otherElement
{
    BOOL elementsCanBeCombined = NO;
    
    if (otherElement
        && [self elementType]         != BPLink
        && [otherElement elementType] != BPLink
        && [self elementType]         != BPAutoLink
        && [otherElement elementType] != BPAutoLink) {
        elementsCanBeCombined = YES;
    }
    
    return elementsCanBeCombined;
}

@end
