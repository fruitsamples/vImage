/*
 *  FilterTest.m
 *  Tableau
 *
 *  Created by Robert Murley on 4/18/05.
 *  Copyright 2005 Apple Computer, Inc. All rights reserved.
 *
 */

#import "FilterTest.h"
#import "GeometryPane.h"
#import "HSBPane.h"
#import "AlphaPane.h"
#import "Kernel.h"
#import "MyTimes.h"

@implementation FilterTest

- (void) initWithParams: (NSBitmapImageRep *) theImageRep
					filter: (int) theFilter 
					dataType: (int) dataType
					iterations: (int) theIterationCount
					paramList: (paramList *) theParams
					kernel: (Kernel *) theKernel
{
	imageRep = theImageRep;
	filter = theFilter;
	srcDataType = dstDataType = dataType;
	iterationCount = theIterationCount;
	params = theParams;
	kernel = theKernel;
	srcImageRep = nil;
	dstImageRep = nil;
}

- (void) runFilterTest: (ImageController *) controller
{
	imageController = controller;
	subpool = [[NSAutoreleasePool alloc] init];
	int				set = filter >> 16;
	int				item = filter & 0xffff;
    vImage_Flags	flags = filterLists[set].list[item].flags;
	TestFunc		function = (&filterLists[set].list[item].function)[srcDataType];
	unsigned char	*data[5];
	vImage_Buffer	srcImage[4], dstImage[4];
	long			height, width, rowBytes;
    uint64_t		startTime, endTime;
	double			bestTime = 1e20, currentTime, clockLatency;
	int				i, j;

	if (kernel) {
		params->kernel = [kernel data];
		params->kernel_height = [kernel height];
		params->kernel_width = [kernel width];
		params->divisor = [kernel divisor];
	}
	
    if( params->leaveAlphaUnchanged == YES )
        flags |= kvImageLeaveAlphaUnchanged;
    
	if (flags & kConversionFlags) {
		if (flags & kDestDataTypePlanar8)
			dstDataType = planar_8;
		else if (flags & kDestDataTypePlanarF)
			dstDataType = planar_F;
		else if (flags & kDestDataTypeARGB8888)
			dstDataType = ARGB_8888;
		else if (flags & kDestDataTypeARGBFFFF)
			dstDataType = ARGB_FFFF;

		params->firstTestChannel = 0;
		params->lastTestChannel = 1;
	}
	
	srcImageRep = [imageController formatImageDataForTest: imageRep dataType: srcDataType];
	if (srcImageRep == nil)
		[self endFilterTest];
//	[srcImageRep retain];

	dstImageRep = [imageController setupResultImageRep: imageRep dataType: dstDataType premultiplied: TRUE];
	if (dstImageRep == nil)
		[self endFilterTest];
	[dstImageRep retain];
	
	// set up source and destination vImage_Buffers
	[srcImageRep getBitmapDataPlanes: data];
	height = [srcImageRep pixelsHigh];
	width = [srcImageRep pixelsWide];
	rowBytes = [srcImageRep bytesPerRow];
	for (i = 0; i < 4; i++) {
		srcImage[i].data = data[i];
		srcImage[i].height = height;
		srcImage[i].width = width;
		srcImage[i].rowBytes = rowBytes;
	}
	
	[dstImageRep getBitmapDataPlanes: data];
	height = [dstImageRep pixelsHigh];
	width = [dstImageRep pixelsWide];
	rowBytes = [dstImageRep bytesPerRow];
	for (i = 0; i < 4; i++) {
		dstImage[i].data = data[i];
		dstImage[i].height = height;
		dstImage[i].width = width;
		dstImage[i].rowBytes = rowBytes;
	}

	params->alpha = &srcImage[0];
	flags &= 0xffff;
	
    clockLatency = 1e20;
    for( i = 0; i < 100; i++ )
    {
        startTime = MyGetTime();
        endTime = MyGetTime();
        currentTime = MySubtractTime( endTime, startTime );
        if( currentTime < clockLatency )
            clockLatency = currentTime;
    }

	if (iterationCount > 1)
		[imageController startTest];
	
	for(i = 0; i < iterationCount; i++)
	{
		startTime = MyGetTime();
		for(j = params->firstTestChannel; j < params->lastTestChannel; j++)
		{
			params->colorChannel = j;
			(*function)( &srcImage[j], &dstImage[j], flags, params );
		}
		endTime = MyGetTime();
		currentTime = MySubtractTime( endTime, startTime );
		if( currentTime < bestTime )
			bestTime = currentTime;
		if (iterationCount > 1)
			[imageController setProgress: ((double) (i+1) / (double) iterationCount)];
	}

	// show the time
	[imageController showTime: (bestTime - clockLatency)];
	
	// copy over alpha channel if necessary, then update image
	if (params->firstTestChannel != 0 && [srcImageRep isPlanar])
		memcpy(dstImage[0].data, srcImage[0].data, srcImage[0].height * srcImage[0].rowBytes);
	
	// if result is FP, convert to integer so AppKit will display it
//	if ([dstImageRep bitmapFormat] & NSFloatingPointSamplesBitmapFormat)
//	{
//		NSBitmapImageRep *dstRep = [imageController formatImageDataForTest: dstImageRep dataType: ARGB_8888];
//		[imageController displayView:dstRep];
//	} else
		[imageController displayView: dstImageRep];
		
	[imageController updateActiveImage: dstImageRep];
	[srcImageRep release];
	[NSThread sleepUntilDate: [NSDate dateWithTimeIntervalSinceNow: 0.5]];	// allow progress bar to update
	[imageController finishTest];
	[self endFilterTest];
}

- (void) endFilterTest
{
	[subpool release];
	[NSThread exit];
}

@end