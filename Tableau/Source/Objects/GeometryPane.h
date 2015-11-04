//
//  GeometryPane.h
//  Tableau/Volumes/Files/iano/Tableau/Source/Objects/HSBPane.m:19: error: `saturationString' undeclared (first use in this function)

//
//  Created by Ian Ollmann on Fri Oct 04 2002.
//	Modified by Robert Murley Sep 2003.
//  Copyright (c) 2002 Apple Computer, Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
//#import <Accelerate/Accelerate.h>
#import "Filters.h"
#import "ImageController.h"
#import "ParamsController.h"

@interface GeometryPane : NSWindow
{
    IBOutlet ImageController *imageController;
    IBOutlet NSButton *goButton;
    IBOutlet NSSlider *rotate;
    IBOutlet NSSlider *scale_X;
    IBOutlet NSSlider *scale_Y;
    IBOutlet NSSlider *shear_X;
    IBOutlet NSSlider *shear_Y;
    IBOutlet NSTableView *transformMatrix;
    IBOutlet NSSlider *translate_X;
    IBOutlet NSSlider *translate_Y;
    IBOutlet ParamsController *paramsController;
    
    vImage_AffineTransform	transform;
    TestFunc				function;
	NSBitmapImageRep		*imageRep, *srcImageRep, *dstImageRep;
	vImage_Buffer			src[4], dst[4];
	int		dataType;
    int		flags;
    int		iterationCount;
	int		lastIteration;
    int		height, width;
	int		first, last;
    BOOL	quitting;
    TransformInfo	info;
    paramList	*params;
}
- (IBAction)go:(id)sender;
- (IBAction)updateTransformMatrix:(id)sender; //Take the current geometry information and use it to render an image

//selector is for -(void)action:(TransformInfo*)info;
-(void)initWithParams: (NSBitmapImageRep *) theImageRep
                filter: (int) filter
				dataType: (int) theDataType
                iterations: (int) iterations
				params: (paramList *) theParams;
- (void) updateViewUsingNewGeometryKernel;

//Send the image to the screen
-(void)flushImage;

//functions for supporting the table view holding the matrix
-(int)numberOfRowsInTableView:(NSTableView *)aTableView;
-(id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex;
-(void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex;

@end
