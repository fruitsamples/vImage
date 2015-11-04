/*
 *  ConvolutionFilters.c
 *  Tableau
 *
 *  Created by Ian Ollmann on Wed Nov 06 2002.
 *	Modified by Robert Murley, Sep 2003.
 *  Copyright (c) 2003 Apple Computer, Inc. All rights reserved.
 *
 */

#import "ConvolutionFilters.h"

int Convolution( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    Pixel_8		backcolor = UCHAR_MAX * params->backgroundColor[params->colorChannel];
    vImage_Error err;
    
    err = vImageConvolve_Planar8(	src, 					// const vImage_Buffer *src
                                    dest,					// const vImage_Buffer *dest, 
                                    NULL,					// temporary buffer
                                    params->srcOffsetToROI_X, 
                                    params->srcOffsetToROI_Y,  
                                    params->kernel,			//const signed int *kernel, 
                                    params->kernel_height, 	//unsigned int kernel_height, 
                                    params->kernel_width,	//unsigned int kernel_width,
                                    params->divisor,		// divisor for normalization
                                    backcolor,						// background color
                                    flags | params->edgeStyle		//vImage_Flags flags 
                                );
    return err;
}


int ConvolutionFP( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    Pixel_8		backcolor = params->backgroundColor[params->colorChannel];
    vImage_Error err;

    err = vImageConvolve_PlanarF(	src,
                                    dest,
                                    NULL,
                                    params->srcOffsetToROI_X, 
                                    params->srcOffsetToROI_Y,
                                    params->kernel, 
                                    params->kernel_height,
                                    params->kernel_width,
                                    backcolor,
                                    flags | params->edgeStyle
                                );
    
    return err;
}


int Convolution_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
	Pixel_8 edgeFill[4];
    vImage_Error err;
    
    edgeFill[0] = UCHAR_MAX * params->backgroundColor[0];
    edgeFill[1] = UCHAR_MAX * params->backgroundColor[1];
    edgeFill[2] = UCHAR_MAX * params->backgroundColor[2];
    edgeFill[3] = UCHAR_MAX * params->backgroundColor[3];

    err = vImageConvolve_ARGB8888(	src,
                                    dest,
                                    NULL,
                                    params->srcOffsetToROI_X, 
                                    params->srcOffsetToROI_Y,
                                    params->kernel, 
                                    params->kernel_height,
                                    params->kernel_width,
                                    params->divisor,
                                    edgeFill,
                                    flags | params->edgeStyle
                                );

    return err;
}


int ConvolutionFP_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
	float edgeFill[4];
    vImage_Error err;

    edgeFill[0] = params->backgroundColor[0];
    edgeFill[1] = params->backgroundColor[1];
    edgeFill[2] = params->backgroundColor[2];
    edgeFill[3] = params->backgroundColor[3];

    err = vImageConvolve_ARGBFFFF(	src,
                                    dest,
                                    NULL, 
                                    params->srcOffsetToROI_X,
                                    params->srcOffsetToROI_Y,
                                    params->kernel, 
                                    params->kernel_height,
                                    params->kernel_width,
                                    edgeFill,
                                    flags | params->edgeStyle
                                );
    
    return err;
}

int ConvolutionBias( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    Pixel_8		backcolor = UCHAR_MAX * params->backgroundColor[params->colorChannel];
	int32_t		bias = params->bias[0] * 255.0;
    vImage_Error err;
    
    err = vImageConvolveWithBias_Planar8(	src, 					// const vImage_Buffer *src
                                    dest,					// const vImage_Buffer *dest, 
                                    NULL,					// temporary buffer
                                    params->srcOffsetToROI_X, 
                                    params->srcOffsetToROI_Y,  
                                    params->kernel,			//const signed int *kernel, 
                                    params->kernel_height, 	//unsigned int kernel_height, 
                                    params->kernel_width,	//unsigned int kernel_width,
                                    params->divisor,		// divisor for normalization
									bias,
                                    backcolor,						// background color
                                    flags | params->edgeStyle		//vImage_Flags flags 
                                );
    return err;
}

