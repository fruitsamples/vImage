/*
 *  HistogramFilters.h
 *
 *  Created by Robert Murley on Fri Feb 21 2003.
 *  Copyright (c) 2003 Apple Computer, Inc. All rights reserved.
 *
 */

int Histogram( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int HistogramFP( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int Histogram_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int HistogramFP_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );

int Histogram_Equalization( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int Histogram_EqualizationFP( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int Histogram_Equalization_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int Histogram_EqualizationFP_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );

int Histogram_Specification( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int Histogram_SpecificationFP( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int Histogram_Specification_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int Histogram_SpecificationFP_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );

int Histogram_Contrast_Stretch( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int Histogram_Contrast_StretchFP( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int Histogram_Contrast_Stretch_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int Histogram_Contrast_StretchFP_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );

int Histogram_Ends_In_Contrast_Stretch( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int Histogram_Ends_In_Contrast_StretchFP( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int Histogram_Ends_In_Contrast_Stretch_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int Histogram_Ends_In_Contrast_StretchFP_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
