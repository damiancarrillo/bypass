//
//  BPElementWalkerTests.m
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
#import "BPElementWalker.h"
#import "BPDocumentPrivate.h"
#import "BPElementPrivate.h"
#import "BPWalkEventAccumulator.h"

@interface BPElementWalkerTests : SenTestCase
@end

@implementation BPElementWalkerTests
{
    BPDocument      *_document;
    BPElementWalker *_elementWalker;
}

- (void)setUp
{
    _elementWalker = [[BPElementWalker alloc] init];
    
    using namespace Bypass;
    
    Document d;
    
    Element e0;
    e0.setType(TEXT);
    e0.setText("one ");
    d.append(e0);
    
    Element e1;
    e1.setType(DOUBLE_EMPHASIS);
    e1.setText("two");
    d.append(e1);
    
    Element e2;
    e2.setType(TEXT);
    e2.setText(" three");
    d.append(e2);
    
    _document = [[BPDocument alloc] initWithDocument:d];
    
    STAssertEquals([[_document elements] count], 3U, @"Expected document to have 3 child elements");
}

- (void)tearDown
{
    _document = nil;
    _elementWalker = nil;
}

- (void)testWalkDocument
{
    BPWalkEventAccumulator *walkEventAccumulator = [[BPWalkEventAccumulator alloc] init];
    [_elementWalker addElementVisitor:walkEventAccumulator];
    [_elementWalker walkDocument:_document];
    
    NSArray *events = [walkEventAccumulator accumulatedEvents];
    
    STAssertEquals([events count], 6U, @"Expected 6 acumulated events");
    
    // Events accumulated for the first element
    
    /* Identity Checks */ {
        STAssertEquals([events[0][BYPASS_ELEMENT] elementType], BPText,
                       @"Expected a text element");
        STAssertEquals([events[1][BYPASS_ELEMENT] elementType], BPText,
                       @"Expected a text element");
        
        STAssertEquals([events[0][BYPASS_EVENT_TYPE] unsignedIntegerValue], BPEventTypeBefore,
                       @"Expected a 'before' event");
        STAssertEquals([events[1][BYPASS_EVENT_TYPE] unsignedIntegerValue], BPEventTypeAfter,
                       @"Expected an 'after' event");
    }

    /* Range Checks */ {
        STAssertEquals([events[0][BYPASS_RANGE] rangeValue].location, 0U,
                       @"Expected location 0");
        STAssertEquals([events[1][BYPASS_RANGE] rangeValue].location, 0U,
                       @"Expected location 0");
        
        STAssertEquals([events[0][BYPASS_RANGE] rangeValue].length, 4U,
                       @"Expected length 4");
        STAssertEquals([events[1][BYPASS_RANGE] rangeValue].length,
                       [[[_document elements][0] text] length],
                       @"Expected length to match element 1 text");
    }
    
    // Events accumulated for the second element
    
    /* Identity Checks */ {
        STAssertEquals([events[2][BYPASS_ELEMENT] elementType], BPDoubleEmphasis,
                       @"Expected a double emphasis element");
        STAssertEquals([events[3][BYPASS_ELEMENT] elementType], BPDoubleEmphasis,
                       @"Expected a double emphasis element");
        
        STAssertEquals([events[2][BYPASS_EVENT_TYPE] unsignedIntegerValue], BPEventTypeBefore,
                       @"Expected a 'before' event");
        STAssertEquals([events[3][BYPASS_EVENT_TYPE] unsignedIntegerValue], BPEventTypeAfter,
                       @"Expected an 'after' event");
    }
    
    /* Range checks */ {
        STAssertEquals([events[2][BYPASS_RANGE] rangeValue].location,
                       [[[_document elements][0] text] length],
                       @"Expected location 0");
        STAssertEquals([events[3][BYPASS_RANGE] rangeValue].location,
                       [[[_document elements][0] text] length],
                       @"Expected location 0");
        
        STAssertEquals([events[2][BYPASS_RANGE] rangeValue].length, 3U,
                       @"Expected length 3");
        STAssertEquals([events[3][BYPASS_RANGE] rangeValue].length,
                       [[[_document elements][1] text] length],
                       @"Expected length to match element 2 text");
    }
    
    // Events accumulated for the third element
    
    /* Identity Checks */ {
        STAssertEquals([events[4][BYPASS_ELEMENT] elementType], BPText,
                       @"Expected a text element");
        STAssertEquals([events[5][BYPASS_ELEMENT] elementType], BPText,
                       @"Expected a text element");
        
        STAssertEquals([events[4][BYPASS_EVENT_TYPE] unsignedIntegerValue], BPEventTypeBefore,
                       @"Expected a 'before' event");
        STAssertEquals([events[5][BYPASS_EVENT_TYPE] unsignedIntegerValue], BPEventTypeAfter,
                       @"Expected an 'after' event");
    }
    
    /* Range checks */ {
        STAssertEquals([events[4][BYPASS_RANGE] rangeValue].location,
                       [[[_document elements][0] text] length] + [[[_document elements][1] text] length],
                       @"Expected location 0");
        STAssertEquals([events[5][BYPASS_RANGE] rangeValue].location,
                       [[[_document elements][0] text] length] + [[[_document elements][1] text] length],
                       @"Expected location 0");
        
        STAssertEquals([events[4][BYPASS_RANGE] rangeValue].length, 6U,
                       @"Expected length 6");
        STAssertEquals([events[5][BYPASS_RANGE] rangeValue].length,
                       [[[_document elements][2] text] length],
                       @"Expected length to match element 3 text");
    }
}

@end
