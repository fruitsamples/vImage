/*
 *  MorphologyFilters.c
 *  Tableau
 *
 *  Created by Ian Ollmann on Wed Nov 06 2002.
 *	Modified by Robert Murley, Sep 2003.
 *  Copyright (c) 2003 Apple Computer, Inc. All rights reserved.
 *
 */

#include "MorphologyFilters.h"
#include <limits.h>
#include <string.h>
#include <stdlib.h>
#include <float.h>

#ifndef USING_ACCELERATE
    #include <vImage/Morphology.h>
#endif

#ifndef FLT_MAX
    #define FLT_MAX  3.40282347e+38F
#endif

int bufferSize = 0;
void *tempBuffer = NULL;


// This filter simply copies data from in to out, inverting black for white and colors in between
int InvertFilter( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    unsigned char *srcRow = src->data;
    unsigned char *dstRow = dest->data;
    unsigned int i, j;
    
    for( i = 0; i < src->height; i++ )
    {
        for( j = 0; j < src->width; j++ ) 
            dstRow[j] = 255 - srcRow[j];
        srcRow += src->rowBytes;
        dstRow += dest->rowBytes;
    }
    
    return kvImageNoError;
} 	

int InvertFilterFP( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    float *srcRow = src->data;
    float *dstRow = dest->data;
    unsigned int i, j;
    
    for( i = 0; i < src->height; i++ )
    {
        for( j = 0; j < src->width; j++ ) 
            dstRow[j] = 1.0f - srcRow[j];
        srcRow = (float*) ((char*) srcRow + src->rowBytes);
        dstRow = (float*) ((char*) dstRow + dest->rowBytes);
    }
    
    return kvImageNoError;
} 	

int InvertFilter_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    unsigned char *srcRow = src->data;
    unsigned char *dstRow = dest->data;
    unsigned int i, j, k;
    
    for( i = 0; i < src->height; i++ )
    {
        for( j = 0; j < src->width; j++ )
        {
            k = 4 * j;
            if ( flags & kvImageLeaveAlphaUnchanged )
                dstRow[k] = srcRow[k];
            else
                dstRow[k] = 255 - srcRow[k];
            dstRow[k+1] = 255 - srcRow[k+1];
            dstRow[k+2] = 255 - srcRow[k+2];
            dstRow[k+3] = 255 - srcRow[k+3];
        }
        srcRow += src->rowBytes;
        dstRow += dest->rowBytes;
    }
    
    return kvImageNoError;
} 	

int InvertFilterFP_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    float *srcRow = src->data;
    float *dstRow = dest->data;
    unsigned int i, j, k;
    
    for( i = 0; i < src->height; i++ )
    {
        for( j = 0; j < src->width; j++ ) 
        {
            k = 4 * j;
            if ( flags & kvImageLeaveAlphaUnchanged )
                dstRow[k] = srcRow[k];
            else
                dstRow[k] = 1.0f - srcRow[k];
            dstRow[k+1] = 1.0f - srcRow[k+1];
            dstRow[k+2] = 1.0f - srcRow[k+2];
            dstRow[k+3] = 1.0f - srcRow[k+3];
        }
        srcRow = (float*) ((char*) srcRow + src->rowBytes);
        dstRow = (float*) ((char*) dstRow + dest->rowBytes);
    }
    
    return kvImageNoError;
} 	

// This filter sets the destination image to all black
int BlackFilter( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    unsigned char *dstRow = dest->data;
    unsigned int i, j;
    
    for( i = 0; i < src->height; i++ )
    {
        for( j = 0; j < src->width; j++ ) 
            dstRow[j] = 0;
        dstRow += dest->rowBytes;
    }
    
    return kvImageNoError;
} 	

int BlackFilterFP( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    float *dstRow = dest->data;
    unsigned int i, j;
    
    for( i = 0; i < src->height; i++ )
    {
        for( j = 0; j < src->width; j++ ) 
            dstRow[j] = 0.0f;
        dstRow = (float*) ((char*) dstRow + dest->rowBytes);
    }
    
    return kvImageNoError;
} 	

int BlackFilter_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    unsigned char *dstRow = dest->data;
    unsigned int i, j, k;
    
    for( i = 0; i < src->height; i++ )
    {
        for( j = 0; j < src->width; j++ )
        {
            k = 4 * j;
            dstRow[k  ] = 0;
            dstRow[k+1] = 0;
            dstRow[k+2] = 0;
            dstRow[k+3] = 0;
        }
        dstRow += dest->rowBytes;
    }
    
    return 0;
} 	

