/*
 *  FilterTest.h
 *  Tableau
 *
 *  Created by Robert Murley on 4/18/05.
 *  Copyright 2005 Apple Computer, Inc. All rights reserved.
 *
 */

#import <Cocoa/Cocoa.h>
#import "Filters.h"
#import "ImageController.h"

@interface FilterTest : NSObject
{
	NSAutoreleasePool *subpool;
	ImageController	*imageController;
	NSBitmapImageRep *imageRep, *srcImageRep, *dstImageRep;
	int				filter;
	paramList		*params;
	int				iterationCount;
	DataFormatType	srcDataType, dstDataType;
	Kernel			*kernel;
}

- (void) initWithParams: (NSBitmapImageRep *) theImageRep
					filter: (int) theFilter 
					dataType: (int) dataType
					iterations: (int) theIterationCount
					paramList: (paramList *) theParams
					kernel: (Kernel *) theKernel;
- (void) runFilterTest: (ImageController *) controller;
- (void) endFilterTest;

@end
