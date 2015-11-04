//
//  ViewController.m
//  Tableau
//
//	Created by Robert Murley on 4 Jan 2005.
//	Copyright (c) 2005 Apple Computer, Inc. All rights reserved.
//

#import "ViewController.h"
#import "Filters.h"

@implementation ViewController

- (void) viewControllerCheck { return; }

- (id)init
{
    image = nil;
    imagePath = nil;
	refImageRep = nil;
    colorSpace = nil;
	imageInfo = nil;
	
    return self;
}

- (void) releaseImage
{
	if (image)
		[image release];
	image = nil;
	if (imagePath)
		[imagePath release];
	imagePath = nil;
	if (refImageRep)
		[refImageRep release];
	refImageRep = nil;
    if ( colorSpace )
        [colorSpace release];
	colorSpace = nil;
	if (imageInfo)
		[imageInfo release];
	imageInfo = nil;
}

- (int) height { return height; }

- (int) width { return width; }

- (NSString *) imagePath { return imagePath; }

- (NSBitmapImageRep *) refImageRep { return refImageRep; }

- (BOOL) isInteger: (NSBitmapImageRep *) imageRep
{
	return ([imageRep bitmapFormat] & NSFloatingPointSamplesBitmapFormat) == 0;
}

- (int) imageRepType: (NSBitmapImageRep *) imageRep
{
	BOOL	isInteger = [self isInteger: imageRep];
	
	if ([imageRep isPlanar]) {
		if (isInteger)
			return planar_8;
		else
			return planar_F;
	} else {
		if (isInteger)
			return ARGB_8888;
		else
			return ARGB_FFFF;
	}
	return 0;
}

- (NSBitmapFormat) bitmapFormat { return bitmapFormat; }

- (NSImageView *) imageView  { return	imageView; }

- (void) findImage
{
    NSOpenPanel	*panel = [ NSOpenPanel openPanel ];
	NSString *path;
    
    [ panel setCanChooseFiles: YES ];
    [ panel setCanChooseDirectories: NO ];
    [ panel setResolvesAliases: YES ];
    [ panel setAllowsMultipleSelection: NO ];
    
    if (NSOKButton != [ panel runModalForTypes: [NSBitmapImageRep imageTypes] ])
        return;

	// release memory for previous image
	[self releaseImage];
	
	// get path and imagerep for new file
    path = [[ panel filenames ] objectAtIndex: 0];
	[self readImage: path];
}

-(void) readImage: (NSString *) path {
    NSBitmapImageRep *imageRep;
    char *type[4] = { "planar", "planar w/alpha", "interleaved", "interleaved w/alpha" };
	char *form[2] = { "integer", "floating point" };
	char space[255];

    imageRep = [NSBitmapImageRep imageRepWithContentsOfFile: path ];
    if ( !imageRep ) {
		NSLog(@"NSBitmapImageRep error for imageRepWithContentsOfFile.");
        return;
	}
	
	imagePath = path;
    [imagePath retain];
	
    height =  [imageRep pixelsHigh];
    width = [imageRep pixelsWide];
    channelCount = [imageRep samplesPerPixel];
    colorSpace = [imageRep colorSpaceName];
	[colorSpace retain];
    
    [colorSpace getCString: space maxLength: 255];
    int index = [imageRep hasAlpha];
    if ( ![imageRep isPlanar] )
        index += 2;
    
    imageInfo = [ NSString stringWithFormat: @"%i x %i (%i channels, %s, %s, %s)", 
					height,
					width,
					channelCount,
					type[index],
					form[[self isInteger: imageRep] == 0],
					space];
	[imageInfo retain];
    [infoDisplayField setStringValue: imageInfo];
	
	if ([self isInteger: imageRep]) {
		refImageRep = [self constructIntegerReferenceImage: imageRep];
		if (refImageRep == nil)
			return;
	} else {
		refImageRep = [self constructFloatingPointReferenceImage: imageRep];
		if (refImageRep == nil)
			return;
	}
	[refImageRep retain];
	
	[self displayView: refImageRep];
    [[imageView window] setTitleWithRepresentedFilename: imagePath];
    [[imageView window] makeKeyAndOrderFront: self];
}

