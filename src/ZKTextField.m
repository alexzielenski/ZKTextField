//
//  ZKTextField.m
//  ZKTextField
//
//  Created by Alex Zielenski on 4/11/12.
//  Copyright (c) 2012 Alex Zielenski. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


// This is used for secure text fields for generating bullets rather than text for display.
@interface ZKSecureGlyphGenerator : NSGlyphGenerator
@end

@implementation ZKSecureGlyphGenerator

- (void)generateGlyphsForGlyphStorage:(id < NSGlyphStorage> )glyphStorage
			desiredNumberOfCharacters:(NSUInteger)nChars
						   glyphIndex:(NSUInteger *)glyphIndex
					   characterIndex:(NSUInteger *)charIndex {
		
	NSUInteger bullet = 0x87;
	NSGlyph newGlyphs[1] = {bullet};
	[glyphStorage insertGlyphs:newGlyphs length:1 forStartingGlyphAtIndex:*glyphIndex characterIndex:*charIndex];
}

@end

#import "ZKTextField.h"

#pragma mark - Private Class Extension
@interface ZKTextField () <NSTextViewDelegate, NSTextDelegate>
@property (nonatomic, retain) NSBezierPath *_currentClippingPath;
@property (nonatomic, retain) NSTextView   *_currentFieldEditor;
@property (nonatomic, retain) NSClipView   *_currentClipView;
- (void)_configureFieldEditor;
@end

@implementation ZKTextField

#pragma mark - Private Properties

@synthesize _currentClippingPath;
@synthesize _currentFieldEditor;
@synthesize _currentClipView;

#pragma mark - Public Properties
@dynamic string;
@dynamic placeholderString;
@synthesize attributedString            = _attributedString;
@synthesize attributedPlaceholderString = _attributedPlaceholderString;
@synthesize backgroundColor             = _backgroundColor;
@synthesize drawsBackground             = _drawsBackground;
@synthesize drawsBorder                 = _drawsBorder;
@synthesize hasHoverCursor              = _hasHoverCursor;
@synthesize shouldClipContent           = _shouldClipContent;
@synthesize secure                      = _secure;
@synthesize shouldShowFocus             = _shouldShowFocus;
@synthesize editable                    = _editable;
@synthesize selectable                  = _selectable;

#pragma mark - Lifecycle

- (id)initWithFrame:(NSRect)frame
{
    if (([super initWithFrame:frame])) {
		self.frame             = frame; // Recalculate frame

		self.hasHoverCursor    = YES;
		self.backgroundColor   = [NSColor whiteColor];
		self.drawsBackground   = YES;
		self.drawsBorder       = YES;
		self.secure            = YES;
		self.shouldClipContent = YES;
		self.shouldShowFocus   = YES;
		self.string            = @"";
		self.placeholderString = @"E-mail";
		self.editable          = YES;
		self.selectable        = YES;
    }
    
    return self;
}

- (void)dealloc
{
	[self endEditing];
	[self discardCursorRects];
	
	self._currentClippingPath        = nil;
	self.attributedString            = nil;
	self.attributedPlaceholderString = nil;
	self.backgroundColor             = nil;
	
	[super dealloc];
}

- (void)resetCursorRects
{
	[self discardCursorRects];
	
	if (self.hasHoverCursor) {
		NSCursor *hoverCursor = self.hoverCursor;
	
		[hoverCursor setOnMouseEntered:YES];
		[hoverCursor setOnMouseExited:NO];
		[self addCursorRect:[self textRectForAttributedString:(self.attributedString.length == 0) ? self.attributedPlaceholderString: self.attributedString] cursor:self.hoverCursor];
	}
	
}

#pragma mark - Drawing

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
	
	[NSGraphicsContext saveGraphicsState];
	
	if (self.shouldClipContent) {
		self._currentClippingPath = self.clippingPath;
		
		if (self._currentClippingPath)
			[self._currentClippingPath addClip];
	
	}
	
	if (self.drawsBackground)
		[self drawBackgroundWithRect:dirtyRect];
	if (self.drawsBorder)
		[self drawFrameWithRect:dirtyRect];
	
	[self drawInteriorWithRect:dirtyRect];
	
	if (!self._currentFieldEditor) {
		NSAttributedString *currentString = (self.attributedString.length > 0) ? self.attributedString : self.attributedPlaceholderString;
		
		if (self.isSecure && (self.attributedString.length > 0)) {
			NSString *bullets = [@"" stringByPaddingToLength:currentString.length 
												  withString:[NSString stringWithUTF8String:"•"] 
											 startingAtIndex:0];
			NSMutableAttributedString *mar = [currentString.mutableCopy autorelease];
			[mar replaceCharactersInRange:NSMakeRange(0, mar.length) withString:bullets];
			currentString = mar;
		}
		
		[self drawTextWithRect:dirtyRect andString:currentString];
	}
	
	if (self._currentFieldEditor && self.shouldShowFocus) {
		NSSetFocusRingStyle(NSFocusRingOnly);
		[self._currentClippingPath ? self._currentClippingPath : [NSBezierPath bezierPathWithRect:self.bounds] fill];
	}
	
	// Release it when done
	self._currentClippingPath = nil;
	
	[NSGraphicsContext restoreGraphicsState];
}

