/*
 *  Filters.c
 *  Tableau
 *
 *  Created by Ian Ollmann on Thu Oct 03 2002.
 *	Modified by Robert Murley, Sep 2003.
 *  Copyright (c) 2002-3 Apple Computer, Inc. All rights reserved.
 *
 */

#import "Filters.h"
#import <string.h>
#import <limits.h>

#import "MorphologyFilters.h"
#import "ConvolutionFilters.h"
#import "RichardsonLucy.h"
#import "HistogramFilters.h"
#import "MiscFilters.h"
#import "GeometryFilters.h"
#import "ConversionFilters.h"
#import "AlphaFilters.h"


int ZeroFunc( void *inData, int height, int width );
int ZeroFunc( void *inData, int height, int width ){ memset( inData, 0, width * height * sizeof( uint8_t) ); return 0; }
int ZeroFuncFP( void *inData, int height, int width );
int ZeroFuncFP( void *inData, int height, int width ){ memset( inData, 0, width * height * sizeof( float ) );  return 0; }
int Median( void *inData, int height, int width );
int Median( void *inData, int height, int width )
{
    int i;
    short *d = (short*) inData;
    
    for( i = 0; i < width * height; i++ )
        d[i] = 1;

	return width * height;
}
int MedianFP( void *inData, int height, int width );
int MedianFP( void *inData, int height, int width )
{
    int i;
    float *d = (float*) inData;
    float value = 1.0f / (float)( width * height);
    
    for( i = 0; i < width * height; i++ )
        d[i] = value;

	return 0;
}
int Emboss( void *inData, int height, int width );
int Emboss( void *inData, int height, int width )
{
    int i;
    short *d = (short*) inData;
    
	*d++ = 2;
    for( i = 1; i < width * height - 1; i++ )
        *d++ = 0;
	*d = -2;

	return 1;
}
int EmbossFP( void *inData, int height, int width );
int EmbossFP( void *inData, int height, int width )
{
    int i;
    float *d = (float*) inData;
	
	*d++ = 2.0;
    for( i = 1; i < width * height - 1; i++ )
        *d++ = 0.0;
	*d = -2.0;

	return 0;
}

int Sharpen( void *inData, int height, int width );
int Sharpen( void *inData, int height, int width )
{
    int16_t *d = (int16_t *) inData;
    int h, w, count = 0;
    int xSpan = (width-1) / 2;
    int ySpan = (height-1) / 2;
	
    memset( inData, 0, width * height * sizeof( int16_t ) );
	
	// fill out lower rows
	for (h = 0; h <= ySpan; h++)
		for (w = xSpan - h; w <= xSpan + h; w++)
			if (w >= 0 && w < width) {
				d[h * width + w] = -1;
				count++;
			}
	
	// fill out upper rows
	for (h = 0; h < ySpan; h++)
		for (w = xSpan - h; w <= xSpan + h; w++)
			if (w >= 0 && w < width) {
				d[(height -1 - h) * width + w] = -1;
				count++;
			}

	d[ySpan * width + xSpan] = count;	// fill in center cell

	return 0;
}

int SharpenFP( void *inData, int height, int width);
int SharpenFP( void *inData, int height, int width)
{
    float *d = (float *) inData;
    int h, w, count = 0;
    int xSpan = (width-1) / 2;
    int ySpan = (height-1) / 2;
	
    memset( inData, 0, width * height * sizeof( float ) );
	
	// fill out lower rows
	for (h = 0; h <= ySpan; h++)
		for (w = xSpan - h; w <= xSpan + h; w++)
			if (w >= 0 && w < width) {
				d[h * width + w] = -1.0;
				count++;
			}
	
	// fill out upper rows
	for (h = 0; h < ySpan; h++)
		for (w = xSpan - h; w <= xSpan + h; w++)
			if (w >= 0 && w < width) {
				d[(height -1 - h) * width + w] = -1.0;
				count++;
			}

	d[ySpan * width + xSpan] = (float) count;	// fill in center cell

	return 0;
}

int RLDkernelFP( void *inData, int height, int width );
int RLDkernelFP( void *inData, int height, int width )
{
	// each kernel value = e**(-r**2/sigma**2)
	// r - distance in pixels from center pixel
    float *d = (float*) inData;
	float sigma = *d; 
	float rsq, sigmasq = sigma * sigma;
	float sum = 0.0;
    int h, w;
    int xSpan = (width-1) / 2;
    int ySpan = (height-1) / 2;
	
    for (h = 0; h < height; h++)
        for (w = 0; w < width; w++) {
            rsq = (xSpan - w) * (xSpan - w) + (ySpan - h) * (ySpan - h);
            d[h * height + w] = exp(-rsq / sigmasq);
        }

	for (h = 0; h < height * width; h++)
		sum += d[h];
	
	for (h = 0; h < height * width; h++)
		d[h] /= sum;

	return 0;
}

