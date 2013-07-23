//
//  BPAttributedTextVisitor.m
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
#import "BPDisplaySettings.h"
#import "BPAttributedTextVisitor.h"
#import "BPAccessibilityElement.h"
#import "BPElement+AccessibilityCombining.h"

NSString *const BPLinkStyleAttributeName = @"NSLinkAttributeName";

@interface BPAttributedTextVisitor ()
@property (nonatomic) BOOL renderedFirstParagraph;
@property (strong, nonatomic) NSMutableArray *accumulatedAccessibilityElements;
@property (strong, nonatomic) BPElement *previousElement; // for accessibility element combining
@end

@implementation BPAttributedTextVisitor
@synthesize accessibilityElements = _accessibilityElements;

#pragma mark Lifecycle

- (id)init {
    if ((self = [super init])) {
        _displaySettings = [[BPDisplaySettings alloc] init];
        _attributedText = [[NSMutableAttributedString alloc] init];
        _accumulatedAccessibilityElements = [NSMutableArray array];
	}

    return self;
}

- (void)elementWalker:(BPElementWalker *)elementWalker
     willVisitElement:(BPElement *)element
        withTextRange:(NSRange)textRange
{
    if ([element isBlockElement]) {
        _previousElement = nil;
    }
}

- (NSInteger)elementWalker:(BPElementWalker *)elementWalker
           didVisitElement:(BPElement *)element
             withTextRange:(NSRange)textRange
{
    return [self convertElement:element toTarget:_attributedText range:textRange];
}

#pragma mark Rendering

- (NSInteger)convertElement:(BPElement *)element
                   toTarget:(NSMutableAttributedString *)target
                      range:(NSRange)effectiveRange
{
    NSInteger insertedCharacters = 0;
    
    BPElementType elementType = [element elementType];
    
    // Render span elements and insert special characters for block elements
    if (elementType == BPList) {
        if ([[element parentElement] elementType] == BPListItem) {
            insertedCharacters += [self insertNewlineIntoTarget:target atIndex:effectiveRange.location];
        }
    } else if (elementType == BPAutoLink) {
        [self renderLinkElement:element toTarget:target];
    } else if (elementType == BPCodeSpan) {
        [self renderCodeSpanElement:element toTarget:target];
    } else if (elementType == BPDoubleEmphasis) {
        [self renderBoldElement:element toTarget:target];
    } else if (elementType == BPEmphasis) {
        [self renderItalicElement:element toTarget:target];
    } else if (elementType == BPImage) {
        // Currently not supported
    } else if (elementType == BPLineBreak) {
        [self renderLineBreak:element toTarget:target];
    } else if (elementType == BPLink) {
        [self renderLinkElement:element toTarget:target];
    } else if (elementType == BPRawHTMLTag) {
        // Currently not supported
    } else if (elementType == BPTripleEmphasis) {
        [self renderBoldItalicElement:element toTarget:target];
    } else if (elementType == BPText) {
        [self renderTextElement:element toTarget:target];
    } else if (elementType == BPParagraph) {
        [self renderParagraphElement:element inRange:effectiveRange toTarget:target];
    } else if (elementType == BPHeader) {
        [self renderHeaderElement:element inRange:effectiveRange toTarget:target];
    } else if (elementType == BPListItem) {
        insertedCharacters += [self renderListItemElement:element inRange:effectiveRange toTarget:target];
    } else if (elementType == BPBlockCode) {
        insertedCharacters += [self renderBlockCodeElement:element inRange:effectiveRange toTarget:target];
    } else if (elementType == BPBlockQuote) {
        [self renderBlockQuoteElement:element inRange:effectiveRange toTarget:target];
    } else if (elementType == BPStrikethrough) {
        [self renderStruckthroughElement:element toTarget:target];
    }
    
    if ([element isBlockElement]
        && ![[element parentElement] isBlockElement]
        && ![[[element parentElement] parentElement] isBlockElement]) {
        insertedCharacters += [self appendNewlineOntoTarget:target];
    }
    
    return insertedCharacters;
}

