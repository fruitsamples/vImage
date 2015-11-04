/*
 *  ConvolutionFilters.h
 *  Tableau
 *
 *	Written by Robert Murley, Sep 2003.
 *  Copyright (c) 2003 Apple Computer, Inc. All rights reserved.
 *
 */

#import "Filters.h"
#import "ParamsController.h"


int Convolution( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int ConvolutionFP( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int Convolution_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int ConvolutionFP_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );

int ConvolutionBias( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int ConvolutionBiasFP( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int ConvolutionBias_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int ConvolutionBiasFP_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );

int ConvolutionMultiKernel( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int ConvolutionMultiKernelFP( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );

int ConvolutionBox( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int ConvolutionBox_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int ConvolutionTent( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int ConvolutionTent_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