int RLDkernel( void *inData, int height, int width );
int RLDkernel( void *inData, int height, int width )
{
	float	*tmp;
	int32_t	k, sum = 0;

	// generate kernel in floating point and then convert
	tmp = malloc(height * width * sizeof(float));
	tmp[0] = ((float *) inData)[0];
	RLDkernelFP(tmp, height, width);
	
	for (k = 0; k < height * width; k++) {
		((int16_t *) inData)[k] = (int16_t) (tmp[k] * 512.0 + 0.5);
		sum += ((int16_t *) inData)[k];
	}
	
	free(tmp);
	
	return sum;
}

int GaussianBlur( void *inData, int height, int width );
int GaussianBlur( void *inData, int height, int width )
{
    int16_t *d = (int16_t *) inData;
    int		sum = 0, i;
	
	if (height == 3 && width == 3) {
		d[0] = 1;
		d[1] = 2;
		d[2] = 1;
		d[3] = 2;
		d[4] = 4;
		d[5] = 2;
		d[6] = 1;
		d[7] = 2;
		d[8] = 1;
	}

	if (height == 5 && width == 5) {
		d[0] = 1;
		d[1] = 1;
		d[2] = 2;
		d[3] = 1;
		d[4] = 1;
		d[5] = 1;
		d[6] = 2;
		d[7] = 4;
		d[8] = 2;
		d[9] = 1;
		d[10] = 2;
		d[11] = 4;
		d[12] = 8;
		d[13] = 4;
		d[14] = 2;
		d[15] = 1;
		d[16] = 2;
		d[17] = 4;
		d[18] = 2;
		d[19] = 1;
		d[20] = 1;
		d[21] = 1;
		d[22] = 2;
		d[23] = 1;
		d[24] = 1;
	}
	
	for (i = 0; i < height * width; i++)
		sum += d[i];
	
    return sum;
}        

int GaussianBlurFP( void *inData, int height, int width );
int GaussianBlurFP( void *inData, int height, int width )
{
    float  *d = (float*) inData;
    float	sum = 0.0;
	int		i;
	
	if (height == 3 && width == 3) {
		d[0] = 1;
		d[1] = 2;
		d[2] = 1;
		d[3] = 2;
		d[4] = 4;
		d[5] = 2;
		d[6] = 1;
		d[7] = 2;
		d[8] = 1;
	}

	if (height == 5 && width == 5) {
		d[0] = 1;
		d[1] = 1;
		d[2] = 2;
		d[3] = 1;
		d[4] = 1;
		d[5] = 1;
		d[6] = 2;
		d[7] = 4;
		d[8] = 2;
		d[9] = 1;
		d[10] = 2;
		d[11] = 4;
		d[12] = 8;
		d[13] = 4;
		d[14] = 2;
		d[15] = 1;
		d[16] = 2;
		d[17] = 4;
		d[18] = 2;
		d[19] = 1;
		d[20] = 1;
		d[21] = 1;
		d[22] = 2;
		d[23] = 1;
		d[24] = 1;
	}
	
	for (i = 0; i < height * width; i++)
		sum += d[i];
	
	for (i = 0; i < height * width; i++)
		d[i] /= sum;
	
    return 0;
}        

int MotionBlurFP( void *inData, int height, int width );
int MotionBlurFP( void *inData, int height, int width )
{
    float *d = (float*) inData;
    int x, y, h;
    int xSpan = (width-1) / 2;
    int ySpan = (height-1) / 2;
    float slope = (float) ySpan / (float) xSpan;
	float sum = 0.0;
    
    //zero the buffer
    memset( inData, 0, height * width * sizeof( float ) );

    //Set the center to 1
    d[ width * ySpan + xSpan] = 1.0f;
    for( x = 1; x <= xSpan; x++ )
    {
        float fy =  slope * (float) x;
        float fract = fy - floor( fy );
        float distance = (float) x * (float) x + fy * fy + 1.0f;
        y = fy;
        d[ (ySpan - y) * width + xSpan + x ] = (1.0f - fract) / distance;
        if( y < ySpan )
            d[ (ySpan - y - 1) * width + xSpan + x ] = fract / distance;

    }
    
	for (h = 0; h < height * width; h++)
		sum += d[h];
	
	for (h = 0; h < height * width; h++)
		d[h] /= sum;

    return 1;
}