- (void)drawBackgroundWithRect:(NSRect)rect
{
	[self.backgroundColor drawSwatchInRect:rect];
}

- (void)drawFrameWithRect:(NSRect)rect
{
	[[NSColor grayColor] setStroke];
	[self._currentClippingPath setLineWidth:2.0];
	[self._currentClippingPath stroke];
}

- (void)drawInteriorWithRect:(NSRect)rect
{
	// Do nothing by default
}

- (void)drawTextWithRect:(NSRect)rect andString:(NSAttributedString *)string
{
	[string drawInRect:[self textRectForAttributedString:string]];
}

- (NSRect)textRectForAttributedString:(NSAttributedString *)string
{
	return NSMakeRect(4.0, round(NSMidY(self.bounds) - 17.0 / 2), self.bounds.size.width - 8.0, 17.0);
}

- (NSBezierPath *)clippingPath
{
	return [NSBezierPath bezierPathWithRoundedRect:self.bounds xRadius:4.0 yRadius:4.0];
}

- (NSDictionary *)stringAttributes
{
	NSMutableParagraphStyle *style = [[[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
	style.lineBreakMode = NSLineBreakByTruncatingTail;
	
	return [NSDictionary dictionaryWithObjectsAndKeys:
			[NSColor controlTextColor], NSForegroundColorAttributeName,
			[NSFont systemFontOfSize:13.0f], NSFontAttributeName, 
			style, NSParagraphStyleAttributeName, nil];
}

- (NSDictionary *)placeholderStringAttributes
{
	NSMutableParagraphStyle *style = [[[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
	style.lineBreakMode = NSLineBreakByTruncatingTail;
	
	return [NSDictionary dictionaryWithObjectsAndKeys:
			[NSColor grayColor], NSForegroundColorAttributeName,
			[NSFont systemFontOfSize:13.0f], NSFontAttributeName, 
			style, NSParagraphStyleAttributeName, nil];
}

- (NSCursor *)hoverCursor
{
	return [NSCursor IBeamCursor];
}

#pragma mark - Dynamic Properties

- (NSString *)string
{
	return self.attributedString.string;
}

- (void)setString:(NSString *)string
{
	[self willChangeValueForKey:@"string"];
	[self setAttributedString:[[[NSAttributedString alloc] initWithString:string attributes:self.stringAttributes] autorelease]];
	[self didChangeValueForKey:@"string"];
}

- (NSString *)placeholderString
{
	return self.attributedPlaceholderString.string;
}

- (void)setPlaceholderString:(NSString *)placeholderString
{
	[self willChangeValueForKey:@"placeholderString"];
	[self setAttributedPlaceholderString:[[[NSAttributedString alloc] initWithString:placeholderString attributes:self.placeholderStringAttributes] autorelease]];
	[self didChangeValueForKey:@"placeholderString"];
}

- (NSBezierPath *)currentClippingPath
{
	return self._currentClippingPath;
}

#pragma mark - Mouse

- (void)beginEditing
{
	if (!self._currentFieldEditor)
		[self _currentFieldEditor];
}

- (void)endEditing
{
	if (self._currentFieldEditor) {
		self.string = self._currentFieldEditor.string;
		
		[self._currentClipView removeFromSuperview];
		self._currentClipView    = nil;
		self._currentFieldEditor = nil;
		
		[self.window makeFirstResponder:nil];
		[self setNeedsDisplay:YES];
	}
}

- (BOOL)acceptsFirstResponder
{
	return YES;
}

- (BOOL)becomeFirstResponder
{
	BOOL success = [super becomeFirstResponder];
	
	if (success && !self._currentFieldEditor)
		[self _configureFieldEditor];
	
	return success;
}

- (void)mouseDown:(NSEvent *)event
{
	if (!self._currentFieldEditor)
		[self _configureFieldEditor];
	
	[self._currentFieldEditor mouseDown:event]; // So you can just drag the selection right away
}

- (void)_configureFieldEditor
{
	NSTextView *fieldEditor = (NSTextView *)[self.window fieldEditor:YES
														   forObject:self];
	fieldEditor.drawsBackground = NO;	
	fieldEditor.fieldEditor = YES;
	fieldEditor.string      = self.string;

	NSRect fieldFrame   = [self textRectForAttributedString:self.attributedString];
	NSSize layoutSize   = fieldEditor.maxSize;
	
	layoutSize.width    = FLT_MAX;
	layoutSize.height   = fieldFrame.size.height;
	
	fieldEditor.maxSize = layoutSize;
	fieldEditor.minSize = NSMakeSize(0.0, fieldFrame.size.height);
	
	fieldEditor.autoresizingMask = NSViewHeightSizable;
	fieldEditor.horizontallyResizable = YES;
	fieldEditor.verticallyResizable   = NO;
	
	fieldEditor.textContainer.heightTracksTextView = YES;
	fieldEditor.textContainer.widthTracksTextView  = NO;
	fieldEditor.textContainer.containerSize        = layoutSize;
	fieldEditor.textContainerInset                 = NSMakeSize(0, 1);
	fieldEditor.textContainer.lineFragmentPadding  = 0.0;
	fieldEditor.typingAttributes                   = self.stringAttributes;
	
	fieldEditor.delegate         = self;
	fieldEditor.editable         = self.isEditable;
	fieldEditor.selectable       = self.isSelectable;
	fieldEditor.usesRuler        = NO;
	fieldEditor.usesInspectorBar = NO;
	
	self._currentFieldEditor = fieldEditor;
	
	self._currentClipView = [[[NSClipView alloc] initWithFrame:fieldFrame] autorelease];
	self._currentClipView.drawsBackground = NO;
	self._currentClipView.documentView    = fieldEditor;
	
	fieldEditor.selectedRange             = NSMakeRange(0, fieldEditor.string.length); // select the whole thing
	[fieldEditor invalidateTextContainerOrigin];
	
	if (self.isSecure)
		fieldEditor.layoutManager.glyphGenerator = [[[ZKSecureGlyphGenerator alloc] init] autorelease]; // Fuck yeah
	
	[self addSubview:self._currentClipView];
	[self.window makeFirstResponder:fieldEditor];
	
	[self setNeedsDisplay:YES];
}

#pragma mark - Layout

- (void)setFrame:(NSRect)frame
{
	CGFloat minH = self.minimumHeight;
	CGFloat minW = self.minimumWidth;
	CGFloat maxH = self.maximumHeight;
	CGFloat maxW = self.maximumWidth;
	
	NSAssert(maxH >= minH || maxH <= 0, @"Maximum height of ZKTextField must be greater than the minimum!");
	NSAssert(maxW >= minW || maxW <= 0, @"Maximum width of ZKTextField must be greater than the minimum!");
	
	if (frame.size.height < minH && minH > 0)
		frame.size.height = minH;
	
	else if (frame.size.height > maxH && maxH > 0)
		frame.size.height = maxH;
	
	if (frame.size.width < minW && minW > 0)
		frame.size.width = minW;
	
	else if (frame.size.width > maxW && maxW > 0)
		frame.size.width = maxW;
	
	if (self._currentClipView) { // Built in autoresizing sucks so much.
		NSRect fieldFrame = [self textRectForAttributedString:self.attributedString];
		[self._currentClipView setFrame:fieldFrame];
	}
	
	[super setFrame:frame];
}

- (CGFloat)minimumHeight
{
	return 24.0;
}

- (CGFloat)minimumWidth
{
	return 60.0;
}

- (CGFloat)maximumHeight
{
	return 24.0;
}

- (CGFloat)maximumWidth
{
	return 0.0;
}

#pragma mark - NSTextViewDelegate

- (void)textDidChange:(NSNotification *)note
{	
	
}

- (void)textDidEndEditing:(NSNotification *)note
{	
	[self endEditing];
}

- (BOOL)textView:(NSTextView *)aTextView shouldChangeTextInRange:(NSRange)affectedCharRange replacementString:(NSString *)replacementString
{
	if ([replacementString isEqualToString:@"\n"])
		return NO;
	return YES;
}

@end