int ConvolutionBiasFP( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    Pixel_F		backcolor = (float) params->backgroundColor[params->colorChannel];
    vImage_Error err;

    err = vImageConvolveWithBias_PlanarF(	src,
                                    dest,
                                    NULL,
                                    params->srcOffsetToROI_X, 
                                    params->srcOffsetToROI_Y,
                                    params->kernel, 
                                    params->kernel_height,
                                    params->kernel_width,
									params->bias[0],
                                    backcolor,
                                    flags | params->edgeStyle
                                );
    
    return err;
}

int ConvolutionBias_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
	Pixel_8 edgeFill[4];
	int32_t		bias = params->bias[0] * 255.0;
    vImage_Error err;
    
    edgeFill[0] = UCHAR_MAX * params->backgroundColor[0];
    edgeFill[1] = UCHAR_MAX * params->backgroundColor[1];
    edgeFill[2] = UCHAR_MAX * params->backgroundColor[2];
    edgeFill[3] = UCHAR_MAX * params->backgroundColor[3];

    err = vImageConvolveWithBias_ARGB8888(	src,
                                    dest,
                                    NULL,
                                    params->srcOffsetToROI_X, 
                                    params->srcOffsetToROI_Y,
                                    params->kernel, 
                                    params->kernel_height,
                                    params->kernel_width,
                                    params->divisor,
									bias,
                                    edgeFill,
                                    flags | params->edgeStyle
                                );

    return err;
}

int ConvolutionBiasFP_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
	float edgeFill[4];
    vImage_Error err;

    edgeFill[0] = params->backgroundColor[0];
    edgeFill[1] = params->backgroundColor[1];
    edgeFill[2] = params->backgroundColor[2];
    edgeFill[3] = params->backgroundColor[3];

    err = vImageConvolveWithBias_ARGBFFFF(	src,
                                    dest,
                                    NULL, 
                                    params->srcOffsetToROI_X,
                                    params->srcOffsetToROI_Y,
                                    params->kernel, 
                                    params->kernel_height,
                                    params->kernel_width,
									params->bias[0],
                                    edgeFill,
                                    flags | params->edgeStyle
                                );
    
    return err;
}

int ConvolutionMultiKernel( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
	Pixel_8 edgeFill[4];
	int32_t	bias[4] = { 0, 0, 0, 0 };
	int16_t	*kernels[4], *kbuffer;
	int32_t	divisors[4] = { params->divisor, params->divisor, params->divisor, params->divisor };
    vImage_Error err;
	int			 i;
    
    edgeFill[0] = UCHAR_MAX * params->backgroundColor[0];
    edgeFill[1] = UCHAR_MAX * params->backgroundColor[1];
    edgeFill[2] = UCHAR_MAX * params->backgroundColor[2];
    edgeFill[3] = UCHAR_MAX * params->backgroundColor[3];
	
	// allocate space for identity kernels
	kbuffer = malloc( params->kernel_height * params->kernel_width * sizeof(int16_t) );
	for (i = 0; i < params->kernel_height * params->kernel_width; i++ )
		kbuffer[i] = 0;
	kbuffer[params->kernel_height * params->kernel_width / 2] = params->divisor;
	kernels[0] = kbuffer;
	kernels[1] = kbuffer;
	kernels[2] = kbuffer;
	kernels[3] = kbuffer;
	
	kernels[params->sourceOverwrite] = params->kernel;

    err = vImageConvolveMultiKernel_ARGB8888(	
									src,
                                    dest,
                                    NULL,
                                    params->srcOffsetToROI_X, 
                                    params->srcOffsetToROI_Y,
                                    (const int16_t **) kernels, 
                                    params->kernel_height,
                                    params->kernel_width,
                                    divisors,
									bias,
                                    edgeFill,
                                    flags | params->edgeStyle
                                );

	free(kbuffer);
    return err;
}