int MotionBlur( void *inData, int height, int width );
int MotionBlur( void *inData, int height, int width )
{
    short *d = (short*) inData;
    int x, y;
    int xSpan = (width-1) / 2;
    int ySpan = (height-1) / 2;
    float slope = (float) ySpan / (float) xSpan;
    
    //zero the buffer
    memset( inData, 0, height * width * sizeof( short ) );

    //Set the center to 1
    d[ width * ySpan + xSpan] = 16384;
    for( x = 1; x <= xSpan; x++ )
    {
        float fy =  slope * (float) x;
        float fract = fy - floor( fy );
        float distance = (float) x * (float) x + fy * fy + 1.0f;
        y = fy;
        d[ (ySpan - y) * width + xSpan + x ] = 16384.0 * (1.0f - fract) / distance;
        if( y < ySpan )
            d[ (ySpan - y - 1) * width + xSpan + x ] = 16384.0f * fract / distance;
    }
    
    return 16384;
}

int Blur( void *inData, int height, int width );
int Blur( void *inData, int height, int width )
{
    short *d = (short*) inData;
    int sum = 0;
    int x, y, value;
    
    for( x = 0; x <= width / 2; x++ )
    {
        for( y = 0; y <= height / 2; y++ )
        {
            value = x + y - width / 2;
            if( value >= 0 )
                value = 1 << ( value );
            else
                value = 0;
                
            d[ y * width + x ] = value;
            d[ y * width + width - x - 1 ] = value;
            d[ ( height - y - 1) * width + x ] = value;
            d[ ( height - y - 1) * width + width - x - 1 ] = value;
        }
    }
    
    for( x = 0; x < width * height; x ++ )
	sum += d[x];
        
    return sum;
        

	return 0;
}

int BlurFP( void *inData, int height, int width );
int BlurFP( void *inData, int height, int width )
{
    float *d = (float*) inData;
	float sum = 0.0;
	int		h;
	
	if ( height == 3 && width == 3 )
    {
		*d++ = 1.0/16.0;
		*d++ = 2.0/16.0;
		*d++ = 1.0/16.0;
		*d++ = 2.0/16.0;
		*d++ = 4.0/16.0;
		*d++ = 2.0/16.0;
		*d++ = 1.0/16.0;
		*d++ = 2.0/16.0;
		*d++ = 1.0/16.0;
		d = (float*) inData;
		
		for (h = 0; h < height * width; h++)
			sum += d[h];
		
		for (h = 0; h < height * width; h++)
			d[h] /= sum;

	}
	else if ( height == 5 && width == 5 )
	{
		*d++ = 0.0;
		*d++ = 1.0/48.0;
		*d++ = 2.0/48.0;
		*d++ = 1.0/48.0;
		*d++ = 0.0;
		*d++ = 1.0/48.0;
		*d++ = 2.0/48.0;
		*d++ = 4.0/48.0;
		*d++ = 2.0/48.0;
		*d++ = 1.0/48.0;
		*d++ = 2.0/48.0;
		*d++ = 4.0/48.0;
		*d++ = 8.0/48.0;
		*d++ = 4.0/48.0;
		*d++ = 2.0/48.0;
		*d++ = 1.0/48.0;
		*d++ = 2.0/48.0;
		*d++ = 4.0/48.0;
		*d++ = 2.0/48.0;
		*d++ = 1.0/48.0;
		*d++ = 0.0;
		*d++ = 1.0/48.0;
		*d++ = 2.0/48.0;
		*d++ = 1.0/48.0;
		*d++ = 0.0;

		d = (float*) inData;
		for (h = 0; h < height * width; h++)
			sum += d[h];
		
		for (h = 0; h < height * width; h++)
			d[h] /= sum;

	}

	return 0;
}

int gammaTable_3_4( void *inData, int height, int width );
int gammaTable_3_4( void *inData, int height, int width )
{
    memset( inData, 0, width * height * sizeof( uint8_t ) );

    if( width > 0 && height >= 256 )
    {
        uint8_t *d = (uint8_t*) inData;
        int i;
    
        for( i = 0; i < 256; i++ )
        {
            double value = pow( (double) i / 255.0, 3.0/4.0);
            d[ i * width ] = (uint8_t)(value * 255.0 + 0.5);        
        }
    }
    
    return 0;
}