#pragma mark Character Insertion

- (NSInteger)insertNewlineIntoTarget:(NSMutableAttributedString*) target
                       atIndex:(int) index
{
    [target insertAttributedString:[[NSMutableAttributedString alloc] initWithString:@"\n"] atIndex:index];
    
    return 1;
}

- (NSInteger)appendNewlineOntoTarget:(NSMutableAttributedString *)target
{
    [target appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"\n"]];
    
    return 1;
}

#pragma mark Span Element Rendering

- (void)renderSpanElement:(BPElement *)element
                 withFont:(UIFont *)font
                 toTarget:(NSMutableAttributedString *)target
{
    [self renderSpanElement:element
                   withFont:font
                 attributes:[NSMutableDictionary dictionary]
                   toTarget:target];
}

- (void)renderSpanElement:(BPElement *)element
                 withFont:(UIFont *)font
               attributes:(NSMutableDictionary *)attributes
                 toTarget:(NSMutableAttributedString *)target
{
    
    if (font == nil) {
        NSLog(@"%@", [element debugDescription]);
        return;
    }
  
    attributes[NSFontAttributeName] = font;
    
    NSString *text;
    
    if ([[element parentElement] elementType] == BPBlockCode) {
        
        // Preserve whitespace within a code block
        
        text = [element text];
    } else {
        text = [[element text] stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    }
    
    if (text != nil) {
        [self createAccessibilityElementForElement:element forText:text];
        
        NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text
                                                                             attributes:attributes];
        [target appendAttributedString:attributedText];
    }
}

- (void)renderTextElement:(BPElement *)element toTarget:(NSMutableAttributedString *)target
{
    [self renderSpanElement:element withFont:[_displaySettings defaultFont] toTarget:target];
}

- (void)renderBoldItalicElement:(BPElement *)element
                       toTarget:(NSMutableAttributedString *)target
{
    [self renderSpanElement:element withFont:[_displaySettings boldItalicFont] toTarget:target];
}

- (void)renderBoldElement:(BPElement *)element
                 toTarget:(NSMutableAttributedString *)target
{
    [self renderSpanElement:element withFont:[_displaySettings boldFont] toTarget:target];
}

- (void)renderItalicElement:(BPElement *)element
                   toTarget:(NSMutableAttributedString *)target
{
    [self renderSpanElement:element withFont:[_displaySettings italicFont] toTarget:target];
}

- (void)renderStruckthroughElement:(BPElement *)element
                          toTarget:(NSMutableAttributedString *)target
{
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    attributes[NSStrikethroughStyleAttributeName] = @(1);
    [self renderSpanElement:element
                   withFont:[_displaySettings defaultFont]
                 attributes:attributes
                   toTarget:target];
}

- (void)renderCodeSpanElement:(BPElement *)element
                     toTarget:(NSMutableAttributedString *)target
{
    [self renderSpanElement:element withFont:[_displaySettings monospaceFont] toTarget:target];
}

- (void)renderLinkElement:(BPElement *)element
                 toTarget:(NSMutableAttributedString *)target
{
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    attributes[NSUnderlineStyleAttributeName] = @(NSUnderlineStyleSingle);
    attributes[NSForegroundColorAttributeName] = [_displaySettings linkColor];
    attributes[BPLinkStyleAttributeName] = element[@"link"];
    [self renderSpanElement:element
                   withFont:[_displaySettings defaultFont]
                 attributes:attributes
                   toTarget:target];
}

- (void)renderLineBreak:(BPElement *)element
               toTarget:(NSMutableAttributedString *)target
{
    [self appendNewlineOntoTarget:target];
}

#pragma mark Block Element Rendering

