//
//  ImageController.m
//  Tableau
//
//	Created by Robert Murley on 20 Sep 2003.
//	Copyright (c) 2003 Apple Computer, Inc. All rights reserved.
//

#import "ImageController.h"
#import "Filters.h"
#import "FilterTest.h"
#import "ParamsController.h"
#import "AlphaPane.h"
#import "GeometryPane.h"
#import "HSBPane.h"
#import "TransformPane.h"
#import "TimingTest.h"
#define MaxReps 5

extern void SetvImageVectorAvailable();

@implementation ImageController

- (id)init
{
	[super init];
	wasInitialized = FALSE;
	
	imageData[0] = nil;
	imageData[1] = nil;
	imageData[2] = nil;
	imageData[3] = nil;
	imageData[4] = nil;
	
	activeImage = 0;
	imageCount = 0;
	viewControllers = [NSMutableArray arrayWithCapacity: 5];
	[viewControllers retain];
	
    useVector = NO;
    dataType = planar_8;
    filter = kNoFilter;
    iterationCount = 1;
	
    return self;
}

- (void) initObject
{
	menus[planar_8] = menuPlanar8;
	menus[planar_F] = menuPlanarF;
	menus[ARGB_8888] = menuInterleaved8;
	menus[ARGB_FFFF] = menuInterleavedF;

	imageButtons[0] = imageButton0;
	imageButtons[1] = imageButton1;
	imageButtons[2] = imageButton2;
	imageButtons[3] = imageButton3;
	imageButtons[4] = imageButton4;

	viewWindowNib = [[NSNib alloc] initWithNibNamed: @"ViewWindow" bundle: [NSBundle mainBundle]];
	params = [paramsController params];

	//Init the progress bar
    progressBarSuperview = [ progressBar superview ];
    progressBarFrame = [ progressBar frame ];
    superviewFrame = [ progressBarSuperview frame ];
    progressBarOffset.x = progressBarFrame.origin.x - superviewFrame.size.width;
    progressBarOffset.y = progressBarFrame.origin.y;
    [ progressBar setMaxValue: 1.0 ];
	[ progressBar removeFromSuperview ];
    [ progressBar retain ];

	//Init the test status field
	[ testStatus removeFromSuperview ];
    [ testStatus retain ];
}

-(void) awakeFromNib
{
	if (wasInitialized)
		return;
	
    //Init the parameters pane
    [ paramsController initObject ];
	
    //Init our main window 
    [ self initObject ];
	
    //Init the kernel pane
    [ kernelPane initObject ];

    //Set up the function menu
    [ functionMenu initObject ];
	
	wasInitialized = TRUE;
}

- (void)dealloc
{
	int		i;
	
	[viewControllers removeAllObjects];
	[viewControllers release];
	[objects release];

	for (i = 0; i < imageCount; i++)
		[self releaseImageRep: imageData[i]];

	[super dealloc];
}

- (IBAction) setDataType: (id) sender
{
	int		i;
	
	for (i = planar_8; i <= ARGB_FFFF; i++)
		[menus[i] setState: NSOffState];
	
	dataType = [sender tag] - 1;
	
	[menus[dataType] setState: NSOnState];

	[kernelPane setKernelType: dataType];
    
    [functionMenu enableMenuItems];
    
    if([ [ functionMenu currentFilterMenuItem] isEnabled ] == NO)
        [functionMenu turnOnDefaultItem];
}

- (int) dataType { return dataType; }

- (IBAction)setFilterType:(id)sender
{
    [ (FunctionMenu*) functionMenu turnOnItem: sender ];

    if( nil != sender && NSOnState == [ sender state ] )
    {
        [ goButton setTitle: [ sender title ] ];
        filter = [ sender tag ];
    }
    else
    {
        [ goButton setTitle: @"(None)" ];
        [ goButton setEnabled: NO ];
        filter = kNoFilter;
		return;
    }

	set = filter >> 16;
	item = filter & 0xffff;
	filterType =  filterLists[set].type;
	flags = filterLists[set].list[item].flags;

    //Set up the kernel pane to display the current filter
    [ kernelPane setFilter: filter ];
	
	// if filter displays a secondary pane, go to it now
	if (flags & kDisplaysPane)
		[self applyFilter: self];
}

- (int) filter { return filter; }

