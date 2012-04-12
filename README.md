# Introduction
```ZKTextField``` is a simple replacement for NSTextField that offers a very much higher degree of customization ability. It does not use any cells and delegates all most of its functions out to different methods so that subclasses can easily override them and change a function. Finally no more of that -editWithFrame:… or -selectWithFrame:… nonsense!

## How to use it

Simply subclass ```ZKTextField``` and implement enough methods to customize your text field as you see fit. Example

	@implementation ZKAccountTextField
	- (id)initWithFrame:(NSRect)frame
	{
		if ((self = [super initWithFrame:frame])) {
			self.backgroundColor = [NSColor whiteColor];
			self.shouldShowFocus = NO;
		}
	return self;
	}
	
	- (void)drawFrameWithRect:(NSRect)rect
	{
		// 2px border
		[kEQAccountTextFieldCellNormalColor set];
		[self.currentClippingPath setLineWidth:2.0 * 2.0];
		[self.currentClippingPath stroke];
	}

	- (NSPoint)textOffsetForHeight:(CGFloat)textHeight
	{
		// center vertically
		return NSMakePoint(12.0, round(NSMidY(self.bounds) - textHeight / 2));
	}

	- (CGFloat)textWidth
	{
		// the size of our field minus the margin on both size
		return self.bounds.size.width - 12 * 2;
	}

	- (NSDictionary *)stringAttributes
	{
		NSMutableDictionary *origAttrs = [[super stringAttributes].mutableCopy autorelease];
		[origAttrs setObject:[NSFont fontWithName:@"HelveticaNeue-Medium" size:12.0] forKey:NSFontAttributeName];
		[origAttrs setObject:[NSColor colorWithDeviceRed:0.5086 green:0.5047 blue:0.520 alpha:1.000] forKey:NSForegroundColorAttributeName];
		return origAttrs;
	}

	- (NSDictionary *)placeholderStringAttributes
	{
		return self.stringAttributes;
	}

	- (NSDictionary *)selectedStringAttributes
	{
		return [NSDictionary dictionaryWithObjectsAndKeys:
				[NSColor whiteColor], NSForegroundColorAttributeName,
				[[NSColor colorWithDeviceRed:0.5086 green:0.5047 blue:0.520 alpha:1.000] colorWithAlphaComponent:0.8], NSBackgroundColorAttributeName, nil];
	}

	- (NSColor *)insertionPointColor
	{
		return [NSColor colorWithDeviceRed:0.5086 green:0.5047 blue:0.520 alpha:1.000];
	}

	- (CGFloat)minimumWidth
	{
		return 269.0;
	}

	- (CGFloat)minimumHeight
	{
		return 39.0;
	}

	- (CGFloat)maximumWidth
	{
		return self.minimumWidth;
	}

	- (CGFloat)maximumHeight 
	{
		return self.minimumHeight;
	}

	@end
	
That will get you a text field with a white background, customized insertion point, a gray selection background, a 2px gray border radius that doesn't show focus. It looks a bit like this:

![Preview](http://cl.ly/FmZP/Screen%20Shot%202012-04-12%20at%2012.45.19%20AM.png)

[If you can't see it](http://cl.ly/FmZP)

## Functionality

You are probably reading this asking yourself, "Well, that's awesome! What's the catch? How does it work?" Good question! There is a catch!

`ZKTextField` lacks some functionality that NSTextField has such as multiline wrapping. At this moment `ZKTextField` only supports "single line mode" or horizontal scrolling. For most, this won't be a problem; for others, sorry.

In addition to no multi-line mode, `ZKTextField` forces the height of your text to be the exact line height needed for it. Why? Because it is hard to line up the text editor and the view text.


###Feel free to fork this repository and fix all the problems that I've caused. No really, please please do it.

## ZKTextField is licensed under MIT.
Here is some legal jargon:

	// ZKTextField
	//
	// Copyright (C) 2012 by Alex Zielenski.
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