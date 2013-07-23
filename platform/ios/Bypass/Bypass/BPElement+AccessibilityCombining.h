//
//  BPElement+AccessibilityCombining.h
//  Bypass
//
//  Created by Damian Carrillo on 7/19/13.
//  Copyright (c) 2013 Uncodin. All rights reserved.
//

#import "BPElement.h"

@interface BPElement (AccessibilityCombining)

- (BOOL)canBeCombinedWithElement:(BPElement *)otherElement;

@end
