//
//  ParamsController.m
//  Tableau
//
//	Written by Robert Murley Sep 2003.
//  Copyright (c) 2003 Apple Computer, Inc. All rights reserved.
//
#import "ParamsController.h"

#include "AvailabilityMacros.h"

#ifndef MAC_OS_X_VERSION_10_5
    typedef float CGFloat;
#endif

@implementation ParamsController

- (void)initObject
{
    int		i;
    
    params.srcOffsetToROI_X = [SrcOffsetX intValue];
    params.srcOffsetToROI_Y = [SrcOffsetY intValue];
    params.leaveAlphaUnchanged = [LeaveAlphaUnchanged intValue];
    params.useTemporaryBuffers = [UseTemporaryBuffers intValue];
    params.doTiling = [DoTiling intValue];
    params.min = [FPMinimum floatValue];
    params.max = [FPMaximum floatValue];
    params.edgeStyle = kvImageEdgeExtend;
    params.backgroundColor[0] = [BGColorAlpha floatValue];
    params.backgroundColor[1] = [BGColorRed   floatValue];
    params.backgroundColor[2] = [BGColorGreen floatValue];
    params.backgroundColor[3] = [BGColorBlue  floatValue];
    params.bias[0] = [BGColorAlpha floatValue];
    params.bias[1] = [BGColorRed   floatValue];
    params.bias[2] = [BGColorGreen floatValue];
    params.bias[3] = [BGColorBlue  floatValue];
	params.sigmaValue = [RLDSigma floatValue];
	params.iterationsPerCall = [RLDIterationsPerCall intValue];
    params.histogramEntries = [HistogramEntries intValue];
    params.low = [ContrastStretchLow intValue];
    params.high = [ContrastStretchHigh intValue];
    params.readIterations = [ReadIterations intValue];
    params.displayTiming = [DisplayTiming intValue];
    params.shark = [SharkRemoteMonitoring intValue];
	params.scalarForOverwrite = [ScalarForOverwrite floatValue];
	params.sourceOverwrite = [sourceOverwrite indexOfSelectedItem];
	params.destOverwrite = [destOverwrite indexOfSelectedItem];
    for ( i = 0; i < 256; i++ )
    {
        params.alphaHistogram[i] = 0;
        params.redHistogram[i] = 0;
        params.greenHistogram[i] = 0;
        params.blueHistogram[i] = 0;
        params.alphaTable[i] = 0;
        params.redTable[i] = 0;
        params.greenTable[i] = 0;
        params.blueTable[i] = 0;
    }
}
    
- (paramList*)params
{
    return &params;
}

- (IBAction) doLeaveAlphaUnchanged:(id)sender
{
    params.leaveAlphaUnchanged = [sender intValue];
}

- (IBAction)doBias:(id)sender
{
    params.bias[0] = [ BiasAlpha floatValue ];
    params.bias[1] = [ BiasRed   floatValue ];
    params.bias[2] = [ BiasGreen floatValue ];
    params.bias[3] = [ BiasBlue  floatValue ];
}

- (IBAction)doBackgroundColor:(id)sender
{
    NSColorPanel *panel = [ NSColorPanel sharedColorPanel ];
    
    [ panel setContinuous: YES ];
    [ panel setTarget: self ];
    [ panel setAction: @selector( changeColor: ) ];
    [ panel makeKeyAndOrderFront: nil ];
}

-(void)changeColor:(id)sender
{
    NSColor *color = [sender color];
    CGFloat	r, g, b, a;
    
    [ color getRed:&r green:&g blue:&b alpha:&a ];
    [ BGColorRed   setFloatValue: r ];
    [ BGColorGreen setFloatValue: g ];
    [ BGColorBlue  setFloatValue: b ];
    [ BGColorAlpha setFloatValue: a ];
    params.backgroundColor[0] = a;
    params.backgroundColor[1] = r;
    params.backgroundColor[2] = g;
    params.backgroundColor[3] = b;
}

- (IBAction)doContrastStretchHigh:(id)sender
{
    params.high = [sender intValue];
    if ( params.low + params.high > 100 )
    {
        [ContrastStretchLow setIntValue: 100 - params.high];
        [ContrastStretchLow selectText: self];
    }
}

- (IBAction)doContrastStretchLow:(id)sender
{
    params.low = [sender intValue];
    if ( params.low + params.high > 100 )
    {
        [ContrastStretchHigh setIntValue: 100 - params.low];
        [ContrastStretchHigh selectText: self];
    }
}

- (IBAction)doEdgeStyle:(id)sender
{
    int		row;
    
    row = [sender selectedRow];
    if ( row == 0 )
        params.edgeStyle = kvImageEdgeExtend;
    else if ( row == 1 )
        params.edgeStyle = kvImageBackgroundColorFill;
    else if ( row == 2 )
        params.edgeStyle = kvImageCopyInPlace;
	else
		params.edgeStyle = kvImageTruncateKernel;
}

- (IBAction)doFPMaximum:(id)sender
{
    params.max = [sender floatValue];
    if ( params.min > params.max )
    {
        [FPMinimum setFloatValue: params.max];
        [FPMinimum selectText: self];
    }
}

- (IBAction)doFPMinimum:(id)sender
{
    params.min = [sender floatValue];
    if ( params.max < params.min )
    {
        [FPMaximum setFloatValue: params.min];
        [FPMaximum selectText: self];
    }
}

- (IBAction)doHistogramEntries:(id)sender
{
    params.histogramEntries = [sender intValue];
}

- (IBAction)doReadIterations:(id)sender
{
    params.readIterations = [sender intValue];
    if ( params.readIterations < 1 )
    {
        params.readIterations = 1;
        [sender setIntValue: 1];
    }
    [DisplayTiming setEnabled: params.readIterations > 1];
    [SharkRemoteMonitoring setEnabled: params.readIterations > 1];
}

