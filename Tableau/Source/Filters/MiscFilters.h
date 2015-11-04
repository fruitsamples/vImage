/*
 *  MiscFilters.h
 *  Tableau
 *
 *  Created by iano on Thu Feb 06 2003.
 *	Modified by Robert Murley, Sep 2003.
 *  Copyright (c) 2003 Apple Computer, Inc. All rights reserved.
 *
 */

#ifndef USING_ACCELERATE
    #include <vImage/vImage_Types.h>
#endif

#import "Filters.h"

int Lookup( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int Lookup_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );

