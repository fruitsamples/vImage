//
//  AlphaPane.m
//  Tableau
//
//	Written by Robert Murley Sep 2003.
//  Copyright (c) 2003 Apple Computer, Inc. All rights reserved.
//
#import "AlphaPane.h"
#import "MyTimes.h"
#import "ImageController.h"
#import "MorphologyFilters.h"

@implementation AlphaPane

-(void)initWithParams: (NSBitmapImageRep *) theImageRep
                filter: (int) filter
				dataType: (int) theDataType
                iterations: (int) iterations
{
	int				pixelPlanes[4] = { 4, 4, 1, 1 };

	imageRep = theImageRep;
	set = filter >> 16;
	item = filter & 0xffff;
	dataType = theDataType;
	iterationCount = iterations;
    flags = filterLists[set].list[item].flags;
	planes = pixelPlanes[dataType];
	isPremultiplied = (flags & kIsPremultiplied) != 0;
	
	srcTopImageRep = nil;
	topImageRep = nil;
	srcBottomImageRep = nil;
	bottomImageRep= nil;
	dstImageRep = nil;
	
	[self setupImageMenu];
	
	viewController = [imageController getViewController: [imageMenu indexOfSelectedItem]];

	[self setupTestBuffers];
}

- (void) setupTestBuffers {
	unsigned char	*srcData[5], *topData[5], *srcBottomData[5], *bottomData[5], *dstData[5];
    int				i;

	if (!viewController) {
		[self doDone: self];
		return;
	}
	
	if (srcTopImageRep == nil) {
		srcTopImageRep = [imageController formatImageDataForTest: imageRep dataType: dataType];
		if (srcTopImageRep == nil) {
			[self doDone: self];
			return;
		}
	}

	if (topImageRep == nil) {
		topImageRep = [imageController setupResultImageRep: imageRep dataType: dataType premultiplied: isPremultiplied];
		if (topImageRep == nil) {
			[self doDone: self];
			return;
		}
	}
	
	if (srcBottomImageRep)
		[imageController releaseImageRep: srcBottomImageRep];
	srcBottomImageRep = [viewController formatImageDataForTest: [viewController refImageRep] dataType: dataType];
	if (srcBottomImageRep == nil) {
		[self doDone: self];
		return;
	}
	
	if (bottomImageRep)
		[imageController releaseImageRep: bottomImageRep];
	bottomImageRep = [imageController setupResultImageRep: imageRep dataType: dataType premultiplied: isPremultiplied];
	if (bottomImageRep == nil) {
		[self doDone: self];
		return;
	}
	
	if (dstImageRep == nil) {
		dstImageRep = [imageController setupResultImageRep: imageRep dataType: dataType premultiplied: isPremultiplied];
		if (dstImageRep == nil) {
			[self doDone: self];
			return;
		}
	}

	// if image sizes are different, just use the area of intersection
    height = [imageController height];
    width = [imageController width];
    if ( height > [viewController height] )
        height = [viewController height];
    if ( width > [viewController width] )
        width = [viewController width];

    // get pointers to data buffers
	[srcTopImageRep getBitmapDataPlanes: srcData];
	[topImageRep getBitmapDataPlanes: topData];
	[srcBottomImageRep getBitmapDataPlanes: srcBottomData];
	[bottomImageRep getBitmapDataPlanes: bottomData];
	[dstImageRep getBitmapDataPlanes: dstData];

    // set up vImage_Buffers
    for ( i = 0; i < planes; i++ )
    {
		srcTop[i].data = srcData[i];
        srcTop[i].height = height;
        srcTop[i].width = width;
		srcTop[i].rowBytes = [srcTopImageRep bytesPerRow];
		top[i].data = topData[i];
        top[i].height = height;
        top[i].width = width;
		top[i].rowBytes = [topImageRep bytesPerRow];
		srcBottom[i].data = srcBottomData[i];
        srcBottom[i].height = height;
        srcBottom[i].width = width;
		srcBottom[i].rowBytes = [srcBottomImageRep bytesPerRow];
		bottom[i].data = bottomData[i];
        bottom[i].height = height;
        bottom[i].width = width;
		bottom[i].rowBytes = [topImageRep bytesPerRow];
		dest[i].data = dstData[i];
        dest[i].height = height;
        dest[i].width = width;
		dest[i].rowBytes = [dstImageRep bytesPerRow];
    }
	
	for ( i = planes - 1; i >= 0; i-- ) {
		switch (dataType) {
			case planar_8:
				CopyFilter(&srcTop[i], &top[i], flags, NULL);
				CopyFilter(&srcBottom[i], &bottom[i], flags, NULL);
				vImageUnpremultiplyData_Planar8(&srcTop[i], &srcTop[0], &srcTop[i], flags);							
				vImageUnpremultiplyData_Planar8(&srcBottom[i], &srcBottom[0], &srcBottom[i], flags);
				break;
			
			case planar_F:
				CopyFilterFP(&srcTop[i], &top[i], flags, NULL);
				CopyFilterFP(&srcBottom[i], &bottom[i], flags, NULL);
				vImageUnpremultiplyData_PlanarF(&srcTop[i], &srcTop[0], &srcTop[i], flags);							
				vImageUnpremultiplyData_PlanarF(&srcBottom[i], &srcBottom[0], &srcBottom[i], flags);
				break;

			case ARGB_8888:
				CopyFilter_ARGB(&srcTop[i], &top[i], flags, NULL);
				CopyFilter_ARGB(&srcBottom[i], &bottom[i], flags, NULL);
				vImageUnpremultiplyData_ARGB8888(&srcTop[i], &srcTop[i], flags);							
				vImageUnpremultiplyData_ARGB8888(&srcBottom[i], &srcBottom[i], flags);
				break;

			case ARGB_FFFF:
				CopyFilterFP_ARGB(&srcTop[i], &top[i], flags, NULL);
				CopyFilterFP_ARGB(&srcBottom[i], &bottom[i], flags, NULL);
				vImageUnpremultiplyData_ARGBFFFF(&srcTop[i], &srcTop[i], flags);							
				vImageUnpremultiplyData_ARGBFFFF(&srcBottom[i], &srcBottom[i], flags);
				break;
		}
	}

	lastSliderValueTop = 1.0 - [transparencySliderTop floatValue];
    lastSliderValueBottom = 1.0 - [transparencySliderBottom floatValue];
	
    [ self setReleasedWhenClosed: NO ];    
    [ self makeKeyAndOrderFront: nil ];
	
	return;
} 

