//
//  TimingTest.m
//  Tableau
//
//  Created by Robert Murley on 4/13/05.
//  Copyright 2005 Apple Computer, Inc. All rights reserved.
//

#import "TimingTest.h"
#import "Kernel.h"
#import "KernelPane.h"
#import "MyTimes.h"

@implementation TimingTest

- (void) initWithParams: (NSBitmapImageRep *) theImageRep
					filter: (int) theFilter 
					dataType: (int) theDataType
					iterations: (int) theIterationCount
					paramList: (paramList *) theParams
					kernel: (Kernel *) theKernel
{
	imageRep = theImageRep;
	filter = theFilter;
	dataType = theDataType;
	iterationCount = theIterationCount;
	params = theParams;
	kernel = theKernel;
	srcImageRep = nil;
	dstImageRep = nil;
	displayImageRep = nil;
}


- (void) runTimingTest: (ImageController *) controller
{
	NSAutoreleasePool    *subpool = [[NSAutoreleasePool alloc] init];
	NSFileManager	*fileManager = [NSFileManager defaultManager];
	NSString		*path = [NSString stringWithCString: "/ImagesForTiming/"];
	NSArray			*fileNames = [fileManager directoryContentsAtPath: path];
	NSMutableData	*text = nil;
	NSMutableString	*pathName = [NSMutableString stringWithCapacity: 256];
	NSString		*outFileName = [NSString stringWithCString: "/TimingResults"];
	NSString		*vecState[] = { @"scalar - ", @"vector - " };
	NSString		*dataTypeName[] = { @"planar 8", @"planar F", @"ARGB 8888", @"ARGB FFFF" };
	NSString		*dataString;
	char			*sVecState[] = { "scalar", "vector" };
	char			tmpStr[256], *newline = "\n";

	int				set = filter >> 16;
	int				item = filter & 0xffff;
    vImage_Flags	flags = filterLists[set].list[item].flags;
	vImage_Buffer	srcImage[4], dstImage[4];
	TestFunc		function;
    uint64_t		startTime, endTime;
	double			bestTime, currentTime, clockLatency;
	double			time[2][4];
	int				i, j, file, vec;
	long			height, width, rowBytes;
	unsigned char	*data[5];
	
	imageController = controller;
	if (fileNames == nil)
		[self exit: subpool];
	
	text = [NSMutableData dataWithCapacity: 5];
	if (text == nil)
		[self exit: subpool];
	
	progressCount = 8 * iterationCount;
	
    if( params->leaveAlphaUnchanged == YES )
        flags |= kvImageLeaveAlphaUnchanged;
    
    clockLatency = 1e20;
    for( i = 0; i < 100; i++ )
    {
        startTime = MyGetTime();
        endTime = MyGetTime();
        currentTime = MySubtractTime( endTime, startTime );
        if( currentTime < clockLatency )
            clockLatency = currentTime;
    }
	
	for (file = 0; file < [fileNames count]; file++)
	{
		vImagePixelCount	imageSize;
		
		[imageController releaseImage];
		[pathName setString: path];
		[pathName appendString: [fileNames objectAtIndex: file]];
		[imageController readImage: pathName];
		imageRep = [imageController refImageRep];
		if (imageRep == nil)
			continue;
		
		// write file name and size
		[text appendBytes: newline length: strlen(newline)];
		[[fileNames objectAtIndex: file] getCString: tmpStr maxLength: 255 encoding: NSASCIIStringEncoding];
		[text appendBytes: tmpStr length: strlen(tmpStr)];
		imageSize = ([imageRep pixelsHigh] * [imageRep pixelsWide] * [imageRep samplesPerPixel] + 500) / 1000;
		dataString = [NSString stringWithFormat: @"\t%d KB", imageSize];
		[dataString getCString: tmpStr maxLength: 255 encoding: NSASCIIStringEncoding];
		[text appendBytes: tmpStr length: strlen(tmpStr)];
		[imageController startTest];
		
		// once for each data format
		for (tag = planar_8; tag <= ARGB_FFFF; tag++) {
			function = (&filterLists[set].list[item].function)[tag];
			[imageController setDataType: self];
			srcImageRep = [imageController formatImageDataForTest: imageRep dataType: tag];
			if (srcImageRep == nil)
				break;
			dstImageRep = [imageController setupResultImageRep: imageRep dataType: tag premultiplied: YES];
			if (dstImageRep == nil) {
				[imageController releaseImageRep: srcImageRep];
				break;
			}
			
			if (kernel) {
				kernel = [imageController kernel];
				params->kernel = [kernel data];
				params->kernel_height = [kernel height];
				params->kernel_width = [kernel width];
				params->divisor = [kernel divisor];
			}

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

			[imageController displayView: srcImageRep];
			params->firstTestChannel = 0;
			if (tag == planar_8 || tag == planar_F) {
				params->lastTestChannel = 4;
				if (params->leaveAlphaUnchanged)
					params->firstTestChannel = 1;
			} else
				params->lastTestChannel = 1;
			
			// do scalar timing first, then vector
			for (vec = 0; vec <= 1; vec++) {
				SetvImageVectorAvailable( vec );
				[imageController setTimingTestStatus: vecState[vec] dataType: dataTypeName[tag]];

				bestTime = 1e20;
				for(i = 0; i < iterationCount; i++)
				{
					vImage_Error	err;
					startTime = MyGetTime();
					for(j = params->firstTestChannel; j < params->lastTestChannel; j++)
					{
						params->colorChannel = j;
						err = (*function)( &srcImage[j], &dstImage[j], flags, params );
					}
					endTime = MyGetTime();
					currentTime = MySubtractTime( endTime, startTime );
					if( currentTime < bestTime )
						bestTime = currentTime;
					[imageController setProgress: ((double) (iterationCount * (2 * tag + vec) + i + 1) / (double) progressCount)];
				}
			
				bestTime -= clockLatency;
				time[vec][tag] = bestTime;
			}
				
			// copy over alpha channel if necessary
			if (params->firstTestChannel != 0 && [srcImageRep isPlanar])
				memcpy(dstImage[0].data, srcImage[0].data, srcImage[0].height * srcImage[0].rowBytes);

			[imageController displayView: dstImageRep];
			[imageController releaseImageRep: srcImageRep];
			if (displayImageRep)
				[imageController releaseImageRep: displayImageRep];
			displayImageRep = dstImageRep;
		}

		dataString = [NSString stringWithFormat: @"\n%s  %6.4f  %6.4f  %6.4f  %6.4f", sVecState[0], time[0][0], time[0][1], time[0][2], time[0][3]];
		[dataString getCString: tmpStr maxLength: 255 encoding: NSASCIIStringEncoding];
		[text appendBytes: tmpStr length: strlen(tmpStr)];
		dataString = [NSString stringWithFormat: @"\n%s  %6.4f  %6.4f  %6.4f  %6.4f", sVecState[1], time[1][0], time[1][1], time[1][2], time[1][3]];
		[dataString getCString: tmpStr maxLength: 255 encoding: NSASCIIStringEncoding];
		[text appendBytes: tmpStr length: strlen(tmpStr)];
		[text appendBytes: newline length: strlen(newline)];

		[imageController updateActiveImage: displayImageRep];
		displayImageRep = nil;
		[NSThread sleepUntilDate: [NSDate dateWithTimeIntervalSinceNow: .5]];	// allow progress bar to update
		[imageController finishTest];
	}
	
	[fileManager createFileAtPath: outFileName contents: text attributes: nil];
	
	[imageController setTimingTestStatus: nil dataType: dataTypeName[tag]];
	[NSThread sleepUntilDate: [NSDate dateWithTimeIntervalSinceNow: .5]];	// allow status to update
	[self exit: subpool];
}

-(NSInteger) tag 
{ 
	return tag + 1;				// current data format
}

- (void) exit: (NSAutoreleasePool *) subpool
{
	[subpool release];
	[NSThread exit];
}

@end
