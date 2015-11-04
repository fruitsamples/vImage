/*
 *  GeometryFilters.h
 *  Tableau
 *
 *  Created by Ian Ollmann on Wed Nov 06 2002.
 *	Modified by Robert Murley, Sep 2003.
 *  Copyright (c) 2003 Apple Computer. All rights reserved.
 *
 */

#ifndef USING_ACCELERATE
    #include <vImage/vImage_Types.h>
#endif
#include "Filters.h"


int ShearXFilter( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );  
int ShearYFilter( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );  
int ShearXFilterCustom( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );  
int ShearYFilterCustom( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );  
int RotateFilter( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );  
int ScaleFilter( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params ); 
int AffineTransformFilter( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params ); 
int ReflectXFilter( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params ); 
int ReflectYFilter( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params ); 
int Rotate90Filter(vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );  

int ShearXFilterFP( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int ShearYFilterFP( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int ShearXFilterCustomFP( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );  
int ShearYFilterCustomFP( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );  
int RotateFilterFP( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int ScaleFilterFP( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int AffineTransformFilterFP( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int ReflectXFilterFP( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int ReflectYFilterFP( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int Rotate90FilterFP(vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );  

int ShearXFilter_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int ShearYFilter_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int ShearXFilterCustom_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );  
int ShearYFilterCustom_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );  
int RotateFilter_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int ScaleFilter_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int AffineTransformFilter_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int ReflectXFilter_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int ReflectYFilter_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int Rotate90Filter_ARGB(vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );  

int ShearXFilterFP_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int ShearYFilterFP_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int ShearXFilterCustom_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );  
int ShearYFilterCustom_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );  
int RotateFilterFP_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int ScaleFilterFP_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int AffineTransformFilterFP_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int ReflectXFilterFP_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int ReflectYFilterFP_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int Rotate90FilterFP_ARGB(vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );  