- (IBAction) setIterationCount: (id) sender
{
    iterationCount = [sender intValue];
    if ( iterationCount < 1 )
    {
        iterationCount = 1;
        [sender setIntValue: 1];
    }
}

- (int) iterationCount { return iterationCount; }

- (paramList*) params { return [paramsController params]; }

- (void) setTimingTestStatus: (NSString *) vecState dataType: (NSString *) type
{
	if (vecState == NULL) {
		[testStatus setHidden: TRUE];
		[testStatus removeFromSuperview];
		return;
	}
	
	[ progressBarSuperview addSubview: testStatus ];
	[testStatus setStringValue: [vecState stringByAppendingString: type]];
	[testStatus setHidden: FALSE];
}

- (NSString*) filterName
{    return filterLists[set].list[item].name; }


- (void) doTrace: (BOOL) isTraced
{
    shouldDoTrace = isTraced;
}


- (void) enableVectorUnit: (BOOL) isOn
{
	if( YES == isOn )
		useVector = -1;
	else
		useVector = 0;
}

- (BOOL) isVectorAvailable
{
    int selectors[2] = { CTL_HW, HW_VECTORUNIT };
    int hasVectorUnit = 0;
    size_t length = sizeof(hasVectorUnit);
    int error = sysctl(selectors, 2, &hasVectorUnit, &length, NULL, 0); 
    
    if(0 == error && 0 != hasVectorUnit )
        return YES;
    
    return NO;
}

- (BOOL) validateMenuItem: (id <NSMenuItem>) menuItem
{
//    return ( refImageRep && [self getViewController: 0] );
	return TRUE;
}

- (IBAction) newWindow:(id)sender
{
	ViewController	*view = nil;
	NSWindow		*window;
	int		  i;

	// instantiate a new ViewController and ViewWindow
	[viewWindowNib instantiateNibWithOwner: self topLevelObjects: &objects];
	if (!objects)
		return;

	// add to the ViewControllers array
	for (i = 0; i < [objects count]; i++) {
		[[objects objectAtIndex: i] retain];
		if ([[objects objectAtIndex: i] respondsToSelector: @selector(viewControllerCheck)]) {
			view = [objects objectAtIndex: i];
			[viewControllers addObject: view];
		} else {
			window = [objects objectAtIndex: i];
			[window setDelegate: self];
		}
	}

	if (view) {
		if ([sender isKindOfClass: [NSMenuItem class]]) {
			[view findImage];
			if (filter >> 16 == alphaComposite)
				[alphaPane performSelector: @selector(setupImageMenu)];
		}
	} else
		NSLog(@"Error reading ViewWindow.nib");
	
	objects = nil;
	return;
}

- (ViewController *) getViewController: (int) number
{
	if (number >= [viewControllers count])
		return nil;
	return [viewControllers objectAtIndex: number];
}

- (NSArray *) getViewNameList
{
	int		i;
	
	if ([viewControllers count] == 0)
		return nil;
		
	NSMutableArray *viewNames = [NSMutableArray arrayWithCapacity: 5];
	[viewNames retain];
	
	for (i = 0; i < [viewControllers count]; i++) {
		NSArray *viewPath = [[[viewControllers objectAtIndex: i] imagePath] componentsSeparatedByString: @"/"];
		[viewNames addObject: [viewPath objectAtIndex: [viewPath count] - 1]];
		[[viewNames objectAtIndex: i] retain];
	}
	
	return viewNames;
}

- (IBAction)findImage:(id)sender
{
    int		i;
    
	[super findImage];
	if (!refImageRep)
		return;		// failed somewhere along the way

	for (i = 0; i < imageCount; i++)
		[self releaseImageRep: imageData[i]];
	imageCount = 0;
    
	revNum = -1;
	[self updateActiveImage: refImageRep];

	[goButton setEnabled: YES ];
}

