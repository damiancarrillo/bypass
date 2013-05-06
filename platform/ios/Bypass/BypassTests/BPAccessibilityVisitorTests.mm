//
//  BPAccessibilityVisitorTests.m
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
#import <SenTestingKit/SenTestingKit.h>
#import "BPElementPrivate.h"
#import "BPAccessibilityVisitor.h"

@interface BPAccessibilityVisitorTests : SenTestCase
@end

@implementation BPAccessibilityVisitorTests
{
    BPAccessibilityVisitor *_visitor;
    NSArray                *_elements;
}

- (void)setUp
{
    using namespace Bypass;
    
    _visitor = [[BPAccessibilityVisitor alloc] init];
    
    Element e0;
    e0.setType(TEXT);
    e0.setText("one ");
    BPElement *ee0 = [[BPElement alloc] initWithElement:e0];
    
    Element e1;
    e1.setType(LINK);
    e1.setText("two");
    BPElement *ee1 = [[BPElement alloc] initWithElement:e1];
    
    Element e2;
    e2.setType(TEXT);
    e2.setText(" three");
    BPElement *ee2 = [[BPElement alloc] initWithElement:e2];
    
    _elements = @[ee0, ee1, ee2];
}

- (void)tearDown
{
    _visitor = nil;
}

- (void)testDidVisitElement {
    for (BPElement *element in _elements) {
        NSRange range;
        range.location = 0;
        range.length = 0;
        
        [_visitor elementWalker:nil willVisitElement:element withTextRange:range];
        [_visitor elementWalker:nil didVisitElement:element withTextRange:range];
    }
    
    STAssertEquals([[_visitor accessibilityElements] count], 3U,
                   @"Expected 3 accessibility elements");
    STAssertEquals([[_visitor linkIndices] count], 1U,
                   @"Expected 1 link index");
    STAssertEquals([[_visitor linkIndices][0] unsignedIntegerValue], 1U,
                   @"Expected link index to point to element 1");
}

@end