- (void) setupImageMenu
{
	NSArray *fileNames;
	int		i;
	
	[imageMenu removeAllItems];
	fileNames = [imageController getViewNameList];
	if (fileNames == nil)
		return;
	
	for (i = 0; i < [fileNames count]; i++)
		[imageMenu addItemWithTitle: [fileNames objectAtIndex: i]];
	
	[transparencySliderBottom setHidden: item == premultipliedConstAlphaBlend];
	[valueDisplayBottom setHidden: item == premultipliedConstAlphaBlend];
	[valueTitleTop setHidden: item == premultipliedConstAlphaBlend];
	[valueTitleBottom setHidden: item == premultipliedConstAlphaBlend];
	
	[imageMenu setHidden: FALSE];
}

- (IBAction) handleImageMenu: (id) sender
{
	NSWindow	*window = [[imageController imageView] window];
	
	// put windows for top image and bottom image first and second
	[window orderFront: self];
	[window setViewsNeedDisplay: TRUE];
	viewController = [imageController getViewController: [imageMenu indexOfSelectedItem]];
	[[[viewController imageView] window] orderWindow: NSWindowBelow relativeTo: [window windowNumber]];
	
	// move second window adjacent to first
	NSRect	rect = [window frame];
	rect.origin.x += rect.size.width + 20;
//	[[[viewController imageView] window] setFrame: rect display: YES];
	
	[self setupTestBuffers];
}