- (IBAction)doIterationsPerCall:(id)sender
{
    params.iterationsPerCall = [sender intValue];
    if ( params.iterationsPerCall < 1 )
    {
        params.iterationsPerCall = 1;
        [sender setIntValue: 1];
    }
}

- (IBAction)doSigmaValue:(id)sender
{
	float	value;
	
    value = [sender floatValue];
	params.sigmaValue = value;
}


- (IBAction)DoDisplayTiming:(id)sender
{
    params.displayTiming = [sender intValue];
}

- (IBAction)DoShark:(id)sender
{
    params.shark = [sender intValue];
}

- (IBAction)doTable:(id)sender
{
    NSOpenPanel	*panel = [ NSOpenPanel openPanel ];
    NSString *textType = [NSString stringWithCString: "txt"];
    NSArray *types = [NSArray arrayWithObject: textType];
    NSString *tablePath;
    unsigned char	*tablePtrs[4] = { params.alphaTable, params.redTable, params.greenTable, params.blueTable };
    char	*theTablePtr;
    char	fileName[256];
    FILE	*table;
    int		value, eof, i;
    
    [ panel setCanChooseFiles: YES ];
    [ panel setCanChooseDirectories: NO ];
    [ panel setResolvesAliases: YES ];
    [ panel setAllowsMultipleSelection: NO ];
    
    if (NSOKButton != [ panel runModalForTypes: types ])
        return;

    tablePath = [[ panel filenames ] objectAtIndex: 0];
    [tablePath getCString: fileName maxLength: 255];
    table = fopen( fileName, "r" );
    if ( !table )
        return;
    
    theTablePtr = (char *) tablePtrs[ [sender tag] ];
    for ( i = 0; i < 256; i++ )
    {
        eof = fscanf( table, "%d", &value );
        if ( eof < 0 )
            break;
        theTablePtr[i] = value;
    }
    for ( ; i < 256; i++ )
        theTablePtr[i] = 0;
        
    fclose( table );
}

- (IBAction)doSrcOffsetX:(id)sender
{
    params.srcOffsetToROI_X = [sender intValue];
}

- (IBAction)doSrcOffsetY:(id)sender
{
    params.srcOffsetToROI_Y = [sender intValue];
}

- (IBAction)doTiling:(id)sender
{
    params.doTiling = [sender intValue];
}

- (IBAction)doSpecificationTable:(id)sender
{
    NSOpenPanel	*panel = [ NSOpenPanel openPanel ];
    NSString *textType = [NSString stringWithCString: "txt"];
    NSArray *types = [NSArray arrayWithObject: textType];
    NSString *tablePath;
    char	fileName[256];
    FILE	*table;
    int		alpha, red, green, blue, eof, i;
    
    [ panel setCanChooseFiles: YES ];
    [ panel setCanChooseDirectories: NO ];
    [ panel setResolvesAliases: YES ];
    [ panel setAllowsMultipleSelection: NO ];
    
    if (NSOKButton != [ panel runModalForTypes: types ])
        return;

    tablePath = [[ panel filenames ] objectAtIndex: 0];
    [tablePath getCString: fileName maxLength: 255];
    table = fopen( fileName, "r" );
    if ( !table )
        return;
    
    for ( i = 0; i < 256; i++ )
    {
        eof = fscanf( table, "%d %d %d %d", &alpha, &red, &green, &blue );
        if ( eof < 0 )
            break;
        params.alphaHistogram[i] = alpha;
        params.redHistogram[i] = red;
        params.greenHistogram[i] = green;
        params.blueHistogram[i] = blue;
    }
    for ( ; i < 256; i++ )
    {
        params.alphaHistogram[i] = 0;
        params.redHistogram[i] = 0;
        params.greenHistogram[i] = 0;
        params.blueHistogram[i] = 0;
    }
        
    fclose( table );
}

- (IBAction) doUseTemporaryBuffers:(id)sender
{
    params.useTemporaryBuffers = [sender intValue];
}

- (IBAction) doScalarForOverwrite:(id)sender
{
	params.scalarForOverwrite = [sender floatValue];
}

- (IBAction) dosourceOverwrite:(id)sender
{
	params.sourceOverwrite = [sourceOverwrite indexOfSelectedItem];
}

- (IBAction) dodestOverwrite:(id)sender
{
	params.destOverwrite = [destOverwrite indexOfSelectedItem];
}

- (IBAction)hitOK:(id)sender
{
	NSWindow	*pane = (NSWindow *) ParamsWindow;
    [ pane orderOut: nil ];
}

- (IBAction)display:(id)sender
{
	NSWindow	*pane = (NSWindow *) ParamsWindow;
    [ pane setReleasedWhenClosed: NO ];
    
    [ pane makeKeyAndOrderFront: nil ];
}

- (void)controlTextDidChange:(NSNotification*) notification
{
    NSTextField *field = [notification object];
    
    switch ( [field tag] )
    {
        case 0:		[self doFPMinimum: field];				break;
        case 1:		[self doFPMaximum: field];				break;
        case 2:		[self doHistogramEntries: field];		break;
        case 3:		[self doContrastStretchLow: field];		break;
        case 4:		[self doContrastStretchHigh: field];	break;
        case 5:		[self doReadIterations: field];			break;
        case 6:		[self doSrcOffsetX: field];				break;
        case 7:		[self doSrcOffsetY: field];				break;
        case 8:		[self doSigmaValue: field];				break;
        case 9:		[self doIterationsPerCall: field];		break;
        case 10:	[self doBias: field];					break;
        case 11:	[self doBackgroundColor: field];		break;
		case 12:	[self doScalarForOverwrite: field];		break;
        default:	break;
    }
}

@end