- (NSBitmapImageRep *) constructIntegerReferenceImage: (NSBitmapImageRep *) imageRep
{
	unsigned char *data[5], *refData, *refPtr;
	unsigned char *alphaPtr, *dataPtr;
	int  pixelStep, dataStep;
	BOOL refImageHasAlpha = FALSE;
	NSBitmapFormat format = NSAlphaFirstBitmapFormat;
	int	 h, w, i, j;
	
	// get data buffers
	if (![self allocateImageBuffers: (void**) &refData planes: 1 size: 4 * height * width])
		return nil;
	[imageRep getBitmapDataPlanes: data];

	if ([imageRep isPlanar])
		pixelStep = 1;
	else
		pixelStep = channelCount;
	
	// set up alpha channel
	if (channelCount > 4)
		channelCount = 4;
	else if ([imageRep hasAlpha]) {
		// copy alpha from source
		channelCount--;			// set to number of data channels
		if ([imageRep bitmapFormat] & NSAlphaFirstBitmapFormat)
			alphaPtr = data[0];
		else if ([imageRep isPlanar])
			alphaPtr = data[channelCount];
		else
			alphaPtr = data[0] + channelCount;
		i = 0;
		for (h = 0; h < height; h++) {
			unsigned char *alphaSrc = alphaPtr + h * [imageRep bytesPerRow];
			for (w = 0; w < width; w++) {
				refData[i] = *alphaSrc;
				i += 4;
				alphaSrc += pixelStep;
			}
		}
		refImageHasAlpha = TRUE;
	} else if (channelCount < 4) {
		// set all values to 255
		for (i = 0; i < 4 * height * width; i += 4)
			refData[i] = 255;
		refImageHasAlpha = TRUE;
	}
	
	// copy over data channels
	dataStep = 0;
	if (bitmapFormat & NSAlphaFirstBitmapFormat)
		dataStep = 1;
	for (i = 0; i < channelCount; i++) {
		if ([imageRep isPlanar])
			dataPtr = data[dataStep + i];
		else
			dataPtr = data[0] + dataStep + i;
		refPtr = refData + i;
		if (refImageHasAlpha)
			refPtr++;
		for (h = 0; h < height; h++) {
			unsigned char *dataSrc = dataPtr + h * [imageRep bytesPerRow];
			for (w = 0; w < width; w++) {
				refPtr[0] = dataSrc[0];
				dataSrc += pixelStep;
				refPtr += 4;
			}
		}
	}

	// fill in any empty channels
	if (i == 1)
		for (j = 0; j < height * width; j++)	// black and white data - make all channels the same
			refData[4*j + 2] = refData[4*j + 3] = refData[4*j + 1];
	else if (i == 2)
		for (j = 0; j < height * width; j++)	// missing one channel - set to zero
			refData[4*j + 3] = 0;
	
	{
		vImage_Buffer	refImage = { refData, height, width, width * sizeof(Pixel_8888) };
		// do premultiplacaton if necessary
		if (bitmapFormat & NSAlphaNonpremultipliedBitmapFormat)
			vImagePremultiplyData_ARGB8888(&refImage, &refImage, kvImageNoFlags);
		else 
			[self validateIntegerImage: &refImage];		// check for invalid input
	}
	
	// construct image rep
 	refImageRep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes: &refData
						pixelsWide: width
						pixelsHigh: height
						bitsPerSample: 8
						samplesPerPixel: 4
						hasAlpha: refImageHasAlpha
						isPlanar: NO
						colorSpaceName: NSCalibratedRGBColorSpace
						bitmapFormat: format
						bytesPerRow: (width * sizeof(Pixel_8888))
						bitsPerPixel: 32 ];

	return refImageRep;
}

