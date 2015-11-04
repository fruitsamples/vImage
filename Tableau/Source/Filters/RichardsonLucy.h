//
//  RichardsonLucy.h
//  Tableau
//
//  Created by Robert Murley on Thu Nov 5, 2004.
//  Copyright (c) 2004 Apple Computer, Inc. All rights reserved.
//

#import "ParamsController.h"
#import "ImageController.h"

int RichardsonLucy( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int RichardsonLucyFP( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int RichardsonLucy_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int RichardsonLucyFP_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