- (NSBitmapImageRep *) setupResultImageRep: (NSBitmapImageRep *) imageRep dataType: (int) type premultiplied: (BOOL) premult
{
    static const int		pixelSize[4] = { sizeof(Pixel_8), sizeof(Pixel_F), sizeof(Pixel_8888), sizeof(Pixel_FFFF) };
	static const int		planes[4] = { 4, 4, 1, 1 };
	void	*data[5] = { nil, nil, nil, nil, nil };
	NSBitmapImageRep *resultImageRep;
	NSBitmapFormat	format;
	int		bitsPerSample, i;
	int		x = [imageRep pixelsWide], y = [imageRep pixelsHigh];
	
	// allocate destination filter buffers
	if ([self allocateImageBuffers: data planes: planes[type] size: x * y * pixelSize[type]] == NO)
		return nil;

	bitsPerSample = 8;
	format = NSAlphaFirstBitmapFormat;
	if (!premult)
		format |= NSAlphaNonpremultipliedBitmapFormat;
	if (type == planar_F || type == ARGB_FFFF) {
		bitsPerSample = 32;
		format |= NSFloatingPointSamplesBitmapFormat;
	}
	
 	resultImageRep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes: (unsigned char**) data
						pixelsWide: x
						pixelsHigh: y
						bitsPerSample: bitsPerSample
						samplesPerPixel: 4
						hasAlpha: [imageRep hasAlpha]
						isPlanar: (type == planar_8 || type == planar_F)
						colorSpaceName: NSCalibratedRGBColorSpace
						bitmapFormat: format
						bytesPerRow: x * pixelSize[type]
						bitsPerPixel: 8 * pixelSize[type] ];
	
	if (resultImageRep == nil)
		for ( i = 0; i < planes[type]; i++ )
			free(data[i]);
	
	return resultImageRep;
}

- (IBAction)applyFilter:(id)sender
{
	params->firstTestChannel = 0;
	if (dataType == planar_8 || dataType == planar_F) {
		params->lastTestChannel = 4;
		if (params->leaveAlphaUnchanged)
			params->firstTestChannel = 1;
	} else
		params->lastTestChannel = 1;
    
	SetvImageVectorAvailable( useVector );
		
	// check for tests with their own control panel
    if (filterType == geometry && (flags & kGeometryFlags))
		[geometryPane initWithParams: imageData[activeImage]
						filter: filter
						dataType: dataType
						iterations: iterationCount
						params: params];
	else if ((filterType == alphaComposite) && (flags & kDisplaysPane))
		[alphaPane initWithParams: imageData[activeImage]
						filter: filter
						dataType: dataType
						iterations: iterationCount];
	else if (filterType == hsb)
		[hsbPane initWithParams: imageData[activeImage]
						filter: filter
						dataType: dataType
						iterations: iterationCount
						params: params];
	else if (filterType == transform)
		[transformPane initWithParams: imageData[activeImage]
						filter: filter
						dataType: dataType
						iterations: iterationCount
						params: params];
	else {

		FilterTest	*filterTest = [[FilterTest alloc] init];
		if (filterTest == nil)
			return;
		
		[filterTest initWithParams: imageData[activeImage]
						filter: filter 
						dataType: dataType
						iterations: iterationCount
						paramList: [paramsController params]
						kernel: [self kernel]];
		
		[NSThread detachNewThreadSelector: @selector(runFilterTest:) toTarget: filterTest withObject: self];
	}
}

- (IBAction) timingTest: (id) sender
{
	TimingTest	*timingTest = [[TimingTest alloc] init];
	if (timingTest == nil)
		return;

	[timingTest initWithParams: imageData[activeImage]
					filter: filter 
					dataType: dataType
					iterations: iterationCount
					paramList: [paramsController params]
					kernel: [self kernel]];
	
	[NSThread detachNewThreadSelector: @selector(runTimingTest:) toTarget: timingTest withObject: self];
}

-(Kernel*)kernel
{
    Kernel *k = nil;

    switch( dataType )
    {
        case planar_8:
		case ARGB_8888:
            k = [ kernelPane kernelForFilter: filter	isFP: NO ];
            break;
        case planar_F:
		case ARGB_FFFF:
            k = [ kernelPane kernelForFilter: filter	isFP: YES ];
            break;
        default:
            //Do nothing
            break;
    }
            
    return k;
}

- (void) closeWindow: (ViewController *) view
{
	[viewControllers removeObject: view];
	[view release];
}