- (NSBitmapImageRep *) constructFloatingPointReferenceImage: (NSBitmapImageRep *) imageRep
{
	float *data[5], *refData, *refPtr;
	float *alphaPtr, *dataPtr;
	int  pixelStep, dataStep;
	BOOL refImageHasAlpha = FALSE;
	NSBitmapFormat format = NSAlphaFirstBitmapFormat | NSFloatingPointSamplesBitmapFormat;
	int	 h, w, i, j;
	
	// get data buffers
	if (![self allocateImageBuffers: (void**) &refData planes: 1 size: 4 * sizeof( float ) * height * width])
		return nil;
	[imageRep getBitmapDataPlanes: (unsigned char**) data];

	if ([imageRep isPlanar])
		pixelStep = 1;
	else
		pixelStep = channelCount;
	
	// set up alpha channel
	if (channelCount > 4)
		channelCount = 4;
	else if ([imageRep hasAlpha]) {
		// copy alpha from source
		channelCount--;			// set to number of data channels
		if ([imageRep bitmapFormat] & NSAlphaFirstBitmapFormat)
			alphaPtr = data[0];
		else if ([imageRep isPlanar])
			alphaPtr = data[channelCount];
		else
			alphaPtr = data[0] + channelCount;
		i = 0;
		for (h = 0; h < height; h++) {
			float *alphaSrc = alphaPtr + h * [imageRep bytesPerRow];
			for (w = 0; w < width; w++) {
				refData[i] = *alphaSrc;
				i += 4;
				alphaSrc += pixelStep;
			}
		}
		refImageHasAlpha = TRUE;
	} else if (channelCount < 4) {
		// set all values to 255
		for (i = 0; i < 4 * height * width; i += 4)
			refData[i] = 1.0f;
		refImageHasAlpha = TRUE;
	}
	
	// copy over data channels
	dataStep = 0;
	if (bitmapFormat & NSAlphaFirstBitmapFormat)
		dataStep = 1;
	for (i = 0; i < channelCount; i++) {
		if ([imageRep isPlanar])
			dataPtr = data[dataStep + i];
		else
			dataPtr = data[0] + dataStep + i;
		refPtr = refData + i;
		if (refImageHasAlpha)
			refPtr++;
		for (h = 0; h < height; h++) {
			float *dataSrc = (float*) ((char*) dataPtr + h * [imageRep bytesPerRow] );
			for (w = 0; w < width; w++) {
				refPtr[0] = dataSrc[0];
				dataSrc += pixelStep;
				refPtr += 4;
			}
		}
	}

	// fill in any empty channels
	if (i == 1)
		for (j = 0; j < height * width; j++)	// black and white data - make all channels the same
			refData[4*j + 2] = refData[4*j + 3] = refData[4*j + 1];
	else if (i == 2)
		for (j = 0; j < height * width; j++)	// missing one channel - set to zero
			refData[4*j + 3] = 0;
	
	{
		vImage_Buffer	refImage = { refData, height, width, width * sizeof(Pixel_FFFF) };
		// do premultiplacaton if necessary
		if (bitmapFormat & NSAlphaNonpremultipliedBitmapFormat)
			vImagePremultiplyData_ARGBFFFF(&refImage, &refImage, kvImageNoFlags);
		else 
			[self validateFloatingPointImage: &refImage];		// check for invalid input
	}
	
	// construct image rep
 	refImageRep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes: (unsigned char**) &refData
						pixelsWide: width
						pixelsHigh: height
						bitsPerSample: 32
						samplesPerPixel: 4
						hasAlpha: refImageHasAlpha
						isPlanar: NO
						colorSpaceName: NSCalibratedRGBColorSpace
						bitmapFormat: format
						bytesPerRow: (width * sizeof(Pixel_FFFF))
						bitsPerPixel: 128 ];

	return refImageRep;
}

- (IBAction)saveImage:(id)sender
{
	NSString *fileName = [[ NSString alloc] init ];
	NSString *fileType = [ NSString stringWithCString:"tiff" ];
    NSSavePanel	*panel = [ NSSavePanel savePanel ];
	NSData *tiffData;

	[panel setRequiredFileType:fileType];

    if (NSFileHandlingPanelOKButton != [ panel runModal ] )
        return;

	fileName = [panel filename];
	tiffData = [refImageRep TIFFRepresentation];
	if (![tiffData writeToFile:fileName atomically:YES])
		 NSBeep();
}

