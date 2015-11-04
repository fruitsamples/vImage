//
//  FunctionMenu.h
//  Tableau
//
//	Writeen by ian Ollmann.
//	Modified by Robert Murley Sep 2003.
//  Copyright (c) 2003 Apple Computer, Inc. All rights reserved.
//

@class ImageController;

@interface FunctionMenu : NSMenu
{
	IBOutlet ImageController *imageController;	
}
- (void)initObject;
- (void)enableMenuItems;
- (void)turnOnItem:(id)item;
- (IBAction)useVector:(id)sender;
- (IBAction)doTrace:(id)sender;
- (void)turnOnDefaultItem;
- (id)currentFilterMenuItem;

@end

