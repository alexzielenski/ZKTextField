//
// ZKTextField.h
// ZKTextField
//
// Created by Alex Zielenski on 4/11/12.
// Copyright (c) 2012 Alex Zielenski. All rights reserved.
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

#import <Cocoa/Cocoa.h>

@interface ZKTextField : NSView <NSCoding>
@property (nonatomic, assign) id target;
@property (nonatomic, assign) SEL action;

@property (nonatomic, copy) NSAttributedString *attributedString;
@property (nonatomic, copy) NSString *string; // Just gets the textAttributes and converts it to an attributed string

@property (nonatomic, copy) NSAttributedString *attributedPlaceholderString;
@property (nonatomic, copy) NSString *placeholderString;              // String to use as a placeholder in the absent of actual content

@property (nonatomic, retain) NSDictionary *stringAttributes;
@property (nonatomic, retain) NSDictionary *placeholderStringAttributes;
@property (nonatomic, retain) NSDictionary *selectedStringAttributes;

@property (nonatomic, retain) NSColor *backgroundColor;               // A background color to draw
@property (nonatomic, assign) BOOL drawsBackground;                   // Flag indicating if -drawBackgroundWithRect: is called
@property (nonatomic, assign) BOOL drawsBorder;                       // Flag indicating if -drawFrameWithRect: is called
@property (nonatomic, assign) BOOL hasHoverCursor;                    // Denotes if there is an extra cursor when hovering over the text rectangle
@property (nonatomic, assign) BOOL shouldClipContent;                 // Denotes whether drawing should be clipped by the -clippingPath                
@property (nonatomic, assign) BOOL shouldShowFocus;                   // Flag indicating whether or not a focus ring is drawn around the view while active
@property (nonatomic, assign, getter = isEditable) BOOL editable;     // Denotes if the field is editable
@property (nonatomic, assign, getter = isSelectable) BOOL selectable; // Denotes if the field is selectable
@property (nonatomic, assign, getter = isSecure) BOOL secure;         // Draw bullets instead of text
@property (nonatomic, assign, getter = isContinuous) BOOL continuous; // Action is sent every time text changes

// Initiates Editing of the Text Field
- (void)beginEditing;

// Ends editing of the Text field
- (void)endEditing;

// Draw a background color. Only called if -drawsBackground is set to YES.
// Default implementation draws the -backgroundColor attribute.
- (void)drawBackgroundWithRect:(NSRect)rect;

// Draw a frame. Only called if -drawsBorder is set to YES.
// Default implementation draws a draw line around the field;
- (void)drawFrameWithRect:(NSRect)rect;

// Draw some extra interior before the text.
// Default Implementation does nothing.
- (void)drawInteriorWithRect:(NSRect)rect;

// Given an attributed string to draw, draw it.
// Default implementation draws the string with the -textRectWithAttributedString: rectangle
- (void)drawTextWithRect:(NSRect)rect andString:(NSAttributedString *)string;

// A cursor to use on hover or the text rect.
// Default implementation uses IBeam. Return nil or [NSCursor arrowCursor] for normal.
- (NSCursor *)hoverCursor;

// Generate an offset for text
// Default implementation gets a vertically centered point with 4px padding
- (NSPoint)textOffsetForHeight:(CGFloat)textHeight;
- (CGFloat)textWidth;

// Generate a path to clip all drawing with.
// Default implementation returns the bounds of the receiver with a 4pt corner radius
// Does nothing if -shouldClipContent is NO
// Return nil for none.
- (NSBezierPath *)clippingPath;

// Color for the insertion point during editing or selection.
// Default implementation does nothing.
- (NSColor *)insertionPointColor;

// Used by the drawing methods to get the clipping path without potentially creating a new instance of it
- (NSBezierPath *)currentClippingPath;

// API for subclasses. Return 0 or below for no limit.
- (CGFloat)minimumHeight;
- (CGFloat)minimumWidth;
- (CGFloat)maximumHeight;
- (CGFloat)maximumWidth;

@end