- (void) displayView: (NSBitmapImageRep *) imageRep
{
	unsigned char *data;

	if (image) {
		if (displayedImageRep)
			[image removeRepresentation: displayedImageRep];
		[image release];
	}
	
	data = [imageRep bitmapData];		// this is needed to insure that the image refreshes
	image = [[NSImage alloc] init];
	[image addRepresentation: imageRep];
	displayedImageRep = imageRep;	
	[imageView setImage: image];
	[imageView display];
}

- (NSBitmapImageRep *) formatImageDataForTest: (NSBitmapImageRep *) imageRep dataType: (int) type
{
	unsigned char	*data[5] = { nil, nil, nil, nil, nil };
	NSBitmapFormat	format = [imageRep bitmapFormat];
	vImage_Buffer	srcData[4];
    vImage_Buffer	srcImage[4];
	int				pixelSize[4] = { 1, 4, 4, 16 };
	int				pixelPlanes[4] = { 4, 4, 1, 1 };
	int				imageRepType, i, h, w, planes, bitsPerSample;
	
	[imageRep getBitmapDataPlanes: data];
	imageRepType = [self imageRepType: imageRep];
	
	// set up 'from' vImage_Buffers
	for (i = 0; i < pixelPlanes[imageRepType]; i++) {
		srcData[i].data = data[i];
		srcData[i].height = height;
		srcData[i].width  = width;
		srcData[i].rowBytes = [imageRep bytesPerRow];
	}
	
	// set up 'to' vImage_Buffers
	planes = pixelPlanes[type];
	if ([self allocateImageBuffers: (void**) data planes: planes size: (height * width * pixelSize[type])] == FALSE)
		return nil;

	for (i = 0; i < planes; i++) {
		srcImage[i].data = data[i];
		srcImage[i].height = height;
		srcImage[i].width  = width;
		srcImage[i].rowBytes = srcImage[i].width * pixelSize[type];
	}
	
	if (imageRepType == type) {
		for (i = 0; i < planes; i++)
			memcpy(srcImage[i].data, srcData[i].data, srcData[i].height * srcData[i].rowBytes);
	} else switch (imageRepType) {
		case planar_8:
			if (type == planar_F)
				for (i = 0; i < 4; i++)
					vImageConvert_Planar8toPlanarF(&srcData[i], &srcImage[i], 1.0, 0.0, kvImageNoFlags);
			else if (type == ARGB_8888)
				vImageConvert_Planar8toARGB8888(&srcData[0], &srcData[1], &srcData[2], &srcData[3], &srcImage[0], kvImageNoFlags);
			else for (h = 0; h < srcData[0].height; h++) {
				// planar_8 to ARGB_FFFF
				unsigned char *src0 = srcData[0].data + h * srcData[0].rowBytes;
				unsigned char *src1 = srcData[1].data + h * srcData[1].rowBytes;
				unsigned char *src2 = srcData[2].data + h * srcData[2].rowBytes;
				unsigned char *src3 = srcData[3].data + h * srcData[3].rowBytes;
				float *dst = srcImage[0].data + h * srcImage[0].rowBytes;
				for (w = 0; w < srcData[0].width; w++) {
					*dst++ = (float) *src0++ / 255.0;
					*dst++ = (float) *src1++ / 255.0;
					*dst++ = (float) *src2++ / 255.0;
					*dst++ = (float) *src3++ / 255.0;
				}
			}
			break;

		case planar_F:
			if (type == ARGB_FFFF)
				vImageConvert_PlanarFtoARGBFFFF(&srcData[0], &srcData[1], &srcData[2], &srcData[3], &srcImage[0], kvImageNoFlags);
			else if (type == planar_8)
				for (i = 0; i < 4; i++)
					vImageConvert_PlanarFtoPlanar8(&srcData[i], &srcImage[i], 1.0, 0.0, kvImageNoFlags);
			else for (h = 0; h < srcData[0].height; h++) {
				// planar_F tp ARGB_8888
				float *src0 = srcData[0].data + h * srcData[0].rowBytes;
				float *src1 = srcData[1].data + h * srcData[1].rowBytes;
				float *src2 = srcData[2].data + h * srcData[2].rowBytes;
				float *src3 = srcData[3].data + h * srcData[3].rowBytes;
				unsigned char *dst = srcImage[0].data + h * srcImage[0].rowBytes;
				for (w = 0; w < srcData[0].width; w++) {
					*dst++ = (unsigned char) (*src0++ * 255.0);
					*dst++ = (unsigned char) (*src1++ * 255.0);
					*dst++ = (unsigned char) (*src2++ * 255.0);
					*dst++ = (unsigned char) (*src3++ * 255.0);
				}
			}
			break;
		
		case ARGB_8888:
			if (type == planar_8)
				vImageConvert_ARGB8888toPlanar8(&srcData[0], &srcImage[0], &srcImage[1], &srcImage[2], &srcImage[3], kvImageNoFlags);
			else if (type == planar_F) {
				for (h = 0; h < srcData[0].height; h++) {
					// ARGB_8888 to planar_F
					unsigned char *src = srcData[0].data + h * srcData[0].rowBytes;
					float *dst0 = srcImage[0].data + h * srcImage[0].rowBytes;
					float *dst1 = srcImage[1].data + h * srcImage[1].rowBytes;
					float *dst2 = srcImage[2].data + h * srcImage[2].rowBytes;
					float *dst3 = srcImage[3].data + h * srcImage[3].rowBytes;
					for (w = 0; w < srcData[0].width; w++) {
						*dst0++ = (float) *src++ / 255.0;
						*dst1++ = (float) *src++ / 255.0;
						*dst2++ = (float) *src++ / 255.0;
						*dst3++ = (float) *src++ / 255.0;
					}
				}
			} else for (h = 0; h < srcData[0].height; h++) {
				// ARGB_8888 to ARGB_FFFF				
				unsigned char *src = srcData[0].data + h * srcData[0].rowBytes;
				float *dst = srcImage[0].data + h * srcImage[0].rowBytes;
				for (w = 0; w < 4 * width; w++)
					*dst++ = (float) *src++ / 255.0;
			}
			break;
		
		case ARGB_FFFF:
			if (type == planar_F)
				vImageConvert_ARGBFFFFtoPlanarF(&srcData[0], &srcImage[0], &srcImage[1], &srcImage[2], &srcImage[3], kvImageNoFlags);
			else if (type == planar_8) {
				for (h = 0; h < srcData[0].height; h++) {
					// ARGB_FFFF to planar_8
					float *src = srcData[0].data + h * srcData[0].rowBytes;
					unsigned char *dst0 = srcImage[0].data + h * srcImage[0].rowBytes;
					unsigned char *dst1 = srcImage[1].data + h * srcImage[1].rowBytes;
					unsigned char *dst2 = srcImage[2].data + h * srcImage[2].rowBytes;
					unsigned char *dst3 = srcImage[3].data + h * srcImage[3].rowBytes;
					for (w = 0; w < srcData[0].width; w++) {
						*dst0++ = (unsigned char) (*src++ * 255.0);
						*dst1++ = (unsigned char) (*src++ * 255.0);
						*dst2++ = (unsigned char) (*src++ * 255.0);
						*dst3++ = (unsigned char) (*src++ * 255.0);
					}
				}
			} else for (h = 0; h < srcData[0].height; h++) {
				// ARGB_FFFF to ARGB_8888
				float *src = srcData[0].data + h * srcData[0].rowBytes;
				unsigned char *dst = srcImage[0].data + h * srcImage[0].rowBytes;
				for (w = 0; w < 4 * srcData[0].width; w++)
					*dst++ = (unsigned char) (*src++ * 255.0);
			}
	}
	
	bitsPerSample = 8;
	format = NSAlphaFirstBitmapFormat;
	if (type == planar_F || type == ARGB_FFFF) {
		bitsPerSample = 32;
		format |= NSFloatingPointSamplesBitmapFormat;
	}
	
 	imageRep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes: data
						pixelsWide: width
						pixelsHigh: height
						bitsPerSample: bitsPerSample
						samplesPerPixel: 4
						hasAlpha: [imageRep hasAlpha]
						isPlanar: (type == planar_8 || type == planar_F)
						colorSpaceName: NSCalibratedRGBColorSpace
						bitmapFormat: format
						bytesPerRow: srcImage[0].rowBytes
						bitsPerPixel: 8 * pixelSize[type] ];
	
	if (imageRep)
		[imageRep retain];
	else for ( i = 0; i < pixelPlanes[type]; i++ )
		free(data[i]);
	
	return imageRep;
}

