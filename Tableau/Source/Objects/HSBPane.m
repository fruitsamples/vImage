#import "HSBPane.h"
#import "MyTimes.h"


@implementation HSBPane

- (IBAction)changeMatrix:(id)sender
{
    NSString *hueString = nil;
    NSString *contrastString = nil;
    NSString *brightnessString = nil;
    NSString *saturationString = nil;

    info.saturation = [ saturationSlider floatValue ];
    info.hue = [ hueSlider floatValue ];
    info.brightness = [ brightnessSlider floatValue ];
    info.contrast = [ contrastSlider floatValue ];

    hueString = [ NSString stringWithFormat: @"%f", info.hue ];
    contrastString = [ NSString stringWithFormat: @"%f", info.contrast ];
    saturationString = [ NSString stringWithFormat: @"%f", info.saturation ];
    brightnessString = [ NSString stringWithFormat: @"%f", info.brightness ];

    [ hueText setStringValue: hueString ];
    [ brightnessText setStringValue: brightnessString ];
    [ saturationText setStringValue: saturationString ];
    [ contrastText setStringValue: contrastString ];
    
    [self flushImage];
}

- (IBAction)go:(id)sender
{
	lastIteration = TRUE;
    [ self flushImage ];
    [ imageController finishTest ];
    [ self orderOut: nil ];
}

-(void)initWithParams: (NSBitmapImageRep *) theImageRep
                filter: (int) filter
				dataType: (int) theDataType
                iterations: (int) iterations
				params: (paramList *) theParams;
{
	imageRep = theImageRep;
	int				set = filter >> 16;
	int				item = filter & 0xffff;
	int				i;
	unsigned char	*data[5];
    flags = filterLists[set].list[item].flags;
    dataType = theDataType;
	function = (&filterLists[set].list[item].function)[dataType];
	iterationCount = iterations;
    params = theParams;
    params->hsbInfo = &info;
	first = params->firstTestChannel;
	last = params->lastTestChannel;
	lastIteration = FALSE;

    height = [imageController height];
    width = [imageController width];
    quitting = NO;
     
	// set up the source and destination vImage_Buffers
	srcImageRep = [imageController formatImageDataForTest: imageRep dataType: dataType];
	dstImageRep = [imageController setupResultImageRep: imageRep dataType: dataType premultiplied: TRUE];
	
	[srcImageRep getBitmapDataPlanes: data];
	for (i = first; i < last; i++) {
		src[i].data = data[i];
		src[i].height = height;
		src[i].width = width;
		src[i].rowBytes = [srcImageRep bytesPerRow];
	}
	[dstImageRep getBitmapDataPlanes: data];
	for (i = first; i < last; i++) {
		dst[i].data = data[i];
		dst[i].height = height;
		dst[i].width = width;
		dst[i].rowBytes = [dstImageRep bytesPerRow];
	}
	
    //Make sure we don't go away when closed
    [ self setReleasedWhenClosed: NO ];
    [ self changeMatrix:nil ];
    [ self makeKeyAndOrderFront: nil ];
}

-(void) flushImage
{
    uint64_t	startTime, endTime;
    double	currentTime;
    int 	j;

    startTime = MyGetTime();
    for( j = first; j < last; j++ ) {
        params->colorChannel = j;
        (*function)( &src[j], &dst[j], flags, params );
    }
    endTime = MyGetTime();
    currentTime = MySubtractTime( endTime, startTime );
    
	[ imageController displayView: dstImageRep ];
    [ imageController showTime: currentTime ];
	if (lastIteration) {
		[ imageController updateActiveImage: dstImageRep ];
		[ imageController releaseImageRep: srcImageRep ];
	}
}


@end