- (void) updateActiveImage: (NSBitmapImageRep *) imageRep
{
	int		i;

	revNum++;
	if (imageCount == MaxReps) {
		[image removeRepresentation: imageData[1]];	// in case this one is displayed
		[self releaseImageRep: imageData[1]];	// release oldest imageRep
		for (i = 1; i < MaxReps - 1; i++) {
			imageData[i] = imageData[i + 1];	// move others up
			[imageButtons[i] setTitle: [imageButtons[i + 1] title]];
		}
		imageCount--;
	}
	
	imageData[imageCount] = imageRep;
	activeImage = imageCount++;
	[imageButtons[imageCount - 1] setTitle: [NSString stringWithFormat: @"%i", revNum]];
	[self displayImageButtons];
}

- (void) displayImageButtons
{
	int		i;
	
	if (imageCount <= 1)
		for (i = 0; i < MaxReps; i++)
			[imageButtons[i] setHidden: YES];
	else for (i = 0; i < imageCount; i++) {
		[imageButtons[i] setHidden: NO];
		[imageButtons[i] setEnabled: i != activeImage];
	}
}

- (void) resetToReferenceImage
{
	activeImage = 0;
	[self displayImageButtons];	
	[self displayView: imageData[activeImage]];
}

- (IBAction) handleImageButtons: (id) sender
{
	activeImage = [sender tag];
	[self displayImageButtons];
	[self displayView: imageData[activeImage]];
}
		
- (IBAction) compareResultImages: (id) sender;
{
	int		i, h, w, a, b, count = 0, rowWidth = width, planes;
	uint8_t	*data0[5], *data1[5];

	if (imageCount < 2)
		return;
	
	planes = 1;
	if ([imageData[imageCount - 1] isPlanar])
		planes = 4;
	else
		rowWidth *= 4;
	
	[imageData[imageCount - 2] getBitmapDataPlanes: data0];
	[imageData[imageCount - 1] getBitmapDataPlanes: data1];

	for (i = 0; i < planes; i++)
		for (h = 0; h < height; h++)
			for (w = 0; w < rowWidth; w++) {
				a = data0[i][h * rowWidth + w];
				b = data1[i][h * rowWidth + w];
				if (a != b) {
					printf("\nrow = %d, column = %d, plane = %d, values = %d  %d", h, w, i, a, b);
					if (++count >= 10)
						return;
				}
			}
	
	printf("\nImages Match.");
}

- (BOOL) windowShouldClose: (id) sender
{
	int		nbr = [sender windowNumber], i;
	
	// find the viewWindow associated with this window
	for (i = 0; i < [viewControllers count]; i++) {
		if ([[[[self getViewController: i] imageView] window] windowNumber] == nbr)
		{
			[viewControllers removeObjectAtIndex: i];
			if (filter >> 16 == alphaComposite)
				[alphaPane setupImageMenu];
			return YES;
		}
	}
	return NO;
}

- (void) startTest
{
	frame = [ progressBarSuperview frame ];
    newOrigin.x = progressBarOffset.x + frame.size.width;
    newOrigin.y = progressBarOffset.y;
    [ progressBar setFrameOrigin: newOrigin ];
	[ progressBarSuperview addSubview: progressBar ];

	[ progressBar setHidden: FALSE ];
    [ self setProgress: 0.0 ];
	[ progressBar display ];
}

- (void) setProgress: (double) progress
{
    if( progress > 1.0 )
        progress = 1.0;
        
    if( progress < 0.0 )
         progress = 0.0;

    [ progressBar setDoubleValue: progress ];
	[ progressBar display ];
}

- (void) finishTest
{
	[ progressBar setHidden: TRUE ];
	[ progressBar removeFromSuperview ];
}

-( void ) showTime: (double) time
{
    NSString *timeString = [ NSString stringWithFormat: @"%4.4e", time ];
    
    [ timeDisplayField setStringValue: timeString ];
}

- (void)controlTextDidChange:(NSNotification*) notification
{
    NSTextField *field = [notification object];
    
    if ( [field tag] == 100 )
        [self setIterationCount: field];
}

- (void) print: (vImage_Buffer *) buffer type: (int) type count: (int) count name: (char *) name
{
	int		i;
	
	for (i = 0; i < count; i++) {
		if ((i % 8) == 0)
			printf("\n");
		else if ((i % 4) == 0)
			printf("\t");
		
		if (type == planar_8 || type == ARGB_8888)
			printf("%3u\t", ((unsigned char *)buffer->data)[i]);
		else
			printf("%6.4f\t", ((float *)buffer->data)[i]);
		if ((i % 8) == 7)
			printf("\t%s", name);
	}
	fflush(stdout);
}

@end