int gammaTable_4_3( void *inData, int height, int width );
int gammaTable_4_3( void *inData, int height, int width )
{
    memset( inData, 0, width * height * sizeof( uint8_t ) );

    if( width > 0 && height >= 256 )
    {
        uint8_t *d = (uint8_t*) inData;
        int i;
    
        for( i = 0; i < 256; i++ )
        {
            double value = pow( (double) i / 255.0, 4.0/3.0);
            d[ i * width ] = (uint8_t)(value * 255.0 + 0.5);        
        }
    }

    return 0;
}

int ClipFP( void *inData, int height, int width );
int ClipFP( void *inData, int height, int width )
{
    float *d = (float*) inData;
    
    if( NULL == inData )
        return 0;
        
    memset( inData, 0, width * height * sizeof( float ) );
    
    d[0] = 0.1f;
    if( width > 1 )
        d[1] = 0.9f;
        
    return 0;
}

int DefaultGeometryKernel( void *inData, int height, int width );
int DefaultGeometryKernel( void *inData, int height, int width )
{
    TransformInfo *info = inData;
    
    info->xShear = 0.0f;			//degrees
    info->yShear = 0.0f;			//degrees
    info->xTranslation = 0.0f;		//fraction of the image width -1.0 ... 1.0
    info->yTranslation = 0.0f;		//fraction of the image width -1.0 ... 1.0
    info->xScale = 1.0f;			//log2 scale
    info->yScale = 1.0f;			//log2 scale
    info->rotate = 0.0f;
    info->a = info->r = info->g = info->b = 1.0f;		//background color
    info->transformMatrix.a = 1.0f;
    info->transformMatrix.b = 0.0f;
    info->transformMatrix.c = 0.0f;
    info->transformMatrix.d = 1.0f;
    info->transformMatrix.tx = 0.0f;
    info->transformMatrix.ty = 0.0f;
    info->quitting = NO;
    
    return 0;
}

int DefaultMMultKernel( void *inData, int height, int width );
int DefaultMMultKernel( void *inData, int height, int width )
{
    int16_t *info = inData;
    
    memset( info, 0, 16 * sizeof( *info) );
    info[0] = 1L << 13;
    info[5] = 1L << 13;
    info[10] = 1L << 13;
    info[15] = 1L << 13;
    
    return 0;
}

int DefaultMMultKernelF( void *inData, int height, int width );
int DefaultMMultKernelF( void *inData, int height, int width )
{
    float *info = inData;
    
    memset( info, 0, 16 * sizeof( *info) );
    info[0] = 1.0f;
    info[5] = 1.0f;
    info[10] = 1.0f;
    info[15] = 1.0f;
    
    return 0;
}



//Specify defaults for Filter kernels

const unsigned char kKernelTypeSizes[] = { 	0, 	/* no kernel type */
                                            0, 	/* no kernel data */
                                            sizeof( int8_t),
                                            sizeof( uint8_t),
                                            sizeof( int16_t),
                                            sizeof( uint16_t),
                                            sizeof( int32_t),
                                            sizeof( uint32_t),
                                            sizeof( float),
                                            sizeof( double ),
                                            sizeof( TransformInfo ),
											0,
											sizeof( float)
										  };


//Kernels.
// These are used to init the default values for kernels. The user can change the 
// kernel, but the changes will be applied to a copy. 

//Morphology 
#pragma mark Morphology kernels   

struct
{
    int 		count;
    KernelInitFunction	zeros;		
}morphologyInitFunctions = { 
                                1,
                                {
                                    ZeroFunc,
                                    ZeroFuncFP,
                                    3,
                                    3,
                                    kUInt8KernelType,
                                    kFloatKernelType,
                                    @"All Zeros"
                                }
                            };
    

//Convolution
#pragma mark Convolution kernels   

