/* HSBPane */

#import <Cocoa/Cocoa.h>

#import "Filters.h"

#import "ImageController.h"
#import "Filters.h"
#import "ParamsController.h"

@interface HSBPane : NSWindow
{
    IBOutlet NSSlider *brightnessSlider;
    IBOutlet NSTextField *brightnessText;
    IBOutlet NSSlider *contrastSlider;
    IBOutlet NSTextField *contrastText;
    IBOutlet NSButton *goButton;
    IBOutlet NSSlider *hueSlider;
    IBOutlet NSTextField *hueText;
    IBOutlet ImageController *imageController;
    IBOutlet ParamsController *paramsController;
    IBOutlet NSSlider *saturationSlider;
    IBOutlet NSTextField *saturationText;
    
	NSBitmapImageRep		*imageRep, *srcImageRep, *dstImageRep;
	vImage_Buffer			src[4], dst[4];
    vImage_AffineTransform	transform;
    TestFunc                function;
	int		dataType;
    int		flags;
    int		iterationCount;
	BOOL	lastIteration;
    int		height, width;
	int		first, last;
    BOOL	quitting;
    HSBInfo	info;
    paramList	*params;

}
-(void)initWithParams: (NSBitmapImageRep *) theImageRep
                filter: (int) filter
				dataType: (int) theDataType
                iterations: (int) iterations
				params: (paramList *) theParams;
- (IBAction)changeMatrix:(id)sender;
- (IBAction)go:(id)sender;
- (void) flushImage;

@end
