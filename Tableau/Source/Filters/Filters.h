/*
 *  Filters.h
 *  Tableau
 *
 *  Created by Ian Ollmann on Thu Oct 03 2002.
 *	Modified by Robert Murley, Sep 2003.
 *  Copyright (c) 2003 Apple Computer, Inc. All rights reserved.
 *
 */

#ifndef _FILTERS_H_
#define _FILTERS_H_	1

#import <Cocoa/Cocoa.h>
@class Kernel;
@class ImageController;

// Data formats
typedef enum
{
    planar_8,
    planar_F,
    ARGB_8888,
    ARGB_FFFF
}DataFormatType;

//Kernel info for a Geometry function
typedef struct
{
    float	xShear;			//degrees
    float	yShear;			//degrees
    float	xTranslation;		//fraction of the image width -1.0 ... 1.0
    float	yTranslation;		//fraction of the image width -1.0 ... 1.0
    float	xScale;			//log2 scale
    float	yScale;			//log2 scale
    float	rotate;
    float	a, r, g, b;		//background color
    vImage_AffineTransform	transformMatrix;	//3x3 array of transformation matrix elements
    BOOL	quitting;
}TransformInfo;

typedef struct
{
    float       hue;
    float       saturation;
    float       brightness;
    float       contrast;
}HSBInfo;

typedef struct
{
    void   			*kernel;            // functions with kernels
    int				kernel_height;
    int				kernel_width;
    int				divisor;
    int				srcOffsetToROI_X;	// offsets
    int				srcOffsetToROI_Y;
    BOOL			leaveAlphaUnchanged;
    BOOL			useTemporaryBuffers;
    BOOL			doTiling;
	int				firstTestChannel;
	int				lastTestChannel;
	vImage_Buffer	*alpha;
    float			min;				// FP functions
    float			max;
    int				edgeStyle;		 	// convolution
    float			backgroundColor[4];	// background color (ARGB)
	float			bias[4];			// bias (ARGB)
    TransformInfo   *info;				// geometry
    HSBInfo         *hsbInfo;           // HSB example
    int				colorChannel;
	float			sigmaValue;			// Richardson-Lucy
	int				iterationsPerCall;	// Richardson-Lucy
    int				histogramEntries;	// histogram
    uintptr_t		alphaHistogram[256];
    uintptr_t		redHistogram[256];	
    uintptr_t		greenHistogram[256];	
    uintptr_t		blueHistogram[256];
	vImagePixelCount		*histogramPtrs[4];
    int				low;
    int				high;
    int				readIterations;		// read iterations for timing
    BOOL			displayTiming;		// display timing for reads
    BOOL			shark;				// Notify Shark remote monitoring for reads
	float			scalarForOverwrite; // Conversion
	uint8_t			sourceOverwrite;	// source channel for overwrite
	uint8_t			destOverwrite;		// destination channel for overwrite
    Pixel_8			alphaTable[256];	// lookup tables
    Pixel_8			redTable[256];
    Pixel_8			greenTable[256];
    Pixel_8			blueTable[256];
} paramList;

typedef int (*TestFunc)( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
typedef int (*KernelInitFunc)( void *inData, int height, int width );

// Filters
enum
{
    test,
    morphology,
    convolution,
    geometry,
    histogram,
    alphaComposite,
    convert,
    hsb,
    transform
};

//Filter Flags
enum
{
    kNoFilterFlags = 0,
    kDoOperationInPlace = (1UL << 16),
    
    //Geometry controls to enable
    kTranslateX = 	(1UL << 17),
    kTranslateY = 	(1UL << 18),
    kRotate = 		(1UL << 19),
    kShearX = 		(1UL << 20),
    kShearY = 		(1UL << 21),
    kScaleX = 		(1UL << 22),
    kScaleY = 		(1UL << 23),
    kGeometryFlags = kTranslateX | kTranslateY | kRotate | kShearX | kShearY | kScaleX | kScaleY,
    
    //Alpha flags
    kIsPremultiplied = (1UL << 24),
	
	//Initialize app with this function
	kInitFilter = (1UL << 25),
	
	kDisplaysPane = (1UL << 26),
	kDestDataTypePlanar8 = (1UL << 27 ),
	kDestDataTypePlanarF = (1UL << 28 ),
	kDestDataTypeARGB8888 = (1UL << 29 ),
	kDestDataTypeARGBFFFF = (1UL << 30 ),
	kConversionFlags = kDestDataTypePlanar8 | kDestDataTypePlanarF | kDestDataTypeARGB8888 | kDestDataTypeARGBFFFF
};



enum
{
    kNoKernelType	=	0,
    kNoKernelData,		//For cases like the Min/Max filters that have a kernel size but no data in the kernel
    kUInt8KernelType,
    kSInt8KernelType,
    kUInt16KernelType,
    kSInt16KernelType,
    kUInt32KernelType,
    kSInt32KernelType,
    kFloatKernelType,
    kDoubleKernelType,
    kGeometryKernelType,	//A TransformInfo struct. See Geometry Filters.h
    
    kLastKernelType
};

enum
{
	kGammaPlanar8toPlanarF = 0,
	kGammaPlanarFtoPlanar8,
	kGammaPlanarF
};

//Index with the kernelTypes in the enum above
extern const unsigned char kKernelTypeSizes[];


typedef struct
{
    KernelInitFunc	intFunc;
    KernelInitFunc	fpFunc;
    int				defaultHeight;
    int				defaultWidth;
    int				typeInt;
    int				typeFP;
    NSString		*name;
}KernelInitFunction;

typedef struct 
{
    int 		count;
    KernelInitFunction	list[1];		//The first item in the list is the default
}KernelInitFunctionList;

typedef struct
{
    TestFunc			function;
    TestFunc			functionFP;
    TestFunc			functionInterleaved;
    TestFunc			functionFPInterleaved;
    NSString			*name;
    int				flags;		// See Filter Flags
	KernelInitFunctionList	*kernelInitList;
	Kernel				*lastIntKernel;
	Kernel				*lastFPKernel;
}FilterInfo;

typedef struct 
{
    int				type;
    FilterInfo			*list;
    NSString			*name;
    int				count;
}FilterList;

extern NSString    *typeNames[];
extern FilterList		filterLists[];
extern int			kListCount;

#define	kNoFilter 	-1L

#endif