struct
{
    int 		count;
    KernelInitFunction	emboss;		
    KernelInitFunction	average;		
    KernelInitFunction	blur;
    KernelInitFunction  motionBlur;		
    KernelInitFunction  Sharpen;		
    KernelInitFunction  GaussianBlur;		
    KernelInitFunction  RLDkernel;		
}convolutionInitFunctions = { 
                                7,
                                {
                                    Blur,
                                    BlurFP,
                                    5,
                                    5,
                                    kSInt16KernelType,
                                    kFloatKernelType,
                                    @"Blur"
                                },
                                {
                                    Emboss,
                                    EmbossFP,
                                    3,
                                    3,
                                    kSInt16KernelType,
                                    kFloatKernelType,
                                    @"Emboss"
                                },
                                {
                                    Median,
                                    MedianFP,
                                    3,
                                    3,
                                    kSInt16KernelType,
                                    kFloatKernelType,
                                    @"Average"
                                },
                                {
                                    MotionBlur,
                                    MotionBlurFP,
                                    3,
                                    3,
                                    kSInt16KernelType,
                                    kFloatKernelType,
                                    @"Motion Blur"
                                },
                                {
                                    Sharpen,
                                    SharpenFP,
                                    3,
                                    3,
                                    kSInt16KernelType,
                                    kFloatKernelType,
                                    @"Sharpen"
                                },
                                {
                                    GaussianBlur,
                                    GaussianBlurFP,
                                    5,
                                    5,
                                    kSInt16KernelType,
                                    kFloatKernelType,
                                    @"Gaussian Blur"
                                },
                                {
                                    RLDkernel,
                                    RLDkernelFP,
                                    5,
                                    5,
                                    kSInt16KernelType,
                                    kFloatKernelType,
                                    @"Richardson-Lucy"
                                }
                            };
    

//Clipping
struct
{
    int 		count;
    KernelInitFunction	clip;		
}clipInitFunctions = { 1,
                                {
                                    NULL,
                                    ClipFP,
                                    1,
                                    2,
                                    kNoKernelData,
                                    kFloatKernelType,
                                    @"Clip Limits (min, max)"
                                }
                            };
                            
//Table lookup
struct
{
    int 		count;
    KernelInitFunction	gamma1_33;		
    KernelInitFunction	gamma0_75;		
}lookupFunctions = { 2,
                                {
                                    gammaTable_4_3,
                                    NULL,
                                    256,
                                    1,
                                    kUInt8KernelType,
                                    kNoKernelData,
                                    @"gamma 4/3"
                                },
                                {
                                    gammaTable_3_4,
                                    NULL,
                                    256,
                                    1,
                                    kUInt8KernelType,
                                    kNoKernelData,
                                    @"gamma 3/4"
                                }
                            };

//Geometry Filters
struct
{
    int 		count;
    KernelInitFunction	geometryDefault;		
}geometryFunctions = { 1,
                        {
                            DefaultGeometryKernel,
                            DefaultGeometryKernel,
                            1,
                            1,
                            kGeometryKernelType,
                            kGeometryKernelType,
                            @"(Geometry Data)"
                        }
                    };

//Matrix multiply
struct
{
    int 		count;
    KernelInitFunction	mmultDefault;		
}mmultFunctions = { 1,
                        {
                            DefaultMMultKernel,
                            DefaultMMultKernelF,
                            4,
                            4,
                            kSInt16KernelType,
                            kFloatKernelType,
                            @"Multiplication matrix"
                        }
                    };

struct
{
    int 		count;
    KernelInitFunction	mmultDefault;		
}nonlinearMMultFunctions = { 1,
                        {
                            DefaultMMultKernelF,
                            DefaultMMultKernelF,
                            4,
                            4,
                            kFloatKernelType,
                            kFloatKernelType,
                            @"Multiplication matrix"
                        }
                    };


//Specify the filters 
FilterInfo	testFilters[] = 
    {
        { InvertFilter,	 InvertFilterFP, InvertFilter_ARGB, InvertFilterFP_ARGB, @"Invert", kNoFilterFlags, NULL },
        { BlackFilter, BlackFilterFP, BlackFilter_ARGB, BlackFilterFP_ARGB, @"Black", kNoFilterFlags, NULL },
        { CopyFilter, CopyFilterFP, CopyFilter_ARGB, CopyFilterFP_ARGB, @"memcpy", kNoFilterFlags, NULL },
        { NULL, NULL, NULL, RedFilterFP_ARGB, @"red", kNoFilterFlags, NULL },
        { NULL, NULL, NULL, GreenFilterFP_ARGB, @"green", kNoFilterFlags, NULL },
        { NULL, NULL, NULL, BlueFilterFP_ARGB, @"blue", kNoFilterFlags, NULL }
    };


