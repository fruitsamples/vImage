/* ParamsController */

#import <Cocoa/Cocoa.h>
#import "Filters.h"

@interface ParamsController : NSObject
{
	IBOutlet id ParamsWindow;
    IBOutlet id BGColorAlpha;
    IBOutlet id BGColorBlue;
    IBOutlet id BGColorGreen;
    IBOutlet id BGColorRed;
    IBOutlet id BiasAlpha;
    IBOutlet id BiasBlue;
    IBOutlet id BiasGreen;
    IBOutlet id BiasRed;
    IBOutlet id ContrastStretchHigh;
    IBOutlet id ContrastStretchLow;
    IBOutlet id DisplayTiming;
    IBOutlet id DoTiling;
    IBOutlet id FPMaximum;
    IBOutlet id FPMinimum;
    IBOutlet id HistogramEntries;
    IBOutlet id LeaveAlphaUnchanged;
    IBOutlet id ReadIterations;
    IBOutlet id RLDIterationsPerCall;
    IBOutlet id RLDSigma;
    IBOutlet id SharkRemoteMonitoring;
    IBOutlet id SrcOffsetX;
    IBOutlet id SrcOffsetY;
    IBOutlet id UseTemporaryBuffers;
	IBOutlet id ScalarForOverwrite;
	IBOutlet id sourceOverwrite;
	IBOutlet id destOverwrite;
    paramList params;
}
- (void)initObject;
- (paramList*)params;
- (IBAction)doBackgroundColor:(id)sender;
- (IBAction)doBias:(id)sender;
- (IBAction)doContrastStretchHigh:(id)sender;
- (IBAction)doContrastStretchLow:(id)sender;
- (IBAction)doEdgeStyle:(id)sender;
- (IBAction)doFPMaximum:(id)sender;
- (IBAction)doFPMinimum:(id)sender;
- (IBAction)doHistogramEntries:(id)sender;
- (IBAction)doLeaveAlphaUnchanged:(id)sender;
- (IBAction)doSpecificationTable:(id)sender;
- (IBAction)doReadIterations:(id)sender;
- (IBAction)DoDisplayTiming:(id)sender;
- (IBAction)DoShark:(id)sender;
- (IBAction)doSrcOffsetX:(id)sender;
- (IBAction)doSrcOffsetY:(id)sender;
- (IBAction)doTable:(id)sender;
- (IBAction)doTiling:(id)sender;
- (IBAction)doUseTemporaryBuffers:(id)sender;
- (IBAction)doIterationsPerCall:(id)sender;
- (IBAction)doSigmaValue:(id)sender;
- (IBAction)hitOK:(id)sender;
- (IBAction)doScalarForOverwrite:(id)sender;
- (IBAction)dosourceOverwrite:(id)sender;
- (IBAction)dodestOverwrite:(id)sender;
- (IBAction)display:(id)sender;
- (void)controlTextDidChange:(NSNotification*) notification;
- (void)changeColor:(id)sender;
@end