- (IBAction) doSlider:(id)sender
{
    float	sliderValueTop = 1.0 - [transparencySliderTop floatValue];
    float	sliderValueBottom = 1.0 - [transparencySliderBottom floatValue];
    char	p = '%';
    int		valueTop, valueBottom;
    int		i, j;
    uint64_t	startTime, endTime;
    double      currentTime, bestTime;
    
	NSString *percentTop = [NSString stringWithFormat: @"%i%s", (int) ( 100 * sliderValueTop ), &p ];
	NSString *percentBottom = [NSString stringWithFormat: @"%i%s", (int) ( 100 * sliderValueBottom ), &p ];
    [ valueDisplayTop setStringValue: percentTop ];
    [ valueDisplayBottom setStringValue: percentBottom ];
    valueTop = (int) ( sliderValueTop * 255.0 );
    valueBottom = (int) ( sliderValueBottom * 255.0 );
    
    bestTime = 1e20;
	currentTime = 0.0;

	for (i = 0; i < iterationCount; i++) {
		startTime = MyGetTime();
		
		switch (item) {
		
			case premultipliedAlphaBlend:
			
				switch (dataType)
				{
					case planar_8:
						if (sliderValueTop != lastSliderValueTop) {
							vImageOverwriteChannelsWithScalar_Planar8((Pixel_8) valueTop, &top[0], flags);
							for (j = 1; j < 4; j++)
								vImagePremultiplyData_Planar8(&srcTop[j], &top[0], &top[j], flags);
							
						}
						if (sliderValueBottom != lastSliderValueBottom) {
							vImageOverwriteChannelsWithScalar_Planar8((Pixel_8) valueBottom, &bottom[0], flags);
							for (j = 1; j < 4; j++)
								vImagePremultiplyData_Planar8(&srcBottom[j], &bottom[0], &bottom[j], flags);
						}
						
						startTime = MyGetTime();
						for (j = 3; j >= 0; j--)
							vImagePremultipliedAlphaBlend_Planar8( &top[j], &top[0], &bottom[j], &dest[j], flags );
						endTime = MyGetTime();
						currentTime += MySubtractTime(endTime, startTime);
						break;
						
					case planar_F:
						if (sliderValueTop != lastSliderValueTop) {
							vImageOverwriteChannelsWithScalar_PlanarF((Pixel_F) sliderValueTop, &top[0], flags);
							for (j = 1; j < 4; j++)
								vImagePremultiplyData_PlanarF(&srcTop[j], &top[0], &top[j], flags);
							
						}
						if (sliderValueBottom != lastSliderValueBottom) {
							vImageOverwriteChannelsWithScalar_Planar8((Pixel_F) sliderValueBottom, &bottom[0], flags);
							for (j = 1; j < 4; j++)
								vImagePremultiplyData_PlanarF(&srcBottom[j], &bottom[0], &bottom[j], flags);
						}
						
						startTime = MyGetTime();
						for (j = 3; j >= 0; j--)
							vImagePremultipliedAlphaBlend_PlanarF( &top[j], &top[0], &bottom[j], &dest[j], flags );
						endTime = MyGetTime();
						currentTime += MySubtractTime(endTime, startTime);
						break;
					
					case ARGB_8888:
						if (sliderValueTop != lastSliderValueTop) {
							vImageOverwriteChannelsWithScalar_ARGB8888((Pixel_8) valueTop, &srcTop[0], &top[0], 0x08, flags);
							vImagePremultiplyData_ARGB8888(&top[0], &top[0], flags);
						}
						if (sliderValueBottom != lastSliderValueBottom) {
							vImageOverwriteChannelsWithScalar_ARGB8888((Pixel_8) valueBottom, &srcBottom[0], &bottom[0], 0x08, flags);
							vImagePremultiplyData_ARGB8888(&bottom[0], &bottom[0], flags);
						}
						
						startTime = MyGetTime();
						vImagePremultipliedAlphaBlend_ARGB8888(&top[0], &bottom[0], &dest[0], flags);
						endTime = MyGetTime();
						currentTime += MySubtractTime(endTime, startTime);
						break;
					
					case ARGB_FFFF:
						if (sliderValueTop != lastSliderValueTop) {
							vImageOverwriteChannelsWithScalar_ARGBFFFF((Pixel_F) sliderValueTop, &srcTop[0], &top[0], 0x08, flags);
							vImagePremultiplyData_ARGBFFFF(&top[0], &top[0], flags);
						}
						if (sliderValueBottom != lastSliderValueBottom) {
							vImageOverwriteChannelsWithScalar_ARGBFFFF((Pixel_F) sliderValueBottom, &srcBottom[0], &bottom[0], 0x08, flags);
							vImagePremultiplyData_ARGBFFFF(&bottom[0], &bottom[0], flags);
						}
						
						startTime = MyGetTime();
						vImagePremultipliedAlphaBlend_ARGBFFFF(&top[0], &bottom[0], &dest[0], flags);
						endTime = MyGetTime();
						currentTime += MySubtractTime(endTime, startTime);
						break;
				}
				break;

			case premultipliedConstAlphaBlend:
			
				switch (dataType)
				{
					case planar_8:
						for( j = 0; j < 4; j++ )
							vImagePremultipliedConstAlphaBlend_Planar8( &top[j], valueTop, &top[0], &bottom[j], &dest[j], flags );
						break;
					
					case planar_F:
						for( j = 0; j < 4; j++ )
							vImagePremultipliedConstAlphaBlend_PlanarF( &top[j], sliderValueTop, &top[0], &bottom[j], &dest[j], flags );
						break;
					
					case ARGB_8888:
						vImagePremultipliedConstAlphaBlend_ARGB8888( &top[0], valueTop, &bottom[0], &dest[0], flags );
						break;
					
					case ARGB_FFFF:
						vImagePremultipliedConstAlphaBlend_ARGBFFFF( &top[0], valueTop, &bottom[0], &dest[0], flags );
						break;
				}
				break;
				
			case unpremultipliedAlphaBlend:
			
				switch (dataType)
				{
					case planar_8:
						if (sliderValueTop != lastSliderValueTop)
							vImageOverwriteChannelsWithScalar_Planar8((Pixel_8) valueTop, &top[0], flags);
						if (sliderValueBottom != lastSliderValueBottom)
							vImageOverwriteChannelsWithScalar_Planar8((Pixel_8) valueBottom, &bottom[0], flags);
						
						vImagePremultipliedAlphaBlend_Planar8( &top[0], &top[0], &bottom[0], &dest[0], flags );
						for( j = 1; j < 4; j++ )
							vImageAlphaBlend_Planar8( &top[j], &top[0], &bottom[j], &bottom [0], &dest[0], &dest[j], flags );
						break;
						
					case planar_F:
						if (sliderValueTop != lastSliderValueTop)
							vImageOverwriteChannelsWithScalar_PlanarF((Pixel_F) sliderValueTop, &top[0], flags);
						if (sliderValueBottom != lastSliderValueBottom)
							vImageOverwriteChannelsWithScalar_PlanarF((Pixel_F) sliderValueBottom, &bottom[0], flags);

						vImagePremultipliedAlphaBlend_PlanarF( &top[0], &top[0], &bottom[0], &dest[0], flags );
						for( j = 1; j < 4; j++ )
							vImageAlphaBlend_PlanarF( &top[j], &top[0], &bottom[j], &bottom [0], &dest[0], &dest[j], flags );
						break;
					
					case ARGB_8888:
						if (sliderValueTop != lastSliderValueTop)
							vImageOverwriteChannelsWithScalar_ARGB8888((Pixel_8) valueTop, &srcTop[0], &top[0], 0x08, flags);
						if (sliderValueBottom != lastSliderValueBottom)
							vImageOverwriteChannelsWithScalar_ARGB8888((Pixel_8) valueBottom, &srcBottom[0], &bottom[0], 0x08, flags);
						
						vImageAlphaBlend_ARGB8888( &top[0], &bottom[0], &dest[0], flags );
						break;
					
					case ARGB_FFFF:
						if (sliderValueTop != lastSliderValueTop)
							vImageOverwriteChannelsWithScalar_ARGBFFFF((Pixel_F) sliderValueTop, &srcTop[0], &top[0], 0x08, flags);
						if (sliderValueBottom != lastSliderValueBottom)
							vImageOverwriteChannelsWithScalar_ARGBFFFF((Pixel_F) sliderValueBottom, &srcBottom[0], &bottom[0], 0x08, flags);

						vImageAlphaBlend_ARGBFFFF( &top[0], &bottom[0], &dest[0], flags );
						break;
				}
				break;
		}

		endTime = MyGetTime();
		currentTime = MySubtractTime( endTime, startTime );
		if( currentTime < bestTime )
			bestTime = currentTime;

		[imageController displayView: dstImageRep];
		[viewController displayView: bottomImageRep];
			
		lastSliderValueTop = sliderValueTop;
		lastSliderValueBottom = sliderValueBottom;
	}
	
	[imageController showTime: bestTime];
}

- (IBAction) doDone: (id) sender
{
	if (dstImageRep)
		[imageController updateActiveImage: dstImageRep];
	if (srcTopImageRep)
		[imageController releaseImageRep: srcTopImageRep];
	if (topImageRep)
		[imageController releaseImageRep: topImageRep];
	if (srcBottomImageRep)
		[imageController releaseImageRep: srcBottomImageRep];
	if (bottomImageRep)
		[imageController releaseImageRep: bottomImageRep];

    [ imageController finishTest ];
    [ self orderOut: nil ];
}

@end