FilterInfo	morphologyFilters[] = 
    {// int scalar	FP scalar	int scalar ARGB		FP scalar ARGB		func name	data format	Init Functions		
     // ----------	---------	---------------		--------------		---------	-----------	--------------
        { DilateFilter,	DilateFilterFP, DilateFilter_ARGB,	DilateFilterFP_ARGB,	@"Dilate",	kNoFilterFlags, (KernelInitFunctionList*) &morphologyInitFunctions }, 	
        { ErodeFilter,	ErodeFilterFP,	ErodeFilter_ARGB,	ErodeFilterFP_ARGB, 	@"Erode",	kNoFilterFlags, (KernelInitFunctionList*) &morphologyInitFunctions }, 	
        { MaxFilter,	MaxFilterFP, 	MaxFilter_ARGB,		MaxFilterFP_ARGB, 	@"Max",		kNoFilterFlags, (KernelInitFunctionList*) &morphologyInitFunctions }, 	
        { MinFilter,	MinFilterFP, 	MinFilter_ARGB,		MinFilterFP_ARGB, 	@"Min",		kNoFilterFlags, (KernelInitFunctionList*) &morphologyInitFunctions } 	
    };
                                
FilterInfo	convolutionFilters[] = 
    {// int scalar		FP scalar		int scalar ARGB		FP scalar ARGB		func name			data format		Init Functions			
     // ----------		---------		---------------		--------------		---------			-----------		-------------------	
        { Convolution,	ConvolutionFP,	Convolution_ARGB,	ConvolutionFP_ARGB,	@"Convolution",		kInitFilter, 	(KernelInitFunctionList*) &convolutionInitFunctions }, 	
        { ConvolutionBias,	ConvolutionBiasFP,	ConvolutionBias_ARGB,	ConvolutionBiasFP_ARGB,	@"Convolution with Bias",		kInitFilter, 	(KernelInitFunctionList*) &convolutionInitFunctions }, 	
        { NULL, NULL, ConvolutionMultiKernel,	ConvolutionMultiKernelFP,	@"Multi-Kernel Convolution",	kNoFilterFlags, 	(KernelInitFunctionList*) &convolutionInitFunctions }, 	
        { ConvolutionBox,	NULL,		ConvolutionBox_ARGB,	NULL,		@"Box Convolution",		kNoFilterFlags, 	(KernelInitFunctionList*) &convolutionInitFunctions }, 	
        { ConvolutionTent,	NULL,		ConvolutionTent_ARGB,	NULL,		@"Tent Convolution",	kNoFilterFlags, 	(KernelInitFunctionList*) &convolutionInitFunctions }, 	
        { RichardsonLucy, RichardsonLucyFP, RichardsonLucy_ARGB, RichardsonLucyFP_ARGB, @"Richardson-Lucy", kNoFilterFlags, (KernelInitFunctionList*) &convolutionInitFunctions }
    };

FilterInfo	geometryFilters[] =
    {
        { ShearXFilter, 	ShearXFilterFP,	ShearXFilter_ARGB, 	ShearXFilterFP_ARGB,	@"Horiz Shear...",	kTranslateX | kShearX | kScaleX | kDisplaysPane, 	(KernelInitFunctionList*) &geometryFunctions },
        { ShearYFilter, 	ShearYFilterFP,	ShearYFilter_ARGB, 	ShearYFilterFP_ARGB,	@"Vert Shear...",	kTranslateY | kShearY | kScaleY | kDisplaysPane, 	(KernelInitFunctionList*) &geometryFunctions },
        { RotateFilter, 	RotateFilterFP,	RotateFilter_ARGB, 	RotateFilterFP_ARGB,	@"Rotate...",	 kRotate | kDisplaysPane,  	(KernelInitFunctionList*) &geometryFunctions },
        { ScaleFilter, 		ScaleFilterFP,	ScaleFilter_ARGB, 	ScaleFilterFP_ARGB,	@"Scale...",	kScaleX | kScaleY | kDisplaysPane, 	(KernelInitFunctionList*) &geometryFunctions },
        { AffineTransformFilter, AffineTransformFilterFP, AffineTransformFilter_ARGB, 	AffineTransformFilterFP_ARGB,	@"Warp Affine...",	kTranslateX | kTranslateY | kRotate | kScaleX | kScaleY | kShearX | kShearY | kDisplaysPane, 	(KernelInitFunctionList*) &geometryFunctions },
        { ReflectXFilter, 	ReflectXFilterFP, ReflectXFilter_ARGB, 	ReflectXFilterFP_ARGB,	@"Reflect Horiz",	kNoFilterFlags, 	NULL },
        { ReflectYFilter, 	ReflectYFilterFP, ReflectYFilter_ARGB, 	ReflectYFilterFP_ARGB,	@"Reflect Vert",	kNoFilterFlags, 	NULL },
        { Rotate90Filter,	Rotate90FilterFP, Rotate90Filter_ARGB,	Rotate90FilterFP_ARGB, 	@"Rotate 90 degrees",	kRotate | kDisplaysPane,		(KernelInitFunctionList*) &geometryFunctions },
        { NULL, NULL, MatrixMultiply_ARGB8888, MatrixMultiply_ARGBFFFF, @"Matrix Multiply", kNoFilterFlags, (KernelInitFunctionList*) &mmultFunctions }
    };

