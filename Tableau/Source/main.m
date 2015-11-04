//
//  main.m
//
//  Created by Ian Ollmann on Thu Oct 03 2002.
//	Updated by Robert Murley Sep 2003.
//  Copyright (c) 2002 Apple. All rights reserved.
//
//  The FunctionMenu is a menu that dynamically creates its own menu items,
//  in response to the contents of the filterLists[] array to be found in 
//  Filters.m. This made it easy for us to add new filters as we wrote them
//  without wasting a lot of time changing interface elements. 
//
//  User driven data format changes are routed through the FilterTestController
//  which tracks the starting and current image, and some details like what type 
//	of filter to use ( AltiVec or no, Interleaved data or no, 8 bit or 32 bit FP). 
//  It also handles the main window controls.
//
//  The image controller reads image data and converts it into a standard internal 
//	planar 8-bit format with 4 planes, including an alpha. The standard image data 
//	is stored in a NSBitmapImageRep. Before a test is run, ImageController converts 
//	this data into the format recognized by the various filters. After test completion 
//	the data is converted back to the internal format. This lets us apply several 
//	filters in series to the image.
//
//	Any special parameters needed by specific filters are entered in the Parameters
//	Pane and stored into its paramList structure, which is passed in the call to 
//	each filter.
//

#import <Cocoa/Cocoa.h>

int main(int argc, const char *argv[])
{
    int result;

    result = NSApplicationMain(argc, argv);

    return result;
}
