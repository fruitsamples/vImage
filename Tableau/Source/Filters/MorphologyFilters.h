/*
 *  MorphologyFilters.h
 *  Tableau
 *
 *  Created by Ian Ollmann on Wed Nov 06 2002.
 *	Modified by Robert Murley, Sep 2003.
 *  Copyright (c) 2003 Apple Computer, Inc. All rights reserved.
 *
 */

#ifndef USING_ACCELERATE
    #include <vImage/vImage_Types.h>
#endif

#import "Filters.h"

int InvertFilter( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int InvertFilterFP( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int InvertFilter_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int InvertFilterFP_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );

int BlackFilter( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int BlackFilterFP( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int BlackFilter_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int BlackFilterFP_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );

int CopyFilter( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int CopyFilterFP( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int CopyFilter_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int CopyFilterFP_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );

int DilateFilter( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int DilateFilterFP( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int DilateFilter_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int DilateFilterFP_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );

int ErodeFilter( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int ErodeFilterFP( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int ErodeFilter_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int ErodeFilterFP_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );

int MaxFilter( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int MaxFilterFP( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int MaxFilter_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int MaxFilterFP_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );

int MinFilter( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int MinFilterFP( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int MinFilter_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int MinFilterFP_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );

int RedFilterFP_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int GreenFilterFP_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int BlueFilterFP_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