FilterInfo	histogramFilters[] =
    {
        { Histogram, 	HistogramFP,	Histogram_ARGB, 	HistogramFP_ARGB,	@"Histogram",	kNoFilterFlags, 	NULL },
        { Histogram_Equalization, 	Histogram_EqualizationFP,	Histogram_Equalization_ARGB, 	Histogram_EqualizationFP_ARGB,	@"Hist Equalization",	kNoFilterFlags, 	NULL },
        { Histogram_Specification, 	Histogram_SpecificationFP,	Histogram_Specification_ARGB, 	Histogram_SpecificationFP_ARGB,	@"Hist Specification",	kNoFilterFlags, 	NULL },
        { Histogram_Contrast_Stretch, 	Histogram_Contrast_StretchFP,	Histogram_Contrast_Stretch_ARGB, 	Histogram_Contrast_StretchFP_ARGB,	@"Contrast Stretch",	kNoFilterFlags, 	NULL },
        { Histogram_Ends_In_Contrast_Stretch, 	Histogram_Ends_In_Contrast_StretchFP,	Histogram_Ends_In_Contrast_Stretch_ARGB, 	Histogram_Ends_In_Contrast_StretchFP_ARGB,	@"Ends-In Stretch",	kNoFilterFlags, 	NULL }
    };

FilterInfo	alphaFilters[] =
    {
        { NULL, NULL, NULL, NULL, @"Alpha Compositing...", kDisplaysPane, NULL },
        { NULL, NULL, NULL, NULL, @"Premultiplied Alpha Compositing...", kDisplaysPane | kIsPremultiplied, NULL },
        { NULL, NULL, NULL, NULL, @"Premultiplied Constant Alpha Compositing...", kDisplaysPane | kIsPremultiplied, NULL },
        { PremultiplyData, PremultiplyDataFP, PremultiplyData_ARGB, PremultiplyDataFP_ARGB, @"Premultiply Data...", kNoFilterFlags, NULL },
        { NULL, NULL, NULL, NULL, @"Unpremultiply Data...", kDisplaysPane, NULL },
        { NULL, NULL, NULL, NULL, @"Nonpre to Pre Data...", kDisplaysPane, NULL },
//        { ClipToAlpha, ClipToAlphaFP, ClipToAlpha_ARGB, ClipToAlphaFP_ARGB, @"Clip to Alpha...", kNoFilterFlags, NULL }
    };
    
