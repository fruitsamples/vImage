//
//  KernelPane.h
//  Tableau
//
//  Created by Ian Ollmann on Wed Nov 20 2002.
//	Copyright (c) 2003 Apple Computer, Inc. All rights reserved.
//

#import "Filters.h"
#import	 "ParamsController.h"

@class Kernel;
@interface KernelPane : NSWindow
{
	IBOutlet ImageController	*controller;
	IBOutlet ParamsController	*parameters;
    IBOutlet NSButton 			*cancelButton;
    IBOutlet NSTextField		*intText;
    IBOutlet NSTextField		*FPText;
    IBOutlet NSTableView 		*kernelData;
    IBOutlet NSPopUpButton 		*kernelPrefabType;
    IBOutlet NSForm 			*kernelSize;
    IBOutlet NSButton 			*applyButton;
    
    NSMutableArray			*kernelList;
    NSMutableArray			*kernelListFP;
}
- (void)initObject;
- (IBAction)applyChanges:(id)sender;
- (IBAction)cancelChanges:(id)sender;
- (IBAction)setPrefabType:(id)sender;
- (IBAction)setSize:(id)sender;
- (IBAction)setIntOrFloat:(id)sender;

- (void)setKernelType: (int) dataType;
- (void)setupPrefabMenu;
- (void)setFilter:(int)filter;
- (BOOL)isShowingFP;
- (Kernel*)kernelForFilter:(int)filter  isFP:(BOOL)isFP;
@end
