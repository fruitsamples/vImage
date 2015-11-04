/*
 *  GeometryFilters.c
 *  Tableau
 *
 *  Created by Ian Ollmann on Fri Feb 14 2003.
 *	Modified by Robert Murley, Sep 2003.
 *  Copyright (c) 2003 Apple Computer. All rights reserved.
 *
 */

//#include <objc/objc.h>

#include "GeometryFilters.h"
#include <math.h>
#include <limits.h>


float			gKernelScale = -INFINITY;
ResamplingFilter	gKernel = NULL;


int ShearXFilter( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    TransformInfo *info = params->info;
    float translate = info->xTranslation;
    float shear = info->xShear;
    float scale = info->xScale;
    Pixel_8 backColor = UCHAR_MAX * (params->backgroundColor)[ params->colorChannel ];
    
    if( scale != gKernelScale )
    {
        vImageDestroyResamplingFilter( gKernel );
        gKernel = vImageNewResamplingFilter( scale, /* kvImageNoFlags */ kvImageHighQualityResampling );
        gKernelScale = scale;
    }

    return vImageHorizontalShear_Planar8( src, dest, params->srcOffsetToROI_X, params->srcOffsetToROI_Y, translate, shear, gKernel, backColor, flags );
}

int ShearYFilter( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    TransformInfo *info = params->info;
    float translate = info->yTranslation;
    float shear = info->yShear;
    float scale = info->yScale;
    Pixel_8 backColor = UCHAR_MAX * (params->backgroundColor)[ params->colorChannel ];

    if( scale != gKernelScale )
    {
        vImageDestroyResamplingFilter( gKernel );
        gKernel = vImageNewResamplingFilter( scale, kvImageNoFlags );
        gKernelScale = scale;
    }

    return vImageVerticalShear_Planar8( src, dest, params->srcOffsetToROI_X, params->srcOffsetToROI_Y, translate, shear, gKernel, backColor, flags );
}

int RotateFilter( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    TransformInfo *info = params->info;
    float angle = info->rotate * 2.0f * M_PI / 360.0f;
    Pixel_8 backColor = UCHAR_MAX * (params->backgroundColor)[ params->colorChannel ];

    return vImageRotate_Planar8( src , dest, NULL, angle, backColor, flags );
}

int ScaleFilter( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    TransformInfo *info = params->info; 
    float newHeight = src->height * info->yScale;	//Our slider uses powers of 2
    float newWidth = src->width * info->xScale;		//Our slider uses powers of 2

    //Clamp to sane ranges
    if( newHeight < 0.0f ) newHeight = 0.0f;
    if( newWidth < 0.0f ) newWidth = 0.0f;
    if( newHeight > dest->height ) newHeight = dest->height;
    if( newWidth > dest->width ) newWidth = dest->width;
    
    dest->height = newHeight;
    dest->width = newWidth;
    
    return vImageScale_Planar8( src, dest, NULL, flags); 
}

int AffineTransformFilter( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    TransformInfo *info = params->info;
    Pixel_8 backColor = UCHAR_MAX * (params->backgroundColor)[ params->colorChannel ];

    return vImageAffineWarp_Planar8( src, dest, NULL, &info->transformMatrix, backColor, flags );
}

int ReflectXFilter( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    return vImageHorizontalReflect_Planar8( src, dest, flags );
}

int ReflectYFilter( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    return vImageVerticalReflect_Planar8( src, dest, flags );
}


int ShearXFilterFP( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    TransformInfo *info = params->info;
    float translate = info->xTranslation;
    float shear = info->xShear;
    float scale = info->xScale;
    Pixel_F backColor = (params->backgroundColor)[ params->colorChannel ];

    if( scale != gKernelScale )
    {
        vImageDestroyResamplingFilter( gKernel );
        gKernel = vImageNewResamplingFilter( scale, kvImageNoFlags );
        gKernelScale = scale;
    }

    return vImageHorizontalShear_PlanarF( src, dest, params->srcOffsetToROI_X, params->srcOffsetToROI_Y, translate, shear, gKernel, backColor, flags );
}

int ShearYFilterFP( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    TransformInfo *info = params->info;
    float translate = info->yTranslation;
    float shear = info->yShear;
    float scale = info->yScale;
    Pixel_F backColor = (params->backgroundColor)[ params->colorChannel ];

    if( scale != gKernelScale )
    {
        vImageDestroyResamplingFilter( gKernel );
        gKernel = vImageNewResamplingFilter( scale, kvImageNoFlags );
        gKernelScale = scale;
    }

    return vImageVerticalShear_PlanarF( src, dest, params->srcOffsetToROI_X, params->srcOffsetToROI_Y, translate,  shear, gKernel, backColor, flags );
}

