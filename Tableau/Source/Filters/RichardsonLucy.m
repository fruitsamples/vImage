/*
 *  RicahrdsonLucy.m
 *  vImage
 *
 *  Created by Robert Murley on Fri Nov 5, 2004.
 *  Copyright (c) 2004 Apple Computer, Inc. All rights reserved.
 *
 */

#include <vImage/vImage.h>
#import "RichardsonLucy.h"
#import "Filters.h"

int RichardsonLucy( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
	Pixel_8		edgeFill = params->backgroundColor[params->colorChannel];
	
	return vImageRichardsonLucyDeConvolve_Planar8(
		src, 
		dest, 
		NULL,
		params->srcOffsetToROI_X, 
		params->srcOffsetToROI_Y,
		params->kernel, 
		NULL,
		params->kernel_height,
		params->kernel_width,
		0,
		0,
		params->divisor,
		0,
		edgeFill,
		params->iterationsPerCall,
		flags | params->edgeStyle );
}

int RichardsonLucyFP( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
	Pixel_F edgeFill = params->backgroundColor[params->colorChannel];
	
	return vImageRichardsonLucyDeConvolve_PlanarF(
		src, 
		dest, 
		NULL,
		params->srcOffsetToROI_X, 
		params->srcOffsetToROI_Y,
		params->kernel, 
		NULL,
		params->kernel_height,
		params->kernel_width,
		0,
		0,
		edgeFill,
		params->iterationsPerCall,
		flags | params->edgeStyle );
}

int RichardsonLucy_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
	Pixel_8 edgeFill[4];
	
	edgeFill[0] = UCHAR_MAX * params->backgroundColor[0];
	edgeFill[1] = UCHAR_MAX * params->backgroundColor[1];
	edgeFill[2] = UCHAR_MAX * params->backgroundColor[2];
	edgeFill[3] = UCHAR_MAX * params->backgroundColor[3];
	
	return vImageRichardsonLucyDeConvolve_ARGB8888(
		src, 
		dest, 
		NULL,
		params->srcOffsetToROI_X, 
		params->srcOffsetToROI_Y,
		params->kernel, 
		NULL,
		params->kernel_height,
		params->kernel_width,
		0,
		0,
		params->divisor,
		0,
		edgeFill,
		params->iterationsPerCall,
		flags | params->edgeStyle );
}

int RichardsonLucyFP_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
	Pixel_F edgeFill[4];
	
	edgeFill[0] = (float) params->backgroundColor[0];
	edgeFill[1] = (float) params->backgroundColor[1];
	edgeFill[2] = (float) params->backgroundColor[2];
	edgeFill[3] = (float) params->backgroundColor[3];
	
	return vImageRichardsonLucyDeConvolve_ARGBFFFF(
		src, 
		dest, 
		NULL,
		params->srcOffsetToROI_X, 
		params->srcOffsetToROI_Y,
		params->kernel, 
		NULL,
		params->kernel_height,
		params->kernel_width,
		0,
		0,
		edgeFill,
		params->iterationsPerCall,
		flags | params->edgeStyle );
}
