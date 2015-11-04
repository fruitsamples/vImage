//
//  ImageController.h
//  Tableau
//
//	Created by Robert Murley on 20 Sep 2003.
//	Copyright (c) 2003 Apple Computer, Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <sys/sysctl.h>
#import "ViewController.h"
#import "Filters.h"
#import "KernelPane.h"
#import "FunctionMenu.h"
#import "ParamsController.h"

@class FilterTest;
@class TimingTest;
@class Kernel;
@class AlphaPane;
@class GeometryPane;
@class HSBPane;
@class TransformPane;

@interface ImageController : ViewController
{
	IBOutlet NSTextField *conversionType;
    IBOutlet FunctionMenu *functionMenu;
	IBOutlet NSMenuItem *menuPlanar8;
	IBOutlet NSMenuItem *menuPlanarF;
	IBOutlet NSMenuItem *menuInterleaved8;
	IBOutlet NSMenuItem *menuInterleavedF;
    IBOutlet KernelPane *kernelPane;
    IBOutlet ParamsController *paramsController;
	IBOutlet GeometryPane *geometryPane;
	IBOutlet AlphaPane   *alphaPane;
	IBOutlet HSBPane	 *hsbPane;
	IBOutlet TransformPane *transformPane;    
    IBOutlet NSButton	 *goButton;
    IBOutlet NSButton	 *imageButton0;
    IBOutlet NSButton	 *imageButton1;
    IBOutlet NSButton	 *imageButton2;
    IBOutlet NSButton	 *imageButton3;
    IBOutlet NSButton	 *imageButton4;
    IBOutlet NSProgressIndicator *progressBar;
	IBOutlet NSTextField *testStatus;
    IBOutlet NSTextField *timeDisplayField;

	// test data
	BOOL		wasInitialized;
    int 		filter;
	int			set, item, filterType;
    int			dataType;
    int			iterationCount;
    vImage_Flags flags;
    BOOL		useVector;
    BOOL		shouldDoTrace;
	NSMenuItem		*menus[4];
	NSButton		*imageButtons[5];
	NSMutableArray	*viewControllers;
	NSNib			*viewWindowNib;
	NSArray			*objects;
	paramList		*params;

    // managing multiple images
	NSBitmapImageRep *imageData[5];
	int		activeImage;
	int		imageCount;
	int		revNum;

	// progress bar
    NSView		*progressBarSuperview;
    NSPoint		progressBarOffset;
    NSRect		frame;
    NSPoint		newOrigin;
    NSRect		progressBarFrame, superviewFrame;
}

- (IBAction) setDataType: (id) sender;
- (IBAction) setIterationCount: (id) sender;
- (IBAction) setFilterType:(id) sender;
- (IBAction) applyFilter: (id) sender;
- (IBAction) timingTest: (id) sender;
- (IBAction) findImage:(id)sender;
- (IBAction) newWindow:(id)sender;
- (IBAction) handleImageButtons: (id) sender;
- (IBAction) compareResultImages: (id) sender;

- (void) initObject;
- (void) awakeFromNib;
- (int) filter;
- (int) dataType;
- (int) iterationCount;
- (paramList*) params;
- (Kernel*) kernel;
- (void) setTimingTestStatus: (NSString *) vecState dataType: (NSString *) type;
- (NSString*) filterName;
- (void) doTrace: (BOOL) shouldDoTrace;
- (void) enableVectorUnit: (BOOL) isOn;
- (BOOL) isVectorAvailable;
- (ViewController *) getViewController: (int) number;
- (NSArray *) getViewNameList;
- (NSBitmapImageRep *) setupResultImageRep: (NSBitmapImageRep *) bitmapImageRep dataType: (int) type premultiplied: (BOOL) premult;
- (void) displayImageButtons;
- (void) resetToReferenceImage;
- (void) updateActiveImage: (NSBitmapImageRep *) imageRep;
- (BOOL) windowShouldClose: (id) sender;

- (void) startTest;
- (void) setProgress: (double) progress;
- (void) finishTest;
- (void) showTime: (double) time;
- (void) controlTextDidChange: (NSNotification *) notification;
- (void) print: (vImage_Buffer *) buffer type: (int) type count: (int) count name: (char *) name;

@end