int RotateFilterFP( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    TransformInfo *info = params->info;
    float angle = info->rotate * 2.0f * M_PI / 360.0f;
    Pixel_F backColor = (params->backgroundColor)[ params->colorChannel ];

    return vImageRotate_PlanarF( src, dest, NULL, angle, backColor, flags );
}

int ScaleFilterFP( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    TransformInfo *info = params->info; 
    float newHeight = src->height * info->yScale;	//Our slider uses powers of 2
    float newWidth = src->width * info->xScale;		//Our slider uses powers of 2
    
    //Clamp to sane ranges
    if( newHeight < 0.0f ) newHeight = 0.0f;
    if( newWidth < 0.0f ) newWidth = 0.0f;
    if( newHeight > dest->height ) newHeight = dest->height;
    if( newWidth > dest->width ) newWidth = dest->width;

    dest->height = newHeight;
    dest->width = newWidth;
    
    return vImageScale_PlanarF( src, dest, NULL, flags ); 
}

int AffineTransformFilterFP( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    Pixel_F backColor = 1.0f;
    TransformInfo *info = params->info; 

    return vImageAffineWarp_PlanarF( src, dest, NULL, &info->transformMatrix, backColor, flags );
}

int ReflectXFilterFP( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    return vImageHorizontalReflect_PlanarF( src, dest, flags );
}

int ReflectYFilterFP( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    return vImageVerticalReflect_PlanarF( src, dest, flags );
}


int ShearXFilter_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    TransformInfo *info = params->info;
    float translate = info->xTranslation;
    float shear = info->xShear;
    float scale = info->xScale;
    Pixel_8888 backColor;
    
    backColor[0] = UCHAR_MAX * params->backgroundColor[3];
    backColor[1] = UCHAR_MAX * params->backgroundColor[0];
    backColor[2] = UCHAR_MAX * params->backgroundColor[1];
    backColor[3] = UCHAR_MAX * params->backgroundColor[2];

    if( scale != gKernelScale )
    {
        vImageDestroyResamplingFilter( gKernel );
        gKernel = vImageNewResamplingFilter( scale, kvImageNoFlags );
        gKernelScale = scale;
    }

    return vImageHorizontalShear_ARGB8888( src, dest, params->srcOffsetToROI_X, params->srcOffsetToROI_Y, translate, shear, gKernel, backColor, flags );
}

int ShearYFilter_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    TransformInfo *info = params->info;
    float translate = info->yTranslation;
    float shear = info->yShear;
    float scale = info->yScale;
    Pixel_8888 backColor;
    
    backColor[0] = UCHAR_MAX * params->backgroundColor[3];
    backColor[1] = UCHAR_MAX * params->backgroundColor[0];
    backColor[2] = UCHAR_MAX * params->backgroundColor[1];
    backColor[3] = UCHAR_MAX * params->backgroundColor[2];
 
    if( scale != gKernelScale )
    {
        vImageDestroyResamplingFilter( gKernel );
        gKernel = vImageNewResamplingFilter( scale, kvImageNoFlags );
        gKernelScale = scale;
    }

    return vImageVerticalShear_ARGB8888( src, dest, params->srcOffsetToROI_X, params->srcOffsetToROI_Y, translate, shear, gKernel, backColor, flags );
}

int RotateFilter_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    TransformInfo *info = params->info;
    float angle = info->rotate * 2.0f * M_PI / 360.0f;
    Pixel_8888 backColor;
    
    backColor[0] = UCHAR_MAX * params->backgroundColor[3];
    backColor[1] = UCHAR_MAX * params->backgroundColor[0];
    backColor[2] = UCHAR_MAX * params->backgroundColor[1];
    backColor[3] = UCHAR_MAX * params->backgroundColor[2];

    return vImageRotate_ARGB8888( src, dest, NULL, angle, backColor, flags );
}

int ScaleFilter_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    TransformInfo *info = params->info; 
    float newHeight = src->height * info->yScale;	//Our slider uses powers of 2
    float newWidth = src->width * info->xScale;		//Our slider uses powers of 2
    
    //Clamp to sane ranges
    if( newHeight < 0.0f ) newHeight = 0.0f;
    if( newWidth < 0.0f ) newWidth = 0.0f;
    if( newHeight > dest->height ) newHeight = dest->height;
    if( newWidth > dest->width ) newWidth = dest->width;
    
    dest->height = newHeight;
    dest->width = newWidth;    
    
    return vImageScale_ARGB8888( src, dest, NULL, flags ); 
}

