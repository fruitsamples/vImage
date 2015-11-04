/*
 * ConversionFilters.h
 * Tableau
 *
 *  Created by Robert Murley on May 29 2003.
 *  Copyright (c) 2003 Apple Computer Inc. All rights reserved.
 *
 */

    IBOutlet ImageController *imageController;

int Convert_Planar8ToARGB8888(vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params);
int Convert_PlanarFToARGBFFFF(vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params);
int Convert_ARGB8888ToPlanar8(vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params);
int Convert_ARGBFFFFToPlanarF(vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params);
int Convert_Planar8ToPlanarF(vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params);
int Convert_PlanarFToPlanar8(vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params);

//These do a round trip conversion
int Convert_PlanarFTo16S(vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params);
int Convert_PlanarFTo16U(vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params);
int Convert_PlanarFTo16F(vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params);
int Convert_Planar8To16U(vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params);
int Convert_Planar8To888(vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params);
int Convert_ARGB8888To888(vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params);
int Convert_PlanarFToFFF(vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params);
int Convert_Planar8To565(vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params);
int Convert_Planar8To1555(vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params);
int Convert_ARGB8888To1555(vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params);
int Convert_ARGB8888To565(vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params);
int Convert_ARGB8888To888(vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params);
int Flatten_ARGB8888To888(vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params);
int Flatten_ARGBFFFFToFFF(vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params);

// These operate on only one format
int OverwriteChannelsWithScalar_Planar8(vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params);
int OverwriteChannelsWithScalar_PlanarF(vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params);
int OverwriteChannelsWithScalar_ARGB8888(vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params);
int OverwriteChannelsWithScalar_ARGBFFFF(vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params);
int OverwriteChannels_ARGB8888(vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params);
int OverwriteChannels_ARGBFFFF(vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params);
int Convert_BufferFill8888(vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params);
int Convert_BufferFillFFFF(vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params);
int Permute_ARGB8888( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int Permute_ARGBFFFF( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );

int ClipFilter_FP( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int ClipFilterFP_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );


int MatrixMultiply_Planar8( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int MatrixMultiply_ARGB8888( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int MatrixMultiply_PlanarF( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int MatrixMultiply_ARGBFFFF( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );

int MatrixMultiply2_ARGB8888( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int MatrixMultiply2_ARGBFFFF( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