int BlackFilterFP_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    float *dstRow = dest->data;
    unsigned int i, j, k;
    
    for( i = 0; i < src->height; i++ )
    {
        for( j = 0; j < src->width; j++ ) 
        {
            k = 4 * j;
            dstRow[k  ] = 0.0;
            dstRow[k+1] = 0.0;
            dstRow[k+2] = 0.0;
            dstRow[k+3] = 0.0;
        }
        dstRow = (float*) ((char*) dstRow + dest->rowBytes);
    }
    
    return 0;
} 	

// This filter copies the source to the destination without change
int CopyFilter( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    #define TYPE Pixel_8
    
    int i;
    TYPE *srcRow = (TYPE*) src->data; 
    TYPE *dstRow = (TYPE*) dest->data; 
    size_t rowSize = src->width * sizeof( TYPE );
    int inRowBytes = src->rowBytes;
    int outRowBytes = dest->rowBytes;
    
    for( i = 0; i < (int) src->height; i++ )
    {
        memcpy( dstRow, srcRow, rowSize );
    
        srcRow = (TYPE*) ( (char*) srcRow + inRowBytes );
        dstRow = (TYPE*) ( (char*) dstRow + outRowBytes );
    }

    return 0;
    #undef TYPE
}

int CopyFilterFP( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    #define TYPE Pixel_F
    
    int i;
    TYPE *srcRow = (TYPE*) src->data; 
    TYPE *dstRow = (TYPE*) dest->data; 
    size_t rowSize = src->width * sizeof( TYPE );
    int inRowBytes = src->rowBytes;
    int outRowBytes = dest->rowBytes;
    
    for( i = 0; i < (int) src->height; i++ )
    {
        memcpy( dstRow, srcRow, rowSize );
    
        srcRow = (TYPE*) ( (char*) srcRow + inRowBytes );
        dstRow = (TYPE*) ( (char*) dstRow + outRowBytes );
    }

    return 0;
    #undef TYPE
}

int CopyFilter_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    #define TYPE Pixel_8888
    
    int i;
    TYPE *srcRow = (TYPE*) src->data; 
    TYPE *dstRow = (TYPE*) dest->data; 
    size_t rowSize = src->width * sizeof( TYPE );
    int inRowBytes = src->rowBytes;
    int outRowBytes = dest->rowBytes;
    
    for( i = 0; i < (int) src->height; i++ )
    {
        memcpy( dstRow, srcRow, rowSize );
    
        srcRow = (TYPE*) ( (char*) srcRow + inRowBytes );
        dstRow = (TYPE*) ( (char*) dstRow + outRowBytes );
    }

    return 0;
    #undef TYPE
}

int CopyFilterFP_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    #define TYPE Pixel_FFFF
    
    int i;
    TYPE *srcRow = (TYPE*) src->data; 
    TYPE *dstRow = (TYPE*) dest->data; 
    size_t rowSize = src->width * sizeof( TYPE );
    int inRowBytes = src->rowBytes;
    int outRowBytes = dest->rowBytes;
    
    for( i = 0; i < (int) src->height; i++ )
    {
        memcpy( dstRow, srcRow, rowSize );
    
        srcRow = (TYPE*) ( (char*) srcRow + inRowBytes );
        dstRow = (TYPE*) ( (char*) dstRow + outRowBytes );
    }

    return 0;
    #undef TYPE
}


int DilateFilter( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    return  vImageDilate_Planar8( src, dest, params->srcOffsetToROI_X, params->srcOffsetToROI_Y, params->kernel, params->kernel_height, params->kernel_width, flags );
}

int ErodeFilter( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    return  vImageErode_Planar8( src, dest, params->srcOffsetToROI_X, params->srcOffsetToROI_Y, params->kernel, params->kernel_height, params->kernel_width, flags );
}

int MaxFilter( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    int				kernel_height = params->kernel_height;
    int				kernel_width = params->kernel_width;
    
    if( YES == params->useTemporaryBuffers )
    {
        size_t		tempSize = vImageMax_Planar8( src, dest, NULL, params->srcOffsetToROI_X, params->srcOffsetToROI_Y, kernel_height, kernel_width, flags | kvImageGetTempBufferSize );

        if( tempSize > bufferSize )
        {
            if( NULL != tempBuffer )
                free( tempBuffer );
        
            tempBuffer = malloc( tempSize );
            bufferSize = tempSize;
        }
        
        return  vImageMax_Planar8( src, dest, tempBuffer, params->srcOffsetToROI_X, params->srcOffsetToROI_Y, kernel_height, kernel_width, flags );
    }

    return  vImageMax_Planar8( src, dest, NULL, params->srcOffsetToROI_X, params->srcOffsetToROI_Y, kernel_height, kernel_width, flags );    
}