- (void)renderBlockQuoteElement:(BPElement *)element
                        inRange:(NSRange)effectiveRange
                       toTarget:(NSMutableAttributedString *)target
{
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    attributes[NSFontAttributeName] = [_displaySettings quoteFont];
    attributes[NSForegroundColorAttributeName] = [_displaySettings quoteColor];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setParagraphSpacing:[_displaySettings paragraphSpacingHeading]];
    [paragraphStyle setFirstLineHeadIndent:[_displaySettings quoteIndentation]];
    [paragraphStyle setHeadIndent:[_displaySettings quoteIndentation]];
    [paragraphStyle setTailIndent:-[_displaySettings quoteIndentation]];
    attributes[NSParagraphStyleAttributeName] = paragraphStyle;
    
    [target addAttributes:attributes range:effectiveRange];
}

- (NSInteger)renderBlockCodeElement:(BPElement *)element
                            inRange:(NSRange)effectiveRange
                           toTarget:(NSMutableAttributedString *)target
{
    NSInteger insertedCharacters = 0;
    
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    attributes[NSFontAttributeName] = [_displaySettings monospaceFont];
    attributes[NSForegroundColorAttributeName] = [_displaySettings codeColor];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setParagraphSpacing:[_displaySettings paragraphSpacingCode]];
    [paragraphStyle setFirstLineHeadIndent:[_displaySettings codeIndentation]];
    [paragraphStyle setHeadIndent:[_displaySettings codeIndentation]];
    [paragraphStyle setTailIndent:-[_displaySettings codeIndentation]];
    attributes[NSParagraphStyleAttributeName] = paragraphStyle;
    
    [target addAttributes:attributes range:effectiveRange];
    
    insertedCharacters += [self appendNewlineOntoTarget:target];
    
    return insertedCharacters;
}

- (void)renderParagraphElement:(BPElement *)element
                       inRange:(NSRange)effectiveRange
                      toTarget:(NSMutableAttributedString *)target
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setParagraphSpacing:[_displaySettings paragraphSpacing]];
    [paragraphStyle setLineSpacing:[_displaySettings paragraphLineSpacing]];
    [paragraphStyle setFirstLineHeadIndent:[_displaySettings paragraphFirstLineHeadIndent]];
    
    if (!_renderedFirstParagraph) {
        [paragraphStyle setFirstLineHeadIndent:[_displaySettings firstParagraphFirstLineHeadIndent]];
        _renderedFirstParagraph = true;
    }
    [paragraphStyle setHeadIndent:[_displaySettings paragraphHeadIndent]];

    NSDictionary *attributes = @{NSParagraphStyleAttributeName : paragraphStyle};
    [target addAttributes:attributes range:effectiveRange];
}

- (NSInteger)renderListItemElement:(BPElement *)element
                           inRange:(NSRange)effectiveRange
                          toTarget:(NSMutableAttributedString *)target
{
    NSInteger insertedCharacters = 0;
    
    NSUInteger level = 0;
    BPElement *inspectedElement = [[element parentElement] parentElement];
    NSMutableString *indentation = [NSMutableString string];
    
    while ([inspectedElement elementType] == BPList || [inspectedElement elementType] == BPListItem) {
        if ([inspectedElement elementType] == BPList) {
            [indentation appendString:@"\t"];
            ++level;
        }
        
        inspectedElement = [inspectedElement parentElement];
    }
    
    UIColor *bulletColor;
    
    switch (level % 3) {
        case 1:
            bulletColor = [UIColor grayColor];
            break;
        case 2:
            bulletColor = [UIColor lightGrayColor];
            break;
        default:
            bulletColor = [UIColor blackColor];
            break;
    }
    
    NSDictionary *bulletAttributes = @{NSFontAttributeName: [_displaySettings bulletFont],
                                       NSForegroundColorAttributeName: bulletColor};
    
    NSAttributedString *attributedBullet;
    attributedBullet = [[NSAttributedString alloc] initWithString:@"• " attributes:bulletAttributes];
    [target insertAttributedString:attributedBullet atIndex:effectiveRange.location];
    
    insertedCharacters += 2;
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:[_displaySettings lineSpacingSmall]];
    [paragraphStyle setHeadIndent:[_displaySettings bulletIndentation]];
    
    NSDictionary *indentationAttributes = @{NSFontAttributeName: [UIFont systemFontOfSize:[_displaySettings bulletIndentation]],
                                            NSParagraphStyleAttributeName: paragraphStyle};
    
    NSAttributedString *attributedIndentation;
    attributedIndentation = [[NSAttributedString alloc] initWithString:indentation attributes:indentationAttributes];
    [target insertAttributedString:attributedIndentation atIndex:effectiveRange.location];
    insertedCharacters += [attributedIndentation length];
    
    if (([[[element parentElement] parentElement] elementType] != BPListItem) || (element != [[[element parentElement] childElements] lastObject])) {
        insertedCharacters += [self appendNewlineOntoTarget:target];
    }
    
    return insertedCharacters;
}

