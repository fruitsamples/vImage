//
//  ViewController.h
//  Tableau
//
//	Created by Robert Murley on 4 Jan 2005.
//	Copyright (c) 2005 Apple Computer, Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#define kNoType -1

@class ParamsController;
@interface ViewController : NSObject
{
    // image display
	IBOutlet NSTextField *imageSizeDisplayField;
    IBOutlet NSImageView *imageView;
    IBOutlet NSTextField *infoDisplayField;
    
    // original image properties
    NSString	*imagePath;
    NSImage		*image;
    int			channelCount;
    int			height;
    int			width;
    NSString	*colorSpace;
	NSBitmapFormat bitmapFormat;
	NSString	*imageInfo;
	
    NSBitmapImageRep *refImageRep;
	NSBitmapImageRep *displayedImageRep;
}
- (void) viewControllerCheck;
- (void) releaseImage;
- (NSBitmapFormat) bitmapFormat;
- (void) findImage;
- (void) readImage: (NSString *) path;
- (void) releaseImage;
- (NSImageView *) imageView;
- (int) height;
- (int) width;
- (NSString *) imagePath;
- (NSBitmapImageRep *) refImageRep;
- (BOOL) isInteger: (NSBitmapImageRep *) imageRep;
- (int) imageRepType: (NSBitmapImageRep *) imageRep;
- (NSBitmapImageRep *) constructIntegerReferenceImage: (NSBitmapImageRep *) srcImageRep;
- (NSBitmapImageRep *) constructFloatingPointReferenceImage: (NSBitmapImageRep *) srcImageRep;
- (NSBitmapImageRep *) formatImageDataForTest: (NSBitmapImageRep *) bitmapImageRep dataType: (int) type;
- (BOOL) allocateImageBuffers: (void **) data planes: (int) planes size: (size_t) size;
- (void) releaseImageRep: (NSBitmapImageRep *) imageRep;
- (void) displayView: (NSBitmapImageRep *) imageRep;
- (BOOL) validateIntegerImage: (vImage_Buffer *) buffer;
- (BOOL) validateFloatingPointImage: (vImage_Buffer *) buffer;

- (IBAction) saveImage:(id)sender;

@end
