/*
 *  TimingTest.h
 *  Tableau
 *
 *  Created by Robert Murley on 4/8/05.
 *  Copyright 2005 Apple Computer, Inc. All rights reserved.
 *
 */

#import <Cocoa/Cocoa.h>
#import "Filters.h"
#import "ImageController.h"
#include "AvailabilityMacros.h"

#ifndef MAC_OS_X_VERSION_10_5
    typedef int NSInteger;
#endif

extern void SetvImageVectorAvailable( int whatIsAvailable );

/*
 *  Timing Test iteratively executes the selected filter on each file in the folder "/ImagesForTiming".
 *  It runs each of the four formats the number of times specified in the iteration count field.
 *  The results are written to the file "/TimingResults".
 */

@interface TimingTest : NSObject
{
	ImageController *imageController;
	NSBitmapImageRep *imageRep, *srcImageRep, *dstImageRep, *displayImageRep;
	int			filter;
	paramList	*params;
	int			iterationCount;
	int			dataType;
	Kernel		*kernel;
	int			tag;
	int			progressCount;
}

- (void) initWithParams: (NSBitmapImageRep *) theImageRep
					filter: (int) theFilter 
					dataType: (int) theDataType
					iterations: (int) theIterationCount
					paramList: (paramList *) theParams
					kernel: (Kernel *) theKernel;
- (void) runTimingTest: (ImageController *) controller;
- (NSInteger) tag;
- (void) exit: (NSAutoreleasePool *) subpool;

@end
