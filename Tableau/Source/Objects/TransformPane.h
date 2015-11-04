//
//  TransformPane.h
//  Tableau
//
//  Created by Robert Murley on 6/28/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Filters.h"

@class ImageController;

@interface TransformPane : NSWindow
{
    IBOutlet NSSlider *exponentSlider;
    IBOutlet NSTextField *valueDisplay;
	IBOutlet NSPopUpButton *gammaMenu;
    IBOutlet ImageController *imageController;

	NSBitmapImageRep *srcImageRep, *dstImageRep;
    int         testChannelCount;
    int         iterationCount;
    int			height;
    int			width;
	int			set, item;
	int			srcDataType, dstDataType;
	int			first, last, lastIteration;
	paramList	*params;
	vImage_Flags flags;
    vImage_Buffer   src[4], dst[4];
}

- (void) initWithParams: (NSBitmapImageRep *) imageRep
                filter: (int) filter
				dataType: (int) theDataType
                iterations: (int) iterations
				params: (paramList *) theParams;
- (IBAction) doSlider: (id) sender;
- (IBAction) doGammaType: (id)sender;
- (IBAction) doDone: (id) sender;
- (void) doGammaFunction;

@end