int AffineTransformFilter_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    TransformInfo *info = params->info; 
    Pixel_8888 backColor;
    
    backColor[0] = UCHAR_MAX * params->backgroundColor[3];
    backColor[1] = UCHAR_MAX * params->backgroundColor[0];
    backColor[2] = UCHAR_MAX * params->backgroundColor[1];
    backColor[3] = UCHAR_MAX * params->backgroundColor[2];

    return vImageAffineWarp_ARGB8888( src, dest, NULL, &info->transformMatrix, backColor, flags );
}

int ReflectXFilter_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    return vImageHorizontalReflect_ARGB8888( src, dest, flags );
}

int ReflectYFilter_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    return vImageVerticalReflect_ARGB8888( src, dest, flags );
}


int ShearXFilterFP_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    TransformInfo *info = params->info;
    float translate = info->xTranslation;
    float shear = info->xShear;
    float scale = info->xScale;
    Pixel_FFFF backColor;

    backColor[0] = params->backgroundColor[3];
    backColor[1] = params->backgroundColor[0];
    backColor[2] = params->backgroundColor[1];
    backColor[3] = params->backgroundColor[2];

    if( scale != gKernelScale )
    {
        vImageDestroyResamplingFilter( gKernel );
        gKernel = vImageNewResamplingFilter( scale, kvImageNoFlags );
        gKernelScale = scale;
    }

    return vImageHorizontalShear_ARGBFFFF( src, dest, params->srcOffsetToROI_X, params->srcOffsetToROI_Y, translate, shear, gKernel, backColor, flags );
}

int ShearYFilterFP_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    TransformInfo *info = params->info;
    float translate = info->yTranslation;
    float shear = info->yShear;
    float scale = info->yScale;
    Pixel_FFFF backColor;

    backColor[0] = params->backgroundColor[3];
    backColor[1] = params->backgroundColor[0];
    backColor[2] = params->backgroundColor[1];
    backColor[3] = params->backgroundColor[2];

    if( scale != gKernelScale )
    {
        vImageDestroyResamplingFilter( gKernel );
        gKernel = vImageNewResamplingFilter( scale, kvImageNoFlags );
        gKernelScale = scale;
    }

    return vImageVerticalShear_ARGBFFFF( src, dest, params->srcOffsetToROI_X, params->srcOffsetToROI_Y, translate, shear, gKernel, backColor, flags );
}

int RotateFilterFP_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    TransformInfo *info = params->info;
    float angle = info->rotate * 2.0f * M_PI / 360.0f;
    Pixel_FFFF backColor;

    backColor[0] = params->backgroundColor[3];
    backColor[1] = params->backgroundColor[0];
    backColor[2] = params->backgroundColor[1];
    backColor[3] = params->backgroundColor[2];

    return vImageRotate_ARGBFFFF( src, dest, NULL, angle, backColor, flags );
}

int ScaleFilterFP_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    TransformInfo *info = params->info; 
    float newHeight = src->height * info->yScale;	//Our slider uses powers of 2
    float newWidth = src->width * info->xScale;		//Our slider uses powers of 2
    
    //Clamp to sane ranges
    if( newHeight < 0.0f ) newHeight = 0.0f;
    if( newWidth < 0.0f ) newWidth = 0.0f;
    if( newHeight > dest->height ) newHeight = dest->height;
    if( newWidth > dest->width ) newWidth = dest->width;

    dest->height = newHeight;
    dest->width = newWidth;
    
    return vImageScale_ARGBFFFF( src, dest, NULL, flags ); 
}

int AffineTransformFilterFP_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    TransformInfo *info = params->info; 
    Pixel_FFFF backColor;


    backColor[0] = params->backgroundColor[3];
    backColor[1] = params->backgroundColor[0];
    backColor[2] = params->backgroundColor[1];
    backColor[3] = params->backgroundColor[2];

    return vImageAffineWarp_ARGBFFFF( src, dest, NULL, &info->transformMatrix, backColor, flags );
}

int ReflectXFilterFP_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    return vImageHorizontalReflect_ARGBFFFF( src, dest, flags );
}

int ReflectYFilterFP_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    return vImageVerticalReflect_ARGBFFFF( src, dest, flags );
}