- (void)renderHeaderElement:(BPElement *)element
                    inRange:(NSRange)effectiveRange
                   toTarget:(NSMutableAttributedString *)target
{
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setParagraphSpacing:[_displaySettings paragraphSpacingHeading]];
    [paragraphStyle setLineSpacing:[_displaySettings paragraphLineSpacingHeading]];
    [paragraphStyle setFirstLineHeadIndent:[_displaySettings headerFirstLineHeadIndent]];
    [paragraphStyle setHeadIndent:[_displaySettings headerHeadIndent]];
    attributes[NSParagraphStyleAttributeName] = paragraphStyle;
    
    // Override font weight and size attributes (but preserve all other attributes)
    
    switch ([element[@"level"] integerValue]) {
        case 1:
            attributes[NSFontAttributeName] = [_displaySettings h1Font];
            break;
        case 2:
            [paragraphStyle setParagraphSpacing:[_displaySettings paragraphSpacingH2]];
            attributes[NSFontAttributeName] = [_displaySettings h2Font];
            break;
        case 3:
            attributes[NSFontAttributeName] = [_displaySettings h3Font];
            break;
        case 4:
            attributes[NSFontAttributeName] = [_displaySettings h4Font];
            break;
        case 5:
            attributes[NSFontAttributeName] = [_displaySettings h5Font];
            break;
        case 6:
            attributes[NSFontAttributeName] = [_displaySettings h6Font];
            break;
        default:
            attributes[NSFontAttributeName] = [_displaySettings defaultFont];
            break;
    }
    
    [target addAttributes:attributes range:effectiveRange];
}

#pragma mark Accessibility

- (NSArray *)accessibilityElements
{
    if (_accessibilityElements == nil) {
        _accessibilityElements = [NSArray arrayWithArray:_accumulatedAccessibilityElements];
    }
    
    return _accessibilityElements;
}

- (void)createAccessibilityElementForElement:(BPElement *)element forText:(NSString *)text
{
    
    // Ensure that the element is not structural
    
    if ([[text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] > 0) {
        BPAccessibilityElement *accessibilityElement;
        
        if ([element canBeCombinedWithElement:_previousElement]) {
            accessibilityElement = [_accumulatedAccessibilityElements lastObject];
            
            CFRange textRange = [accessibilityElement textRange];
            textRange.length += [text length];
            
            [accessibilityElement setTextRange:textRange];
            
            NSMutableString *combinedText = [NSMutableString stringWithString:[accessibilityElement accessibilityLabel]];
            [combinedText appendString:text];
            
            [accessibilityElement setAccessibilityLabel:combinedText];
        } else {
            accessibilityElement = [[BPAccessibilityElement alloc] initWithAccessibilityContainer:_accessibilityContainer];
            [accessibilityElement setTextRange:CFRangeMake([_attributedText length], [text length])];
            [accessibilityElement setAccessibilityLabel:text];
            
            if ([element elementType] == BPLink || [element elementType] == BPAutoLink) {
                [accessibilityElement setAccessibilityTraits:UIAccessibilityTraitLink];
            } else if ([[element parentElement] elementType] == BPHeader) {
                [accessibilityElement setAccessibilityTraits:UIAccessibilityTraitHeader];
            }
            
            [_accumulatedAccessibilityElements addObject:accessibilityElement];
        }

        _previousElement = element;
    }
}

@end
