/*
 *  MiscFilters.c
 *  Tableau
 *
 *  Created by iano on Thu Feb 06 2003.
 *	Modified by Robert Murley, Sep 2003.
 *  Copyright (c) 2003 Apple Computer, Inc. All rights reserved.
 *
 */

#include "MiscFilters.h"
#include <math.h>

#ifndef USING_ACCELERATE
    #include <vImage/Conversion.h>
#endif

int Lookup( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    return vImageTableLookUp_Planar8( src, dest, params->alphaTable, flags);

}

int Lookup_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    return vImageTableLookUp_ARGB8888( src, dest, params->alphaTable, params->redTable, params->greenTable, params->blueTable, flags);

}


