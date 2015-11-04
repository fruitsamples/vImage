/*
 *  AlphaFilters.c
 *  Tableau
 *
 *  Created by iano on Tue May 27 2003.
 *  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
 *
 */

#include "AlphaFilters.h"

int PremultiplyData( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
	return vImagePremultiplyData_Planar8( src, params->alpha, dest, flags );
}

int PremultiplyDataFP( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
	return vImagePremultiplyData_PlanarF( src, params->alpha, dest, flags );
}

int PremultiplyData_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
	return vImagePremultiplyData_ARGB8888( src, dest, flags );
}

int PremultiplyDataFP_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
	return vImagePremultiplyData_ARGBFFFF( src, dest, flags );
}


int ClipToAlpha( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
	return vImageClipToAlpha_Planar8(src, params->alpha, dest, flags);
}  

int ClipToAlphaFP( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    return 0;
}  

int ClipToAlpha_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    return 0;
}  

int ClipToAlphaFP_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    return 0;
}  