int MinFilter( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    int				kernel_height = params->kernel_height;
    int				kernel_width = params->kernel_width;

    size_t		tempSize = vImageMin_Planar8( src, dest, NULL, params->srcOffsetToROI_X, params->srcOffsetToROI_Y, kernel_height, kernel_width, flags | kvImageGetTempBufferSize );

    if( tempSize > bufferSize )
    {
        if( NULL != tempBuffer )
            free( tempBuffer );
    
        tempBuffer = malloc( tempSize );
        bufferSize = tempSize;
    }

    return  vImageMin_Planar8( src, dest, tempBuffer, params->srcOffsetToROI_X, params->srcOffsetToROI_Y, kernel_height, kernel_width, flags );
}

int DilateFilterFP( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    void			*kernel = params->kernel;
    int				kernel_height = params->kernel_height;
    int				kernel_width = params->kernel_width;

    return  vImageDilate_PlanarF( src, dest, params->srcOffsetToROI_X, params->srcOffsetToROI_Y, kernel, kernel_height, kernel_width, flags );
}

int ErodeFilterFP( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    void			*kernel = params->kernel;
    int				kernel_height = params->kernel_height;
    int				kernel_width = params->kernel_width;

    return  vImageErode_PlanarF( src, dest, params->srcOffsetToROI_X, params->srcOffsetToROI_Y, kernel, kernel_height, kernel_width, flags );
}

int MaxFilterFP( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    int				kernel_height = params->kernel_height;
    int				kernel_width = params->kernel_width;
    size_t		tempSize = vImageMax_PlanarF( src, dest, NULL, params->srcOffsetToROI_X, params->srcOffsetToROI_Y, kernel_height, kernel_width, flags | kvImageGetTempBufferSize );

    if( tempSize > bufferSize )
    {
        if( NULL != tempBuffer )
            free( tempBuffer );
    
        tempBuffer = malloc( tempSize );
        bufferSize = tempSize;
    }

    return  vImageMax_PlanarF( src, dest, tempBuffer, params->srcOffsetToROI_X, params->srcOffsetToROI_Y, kernel_height, kernel_width, flags );
}

int MinFilterFP( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    int				kernel_height = params->kernel_height;
    int				kernel_width = params->kernel_width;
    size_t		tempSize = vImageMin_PlanarF( src, dest, NULL, params->srcOffsetToROI_X, params->srcOffsetToROI_Y, kernel_height, kernel_width, flags | kvImageGetTempBufferSize );

    if( tempSize > bufferSize )
    {
        if( NULL != tempBuffer )
            free( tempBuffer );
    
        tempBuffer = malloc( tempSize );
        bufferSize = tempSize;
    }

    return  vImageMin_PlanarF( src, dest, tempBuffer, params->srcOffsetToROI_X, params->srcOffsetToROI_Y, kernel_height, kernel_width, flags );
}


int DilateFilter_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    void			*kernel = params->kernel;
    int				kernel_height = params->kernel_height;
    int				kernel_width = params->kernel_width;

    return  vImageDilate_ARGB8888( src, dest,params->srcOffsetToROI_X, params->srcOffsetToROI_Y, kernel, kernel_height, kernel_width, flags );
}

int ErodeFilter_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    void			*kernel = params->kernel;
    int				kernel_height = params->kernel_height;
    int				kernel_width = params->kernel_width;

    return  vImageErode_ARGB8888( src, dest, params->srcOffsetToROI_X, params->srcOffsetToROI_Y, kernel, kernel_height, kernel_width, flags );
}

int MaxFilter_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    int				kernel_height = params->kernel_height;
    int				kernel_width = params->kernel_width;
    size_t		tempSize =  vImageMax_ARGB8888( src, dest, NULL, params->srcOffsetToROI_X, params->srcOffsetToROI_Y, kernel_height, kernel_width, flags | kvImageGetTempBufferSize );

    if( tempSize > bufferSize )
    {
        if( NULL != tempBuffer )
            free( tempBuffer );
    
        tempBuffer = malloc( tempSize );
        bufferSize = tempSize;
    }

    return  vImageMax_ARGB8888( src, dest, tempBuffer, params->srcOffsetToROI_X, params->srcOffsetToROI_Y, kernel_height, kernel_width, flags );
}

int MinFilter_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    int				kernel_height = params->kernel_height;
    int				kernel_width = params->kernel_width;
    size_t		tempSize = vImageMin_ARGB8888( src, dest, NULL, params->srcOffsetToROI_X, params->srcOffsetToROI_Y, kernel_height, kernel_width, flags | kvImageGetTempBufferSize );

    if( tempSize > bufferSize )
    {
        if( NULL != tempBuffer )
            free( tempBuffer );
    
        tempBuffer = malloc( tempSize );
        bufferSize = tempSize;
    }

    return  vImageMin_ARGB8888( src, dest, tempBuffer, params->srcOffsetToROI_X, params->srcOffsetToROI_Y, kernel_height, kernel_width, flags );
}

