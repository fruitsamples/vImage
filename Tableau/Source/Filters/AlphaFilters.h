/*
 *  AlphaFilters.h
 *  Tableau
 *
 *  Created by iano on Tue May 27 2003.
 *  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
 *
 */

#import "Filters.h"

int PremultiplyData( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int PremultiplyDataFP( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int PremultiplyData_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int PremultiplyDataFP_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
 
int ClipToAlpha( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );  
int ClipToAlphaFP( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );  
int ClipToAlpha_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );  
int ClipToAlphaFP_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );  