int ConvolutionMultiKernelFP( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
	Pixel_F edgeFill[4];
	Pixel_FFFF	bias = { 0, 0, 0, 0 };
	float	*kernels[4], *kbuffer;
    vImage_Error err;
    
    edgeFill[0] = params->backgroundColor[0];
    edgeFill[1] = params->backgroundColor[1];
    edgeFill[2] = params->backgroundColor[2];
    edgeFill[3] = params->backgroundColor[3];

	
	// allocate space for other kernels
	kbuffer = malloc( params->kernel_height * params->kernel_width * sizeof(float) );
	kbuffer[params->kernel_height * params->kernel_width / 2] = 1.0;
	kernels[0] = kbuffer;
	kernels[1] = kbuffer;
	kernels[2] = kbuffer;
	kernels[3] = kbuffer;
	
	kernels[params->sourceOverwrite] = params->kernel;

    err = vImageConvolveMultiKernel_ARGBFFFF(	
									src,
                                    dest,
                                    NULL,
                                    params->srcOffsetToROI_X, 
                                    params->srcOffsetToROI_Y,
                                    (const float **) kernels, 
                                    params->kernel_height,
                                    params->kernel_width,
									bias,
                                    edgeFill,
                                    flags | params->edgeStyle
                                );

	free(kbuffer);
    return err;
}


int ConvolutionBox( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    Pixel_8		backcolor = UCHAR_MAX * params->backgroundColor[params->colorChannel];
    vImage_Error err;
    
    err = vImageBoxConvolve_Planar8(src, 					// const vImage_Buffer *src
                                    dest,					// const vImage_Buffer *dest, 
                                    NULL,					// temporary buffer
                                    params->srcOffsetToROI_X, 
                                    params->srcOffsetToROI_Y,  
                                    params->kernel_height, 	//unsigned int kernel_height, 
                                    params->kernel_width,	//unsigned int kernel_width,
                                    backcolor,						// background color
                                    flags | params->edgeStyle		//vImage_Flags flags 
                                );
    return err;
}

int ConvolutionBox_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
	Pixel_8 edgeFill[4];
    vImage_Error err;
    
    edgeFill[0] = UCHAR_MAX * params->backgroundColor[0];
    edgeFill[1] = UCHAR_MAX * params->backgroundColor[1];
    edgeFill[2] = UCHAR_MAX * params->backgroundColor[2];
    edgeFill[3] = UCHAR_MAX * params->backgroundColor[3];

    err = vImageBoxConvolve_ARGB8888(	src,
                                    dest,
                                    NULL,
                                    params->srcOffsetToROI_X, 
                                    params->srcOffsetToROI_Y,
                                    params->kernel_height,
                                    params->kernel_width,
                                    edgeFill,
                                    flags | params->edgeStyle
                                );

    return err;
}

int ConvolutionTent( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    Pixel_8		backcolor = UCHAR_MAX * params->backgroundColor[params->colorChannel];
    vImage_Error err;
    
    err = vImageTentConvolve_Planar8(src, 					// const vImage_Buffer *src
                                    dest,					// const vImage_Buffer *dest, 
                                    NULL,					// temporary buffer
                                    params->srcOffsetToROI_X, 
                                    params->srcOffsetToROI_Y,  
                                    params->kernel_height, 	//unsigned int kernel_height, 
                                    params->kernel_width,	//unsigned int kernel_width,
                                    backcolor,						// background color
                                    flags | params->edgeStyle		//vImage_Flags flags 
                                );
    return err;
}

int ConvolutionTent_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
	Pixel_8 edgeFill[4];
    vImage_Error err;
    
    edgeFill[0] = UCHAR_MAX * params->backgroundColor[0];
    edgeFill[1] = UCHAR_MAX * params->backgroundColor[1];
    edgeFill[2] = UCHAR_MAX * params->backgroundColor[2];
    edgeFill[3] = UCHAR_MAX * params->backgroundColor[3];

    err = vImageTentConvolve_ARGB8888(	src,
                                    dest,
                                    NULL,
                                    params->srcOffsetToROI_X, 
                                    params->srcOffsetToROI_Y,
                                    params->kernel_height,
                                    params->kernel_width,
                                    edgeFill,
                                    flags | params->edgeStyle
                                );

    return err;
}