- (BOOL) allocateImageBuffers: (void **) data planes: (int) planes size: (size_t) size
{
	int		i, j;
	
	// allocate memory for image representation
	for (i = 0; i < planes; i++) {
		data[i] = malloc(size);
		if (data[i] == nil) {
			NSLog(@"Error allocating image buffers.");
			for (j = 0; j < i; j++)
				free(data[i]);
			return NO;
		}
	}
	
	return YES;
}
	
- (void) releaseImageRep: (NSBitmapImageRep *) imageRep
{
	unsigned char *data[5], i;
	
	[imageRep getBitmapDataPlanes: data];
	[imageRep release];

	for (i = 0; i < 5; i++)
		if (data[i])
			free(data[i]);
}

// check input image data for validity (must be in interleaved format)
- (BOOL) validateIntegerImage: (vImage_Buffer *) buffer
{
	long		h, w;
	
	for (h = 0; h < buffer->height; h++) {
		unsigned char *srcRow = buffer->data + h * buffer->rowBytes;
		for (w = 0; w < buffer->width; w++) {
			int alpha = srcRow[0];
			if ((255 * srcRow[1] / alpha > 255) || (255 * srcRow[2] / alpha > 255) || (255 * srcRow[3] / alpha > 255)) {
				NSLog(@"Invalid alpha data in image.");
				return FALSE;
			}
			srcRow += 4;
		}
	}
	return TRUE;
}

