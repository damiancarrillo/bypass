//
//  BPDocumentTests.m
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

#import <SenTestingKit/SenTestingKit.h>
#import "BPDocumentPrivate.h"

@interface BPDocumentTests : SenTestCase
@end

@implementation BPDocumentTests
{
    BPDocument *document;
}

- (void)setUp
{
    using namespace Bypass;
    
    Document d;
    
    Element e0;
    e0.setType(PARAGRAPH);
    e0.setText("text");
    e0.addAttribute("a", "A");
    e0.addAttribute("b", "B");
    d.append(e0);

    Element e1;
    e1.setType(PARAGRAPH);
    e1.setText("text");
    e1.addAttribute("a", "A");
    e1.addAttribute("b", "B");
    d.append(e1);
    
    document = [[BPDocument alloc] initWithDocument:d];
}

- (void)testInitialization
{
    STAssertNotNil(document, @"Expected non-nil document");
}

- (void)testElementsAccessor_forPointerEquality
{
    NSArray *elements = [document elements];
    STAssertEquals([document elements], elements, @"Expected same elements");
}

- (void)testChildElements
{
    STAssertEquals([[document elements] count], 2U, @"Expected 2 elements");
    STAssertEquals([[document elements][0] elementType], BPParagraph, @"Expected first element type to be BPParagraph");
    STAssertEquals([[document elements][1] elementType], BPParagraph, @"Expected second element type to be BPParagraph");
}

#if __has_feature(objc_subscripting)

- (void)testNumericSubscripting
{
    STAssertEquals(document[0], [[document elements] objectAtIndex:0], @"Expected document subscripting to return an element");
}

#endif


@end
