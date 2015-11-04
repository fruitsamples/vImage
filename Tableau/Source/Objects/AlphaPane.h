//
//  AlphaPane.h
//  Tableau
//
//	Written by Robert Murley Sep 2003.
//  Copyright (c) 2003 Apple Computer, Inc. All rights reserved.
//


#import <Cocoa/Cocoa.h>
#import "Filters.h"

enum {
	unpremultipliedAlphaBlend,
	premultipliedAlphaBlend,
	premultipliedConstAlphaBlend,
	premultiply,
	unpremultiply,
	unpremultipliedToPremultiplied,
	clipToAlpha
};

@class ImageController;
@class ViewController;

@interface AlphaPane : NSWindow
{
    IBOutlet NSButton *okButton;
    IBOutlet NSSlider *transparencySliderTop;
    IBOutlet NSSlider *transparencySliderBottom;
    IBOutlet NSTextField *valueDisplayTop;
    IBOutlet NSTextField *valueDisplayBottom;
	IBOutlet NSTextField *valueTitleTop;
	IBOutlet NSTextField *valueTitleBottom;
	IBOutlet NSPopUpButton *imageMenu;
    IBOutlet ImageController *imageController;

	NSBitmapImageRep *imageRep, *topImageRep, *srcTopImageRep, *bottomImageRep, *srcBottomImageRep, *dstImageRep;
    int         testChannelCount;
    int         iterationCount;
    int         dataType;
    int			height;
    int			width;
	int			planes;
	BOOL		isPremultiplied;
	int			set, item;
	float		lastSliderValueTop, lastSliderValueBottom;
	vImage_Flags flags;
    ViewController  *viewController;
    vImage_Buffer   srcTop[4], top[4], srcBottom[4], bottom[4], dest[4];
}

-(void)initWithParams: (NSBitmapImageRep *) theImageRep
                filter: (int) filter
				dataType: (int) theDataType
                iterations: (int) iterations;
- (void) setupTestBuffers;
- (void) setupImageMenu;
- (IBAction) handleImageMenu: (id) sender;
- (IBAction) doSlider: (id) sender;
- (IBAction) doDone: (id) sender;

@end