#ifndef MAX
    #define MAX( _a, _b )       ((_a) > (-b) ? (_a) : (_b ))
#endif
#ifndef MIN
    #define MIN( _a, _b )       ((_a) < (-b) ? (_a) : (_b ))
#endif

- (BOOL) validateFloatingPointImage: (vImage_Buffer *) buffer
{
	long		h, w;
    float       maxAlpha = -__builtin_inff();
    float       minAlpha = __builtin_inff();
    float       maxRed = -__builtin_inff();
    float       minRed = __builtin_inff();
    float       maxGreen = -__builtin_inff();
    float       minGreen = __builtin_inff();
    float       maxBlue = -__builtin_inff();
    float       minBlue = __builtin_inff();
	float       maxRedOverAlpha = -__builtin_inff();
	float       maxGreenOverAlpha = -__builtin_inff();
	float       maxBlueOverAlpha = -__builtin_inff();
    
	for (h = 0; h < buffer->height; h++) {
		float *srcRow = buffer->data + h * buffer->rowBytes;
		for (w = 0; w < buffer->width; w++) {
			float alpha = srcRow[0];
            float red = srcRow[1];
            float green = srcRow[2];
            float blue = srcRow[3];

            maxAlpha = MAX( maxAlpha, alpha );
            minAlpha = MIN( minAlpha, alpha );
            maxGreen = MAX( maxGreen, green );
            minGreen = MIN( minGreen, green );
            maxRed = MAX( maxRed, red );
            minRed = MIN( minRed, red );
            maxBlue = MAX( maxBlue, blue );
            minBlue = MIN( minBlue, blue );

            maxRedOverAlpha = MAX( maxRedOverAlpha, red / alpha );
            maxGreenOverAlpha = MAX( maxGreenOverAlpha, green / alpha );
            maxBlueOverAlpha = MAX( maxBlueOverAlpha, blue / alpha );


			srcRow += 4;
		}
	}
    
    NSLog( @"Max ARGB: { %10.14f, %10.14f, %10.14f, %10.14f }", maxAlpha, maxRed, maxGreen, maxBlue  );
    NSLog( @"Min ARGB: { %10.14f, %10.14f, %10.14f, %10.14f }", minAlpha, minRed, minGreen, minBlue  );
    NSLog( @"Max RGB/alpha: {        -, %10.14f, %10.14f, %10.14f", maxRedOverAlpha, maxGreenOverAlpha, maxBlueOverAlpha );
    
	return TRUE;
}

@end
