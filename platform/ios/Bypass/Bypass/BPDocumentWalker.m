//
//  BPDocumentWalker.m
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

#import "BPDocument.h"
#import "BPDocumentWalker.h"

@implementation BPDocumentWalker
{
    NSMutableArray *_elementVisitors;
    NSUInteger      _location;
}

- (id)init
{
    self = [super init];
    
    if (self != nil) {
        _elementVisitors = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)addElementVisitor:(id<BPElementVisitor>)elementVisitor
{
    [_elementVisitors addObject:elementVisitor];
}

- (void)walkDocument:(BPDocument *)document
{
    _location = 0;
    
    for (BPElement *element in [document elements]) {
        [self walkSubtreeWithRootElement:element];
    }
}

- (void)walkSubtreeWithRootElement:(BPElement *)rootElement
{
    NSRange textRange;
    textRange.location = _location;
    textRange.length = 0U;

    for (id<BPElementVisitor> elementVisitor in _elementVisitors) {
        [elementVisitor documentWalker:self willVisitElement:rootElement withTextRange:textRange];
    }
    
    for (BPElement *element in [rootElement childElements]) {
        for (id<BPElementVisitor> elementVisitor in _elementVisitors) {
            [self walkSubtreeWithRootElement:element];
            textRange.length = _location - textRange.location;
        }
        
        _location += [[element text] length];
    }
    
    _location += [[rootElement text] length];
    textRange.length = _location - textRange.location;
    
    for (id<BPElementVisitor> elementVisitor in _elementVisitors) {
        [elementVisitor documentWalker:self didVisitElement:rootElement withTextRange:textRange];
    }
}

@end