int DilateFilterFP_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    void			*kernel = params->kernel;
    int				kernel_height = params->kernel_height;
    int				kernel_width = params->kernel_width;

    return  vImageDilate_ARGBFFFF( src, dest, params->srcOffsetToROI_X, params->srcOffsetToROI_Y, kernel, kernel_height, kernel_width, flags );
}

int ErodeFilterFP_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    void			*kernel = params->kernel;
    int				kernel_height = params->kernel_height;
    int				kernel_width = params->kernel_width;

    return  vImageErode_ARGBFFFF( src, dest, params->srcOffsetToROI_X, params->srcOffsetToROI_Y, kernel, kernel_height, kernel_width, flags );
}

int MaxFilterFP_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    int				kernel_height = params->kernel_height;
    int				kernel_width = params->kernel_width;
    size_t		tempSize = vImageMax_ARGBFFFF( src, dest, NULL, params->srcOffsetToROI_X, params->srcOffsetToROI_Y, kernel_height, kernel_width, flags | kvImageGetTempBufferSize );

    if( tempSize > bufferSize )
    {
        if( NULL != tempBuffer )
            free( tempBuffer );
    
        tempBuffer = malloc( tempSize );
        bufferSize = tempSize;
    }

    return  vImageMax_ARGBFFFF( src, dest, tempBuffer, params->srcOffsetToROI_X, params->srcOffsetToROI_Y, kernel_height, kernel_width, flags );
}

int MinFilterFP_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    int				kernel_height = params->kernel_height;
    int				kernel_width = params->kernel_width;
    size_t		tempSize = vImageMin_ARGBFFFF( src, dest, NULL, params->srcOffsetToROI_X, params->srcOffsetToROI_Y, kernel_height, kernel_width, flags | kvImageGetTempBufferSize );

    if( tempSize > bufferSize )
    {
        if( NULL != tempBuffer )
            free( tempBuffer );
    
        tempBuffer = malloc( tempSize );
        bufferSize = tempSize;
    }

    return  vImageMin_ARGBFFFF( src, dest, tempBuffer, params->srcOffsetToROI_X, params->srcOffsetToROI_Y, kernel_height, kernel_width, flags );
}

int RedFilterFP_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    #define TYPE float
    int x, y;
    int inRowBytes = src->rowBytes;
    int outRowBytes = dest->rowBytes;
    
    TYPE *srcRow = src->data;
    TYPE *dstRow = dest->data;
    
    for( y = 0; y < (int) src->height; y++ )
    {
        TYPE *input = srcRow;
        TYPE *output = dstRow;
        
        for( x = 0; x < (int) src->width; x++ )
        {
            output[4*x] = 0.0f;
            output[4*x+1] = input[4*x+1];
            output[4*x+2] = 0.0f;
            output[4*x+3] = 0.0f;
        }
        
        srcRow = (TYPE*) ((char*) srcRow + inRowBytes );
        dstRow = (TYPE*) ((char*) dstRow + outRowBytes );
    }

    return 0;
    #undef TYPE
}

int GreenFilterFP_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    #define TYPE float
    int x, y;
    int inRowBytes = src->rowBytes;
    int outRowBytes = dest->rowBytes;
    
    TYPE *srcRow = src->data;
    TYPE *dstRow = dest->data;
    
    for( y = 0; y < (int) src->height; y++ )
    {
        TYPE *input = srcRow;
        TYPE *output = dstRow;
        
        for( x = 0; x < (int) src->width; x++ )
        {
            output[4*x] = 0.0f;
            output[4*x+1] = 0.0f;
            output[4*x+2] = input[4*x+2];
            output[4*x+3] = 0.0f;
        }
        
        srcRow = (TYPE*) ((char*) srcRow + inRowBytes );
        dstRow = (TYPE*) ((char*) dstRow + outRowBytes );
    }

    return 0;
    #undef TYPE
}

int BlueFilterFP_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    #define TYPE float
    int x, y;
    int inRowBytes = src->rowBytes;
    int outRowBytes = dest->rowBytes;
    
    TYPE *srcRow = src->data;
    TYPE *dstRow = dest->data;
    
    for( y = 0; y < (int) src->height; y++ )
    {
        TYPE *input = srcRow;
        TYPE *output = dstRow;
        
        for( x = 0; x < (int) src->width; x++ )
        {
            output[4*x] = 0.0f;
            output[4*x+1] = 0.0f;
            output[4*x+2] = 0.0f;
            output[4*x+3] = input[4*x+3];
        }
        
        srcRow = (TYPE*) ((char*) srcRow + inRowBytes );
        dstRow = (TYPE*) ((char*) dstRow + outRowBytes );
    }

    return 0;
    #undef TYPE
}