FilterInfo	convertFilters[] =
    {
        { Convert_Planar8ToPlanarF, NULL, NULL, NULL, @"Convert 8 -> F", kDestDataTypePlanarF, NULL },
        { NULL, Convert_PlanarFToPlanar8, NULL, NULL, @"Convert F -> 8", kDestDataTypePlanar8, NULL },
        { Convert_Planar8ToARGB8888, NULL, NULL, NULL, @"Convert 8 -> 8888", kDestDataTypeARGB8888, NULL },
        { NULL, NULL, Convert_ARGB8888ToPlanar8, NULL, @"Convert 8888 -> 8", kDestDataTypePlanar8, NULL },
		{ NULL, Convert_PlanarFToARGBFFFF, NULL, NULL, @"Convert F -> FFFF", kDestDataTypeARGBFFFF, NULL },
		{ NULL, NULL, NULL, Convert_ARGBFFFFToPlanarF, @"Convert FFFF -> F", kDestDataTypePlanarF, NULL },
        { NULL, Convert_PlanarFTo16S, NULL, NULL, @"Convert F <-> 16S", kDestDataTypePlanarF, NULL },
        { NULL, Convert_PlanarFTo16U, NULL, NULL, @"Convert F <-> 16U", kDestDataTypePlanarF, NULL },
        { NULL, Convert_PlanarFTo16F, NULL, NULL, @"Convert F <-> 16F", kDestDataTypePlanarF, NULL },
        { Convert_Planar8To16U, NULL, NULL, NULL, @"Convert 8 <-> 16U", kDestDataTypePlanar8, NULL },
        { Convert_Planar8To888, NULL, NULL, NULL, @"Convert 8 <-> 888", kDestDataTypePlanar8, NULL },
        { NULL, NULL, Convert_ARGB8888To888, NULL, @"Convert 8888 <-> 888", kDestDataTypeARGB8888, NULL },
        { NULL, Convert_PlanarFToFFF, NULL, NULL, @"Convert F <-> FFF", kDestDataTypePlanarF, NULL },
        { Convert_Planar8To565, NULL, NULL, NULL, @"Convert 8 <-> 565", kDestDataTypePlanar8, NULL },
		{ Convert_Planar8To1555, NULL, NULL, NULL, @"Convert 8 <-> 1555", kDestDataTypePlanar8, NULL },
		{ NULL, NULL, Convert_ARGB8888To1555, NULL, @"Convert 8888 <-> 1555", kDestDataTypeARGB8888, NULL },
        { NULL, NULL, Convert_ARGB8888To565, NULL, @"Convert 8888 <-> 565", kDestDataTypeARGB8888, NULL },
        { NULL, NULL, Flatten_ARGB8888To888, NULL, @"Flatten 8888 <-> 888", kDestDataTypeARGB8888, NULL },
        { NULL, NULL, NULL, Flatten_ARGBFFFFToFFF, @"Flatten FFFF <-> FFF", kDestDataTypePlanarF , NULL },
		{ OverwriteChannelsWithScalar_Planar8, OverwriteChannelsWithScalar_PlanarF, OverwriteChannelsWithScalar_ARGB8888, OverwriteChannelsWithScalar_ARGBFFFF, @"Overwrite w/ Scalar", kNoFilterFlags, NULL },
		{ NULL, NULL, OverwriteChannels_ARGB8888, OverwriteChannels_ARGBFFFF, @"Overwrite Channels", kNoFilterFlags, NULL },
		{ NULL, NULL, Convert_BufferFill8888, Convert_BufferFillFFFF, @"Buffer fill", kNoFilterFlags, NULL }
    };

FilterInfo	HSBFilters[] =
    {
        { NULL, NULL, MatrixMultiply2_ARGB8888, MatrixMultiply2_ARGBFFFF, @"HSB Example", kDisplaysPane, (KernelInitFunctionList*) &mmultFunctions }
    };
    
FilterInfo	transformFilters[] =
    {
		 { Lookup, Lookup, Lookup, Lookup, @"Gamma Corr... 8->F", kDisplaysPane, NULL },
		 { Lookup, Lookup, Lookup, Lookup, @"Gamma Corr... F->8", kDisplaysPane, NULL },
		 { Lookup, Lookup, Lookup, Lookup, @"Gamma Corr... float", kDisplaysPane, NULL }
    };


//Put it all together in the master struct. Entries here define the high level filter category menus.
FilterList 	filterLists[] = 
    {
        { test, testFilters,		@"Simple Test Filters",	sizeof( testFilters ) / sizeof( FilterInfo ) },
        { morphology, morphologyFilters,	@"Morphology Filters",	sizeof( morphologyFilters ) / sizeof( FilterInfo ) },
        { convolution, convolutionFilters,	@"Convolution Filters",	sizeof( convolutionFilters ) / sizeof( FilterInfo ) },
        { geometry, geometryFilters,	@"Geometry Filters",	sizeof( geometryFilters ) / sizeof( FilterInfo ) },
        { histogram, histogramFilters,	@"Histogram Filters",	sizeof( histogramFilters ) / sizeof( FilterInfo ) },
        { alphaComposite, alphaFilters, @"Alpha Compositing",	sizeof( alphaFilters ) / sizeof( FilterInfo ) },
        { convert, (FilterInfo *) convertFilters,	@"Format Conversion",	sizeof( convertFilters ) / sizeof( FilterInfo ) },
        { hsb, HSBFilters,	@"HSB Example",	sizeof( HSBFilters ) / sizeof( FilterInfo ) },
        { transform, transformFilters, @"Transform Filters", sizeof( transformFilters ) / sizeof( FilterInfo ) }
    };
                                
int		kListCount = sizeof( filterLists ) / sizeof( FilterList );

