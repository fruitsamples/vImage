//
//  TransformPane.m
//  Tableau
//
//  Created by Robert Murley on 6/28/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "TransformPane.h"
#import "ImageController.h"
#import "MyTimes.h"


@implementation TransformPane

-(void)initWithParams: (NSBitmapImageRep *) imageRep
                filter: (int) filter
				dataType: (int) theDataType
                iterations: (int) iterations
				params: (paramList *) theParams
{
	int				i;
	unsigned char *data[5];
	
	set = filter >> 16;
	item = filter & 0xffff;
    flags = filterLists[set].list[item].flags;
	iterationCount = iterations;
    params = theParams;
	first = params->firstTestChannel;
	last = params->lastTestChannel;
    
    height = [imageController height];
    width = [imageController width];
	lastIteration = FALSE;
	
	if (item == kGammaPlanar8toPlanarF)
		srcDataType = planar_8;
	else
		srcDataType = planar_F;
	
	if (item == kGammaPlanarFtoPlanar8)
		dstDataType = planar_8;
	else
		dstDataType = planar_F;
    
	// set up the source and destination vImage_Buffers
	srcImageRep = [imageController formatImageDataForTest: imageRep dataType: srcDataType];
	if (srcImageRep == nil)
		return;
	dstImageRep = [imageController setupResultImageRep: imageRep dataType: dstDataType premultiplied: TRUE];
	if (dstImageRep == nil) {
		[imageController releaseImageRep: srcImageRep];
		return;
	}
	
	[srcImageRep getBitmapDataPlanes: data];
	for (i = 0; i < last; i++) {
		src[i].data = data[i];
		src[i].height = height;
		src[i].width = width;
		src[i].rowBytes = [srcImageRep bytesPerRow];
	}
	[dstImageRep getBitmapDataPlanes: data];
	for (i = 0; i < last; i++) {
		dst[i].height = height;
		dst[i].width = width;
		dst[i].rowBytes = [dstImageRep bytesPerRow];
		dst[i].data = data[i];
	}
	
    //Make sure we don't go away when closed
    [ self setReleasedWhenClosed: NO ];
    [ self makeKeyAndOrderFront: nil ];
}

- (IBAction) doSlider:(id)sender
{
	NSString *value = [NSString stringWithFormat: @"%4.2f", [exponentSlider floatValue]];
	[ valueDisplay setStringValue: value ];
	[self doGammaFunction];
}

- (IBAction) doGammaType: (id)sender
{
	[self doGammaFunction];
}

- (void) doGammaFunction
{
    float	sliderValue = [exponentSlider floatValue];
	int		gammaType = [gammaMenu indexOfSelectedItem];
	GammaFunction	gamma;
    int		i, j;
    uint64_t	startTime, endTime;
    double      currentTime, bestTime;
	vImage_Error err;
    
	gamma = vImageCreateGammaFunction(sliderValue, gammaType, kvImageNoFlags);
					
    bestTime = 1e20;
	currentTime = 0.0;

	for (i = 0; i < iterationCount; i++) {
		startTime = MyGetTime();

		for (j = first; j < last; j++)
			switch (item)
			{
				case kGammaPlanar8toPlanarF:
					err = vImageGamma_Planar8toPlanarF(&src[j], &dst[j], gamma, kvImageNoFlags);
					break;
				
				case kGammaPlanarFtoPlanar8:
					err = vImageGamma_PlanarFtoPlanar8(&src[j], &dst[j], gamma, kvImageNoFlags);
					break;
					
				case kGammaPlanarF:
					err = vImageGamma_PlanarF(&src[j], &dst[j], gamma, kvImageNoFlags);
					break;

				default:
					break;
			}
		
		endTime = MyGetTime();
		currentTime = MySubtractTime( endTime, startTime );
		if( currentTime < bestTime )
			bestTime = currentTime;

	}
	
	vImageDestroyGammaFunction(gamma);

	// copy over alpha channel if necessary, then update image
	if (params->firstTestChannel != 0 && [srcImageRep isPlanar]) {
		if (dstDataType == planar_8) {
			for (i = 0; i < height; i++) {
				float *srcAlpha = ADVANCE_PTR(src[0].data, i * src[0].rowBytes);
				unsigned char *dstAlpha = ADVANCE_PTR(dst[0].data, i * dst[0].rowBytes);
				
				for (j = 0; j < width; j++)
					dstAlpha[j] = (unsigned char) (srcAlpha[j] * 255.0);
			}
		} else if (srcDataType == planar_8) {
			for (i = 0; i < height; i++) {
				unsigned char *srcAlpha = ADVANCE_PTR(src[0].data, i * src[0].rowBytes);
				float *dstAlpha = ADVANCE_PTR(dst[0].data, i * dst[0].rowBytes);
				
				for (j = 0; j < width; j++)
					dstAlpha[j] = ((float) srcAlpha[j]) / 255.0;
			}
		} else {
			for (i = 0; i < height; i++) {
				float *srcAlpha = ADVANCE_PTR(src[0].data, i * src[0].rowBytes);
				float *dstAlpha = ADVANCE_PTR(dst[0].data, i * dst[0].rowBytes);
				
				for (j = 0; j < width; j++)
					dstAlpha[j] = srcAlpha[j];
			}
		}
	}
	
	// if result is FP, convert to integer so AppKit will display it
	if ([dstImageRep bitmapFormat] & NSFloatingPointSamplesBitmapFormat)
	{
		NSBitmapImageRep *dstRep = [imageController formatImageDataForTest: dstImageRep dataType: ARGB_8888];
		[imageController displayView:dstRep];
	} else
		[imageController displayView: dstImageRep];
		
	[imageController showTime: currentTime];
}


- (IBAction) doDone: (id) sender
{
	if (dstImageRep) {
		// if result is FP, convert to integer so AppKit will display it
		if ([dstImageRep bitmapFormat] & NSFloatingPointSamplesBitmapFormat)
		{
			NSBitmapImageRep *dstRep = [imageController formatImageDataForTest: dstImageRep dataType: ARGB_8888];
			[imageController releaseImageRep: dstImageRep];
			dstImageRep = dstRep;
		}
		[imageController updateActiveImage: dstImageRep];
	}
	if (srcImageRep)
		[imageController releaseImageRep: srcImageRep];
		
    [ imageController finishTest ];
    [ self orderOut: nil ];
}


@end
