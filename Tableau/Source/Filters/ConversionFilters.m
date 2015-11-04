/*
 *  ConvolutionFilters.c
 *  Tableau
 *
 *  Created by Robert Murley on May 29 2003.
 *  Copyright (c) 2003 Apple Computer Inc. All rights reserved.
 *
 */

#import <CoreServices/CoreServices.h>

#import "Filters.h"
#import "ConversionFilters.h"
#import "MorphologyFilters.h"
#import "ImageController.h"

// Utility routines

/*
 *   Extract a planar8 channel from an ARGB8888 image
 *		src = ARGB8888 image
 *		dest = empty vImage_Buffer
 *		channel = channel # (0-3)
 *   if non-error return, caller must release dest->data
 */
int Extract8BitChannel( vImage_Buffer *src, vImage_Buffer *dest, int channel );
int Extract8BitChannel( vImage_Buffer *src, vImage_Buffer *dest, int channel )
{
	vImagePixelCount	h, w;
	
	dest->data = malloc( src->height * src->width );
	if (dest->data == NULL)
		return -1;
	
	dest->height = src->height;
	dest->width = src->width;
	dest->rowBytes = src->width;
	
	for (h = 0; h < src->height; h++) {
		uint8_t *srcRow = src->data + h * src->rowBytes;
		uint8_t *dstRow = dest->data + h * dest->rowBytes;
		
		for (w = 0; w < src->width; w++) {
			dstRow[0] = srcRow[channel];
			dstRow++;
			srcRow += 4;
		}
	}
	
	return 0;
}

/*
 *   Extract a planarF channel from an ARGBFFFF image
 *		src = ARGBFFFF image
 *		dest = empty vImage_Buffer
 *		channel = channel # (0-3)
 *   if non-error return, caller must release dest->data
 */
int Extract32BitChannel( vImage_Buffer *src, vImage_Buffer *dest, int channel );
int Extract32BitChannel( vImage_Buffer *src, vImage_Buffer *dest, int channel )
{
	vImagePixelCount	h, w;
	
	dest->data = malloc( src->height * src->width * sizeof(float) );
	if (dest->data == NULL)
		return -1;
	
	dest->height = src->height;
	dest->width = src->width;
	dest->rowBytes = src->width * sizeof(float);
	
	for (h = 0; h < src->height; h++) {
		float *srcRow = src->data + h * src->rowBytes;
		float *dstRow = dest->data + h * dest->rowBytes;
		
		for (w = 0; w < src->width; w++) {
			dstRow[0] = srcRow[channel];
			dstRow++;
			srcRow += 4;
		}
	}
	
	return 0;
}

int Convert_Planar8ToARGB8888(vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params)
{
	return vImageConvert_Planar8toARGB8888(&src[0], &src[1], &src[2], &src[3], dest, flags);
}		

int Convert_PlanarFToARGBFFFF(vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params)
{
	return vImageConvert_PlanarFtoARGBFFFF(&src[0], &src[1], &src[2], &src[3], dest, flags);
}		
		
int Convert_ARGB8888ToPlanar8(vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params)
{
	return vImageConvert_ARGB8888toPlanar8(src, &dest[0], &dest[1], &dest[2], &dest[3], flags);
}		

int Convert_ARGBFFFFToPlanarF(vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params)
{
	return vImageConvert_ARGBFFFFtoPlanarF(src, &dest[0], &dest[1], &dest[2], &dest[3], flags);
}		

int Convert_Planar8ToPlanarF( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    vImage_Error	err;
	int				i;

	for (i = 0; i < 4; i++)
		err = vImageConvert_Planar8toPlanarF(&src[i], &dest[i], 1.0, 0.0, kvImageNoFlags);
        
    return err;
}

int Convert_PlanarFToPlanar8( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    vImage_Error	err;
	int				i;

	for (i = 0; i < 4; i++)
		err = vImageConvert_PlanarFtoPlanar8(&src[i], &dest[i], 1.0, 0.0, kvImageNoFlags);

    return err;
}

int Convert_PlanarFTo16S( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
	int				i;
	vImage_Error	err;

	short         *buffer16 = malloc(src->height * src->width * sizeof(short));
	if (buffer16 == NULL)
		return -1;
	
	vImage_Buffer stage = { buffer16, src->height, src->width, src->width * sizeof(short) };
	for (i = 0; i < 4; i++) {
		err = vImageConvert_FTo16S(&src[i], &stage, 0.0, 1.0/32767.0, flags);
		err = vImageConvert_16SToF(&stage, &dest[i], 0.0, 1.0/32767.0, flags);
	}

	free(buffer16);
	return err;
}

int Convert_PlanarFTo16U( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
	int				i;
	vImage_Error	err;

	short         *buffer16 = malloc(src->height * src->width * sizeof(short));
	if (buffer16 == NULL)
		return -1;
	
	vImage_Buffer stage = { buffer16, src->height, src->width, src->width * sizeof(short) };
	for (i = 0; i < 4; i++) {
		err = vImageConvert_FTo16U(&src[i], &stage, 0.0, 1.0/32767.0, flags);
		err = vImageConvert_16UToF(&stage, &dest[i], 0.0, 1.0/32767.0, flags);
	}

	free(buffer16);
	return err;
}

int Convert_PlanarFTo16F( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
	int				i;
	vImage_Error	err;

	short         *buffer16 = malloc(src->height * src->width * sizeof(short));
	if (buffer16 == NULL)
		return -1;
	
	flags &= ~kvImageLeaveAlphaUnchanged;
	vImage_Buffer stage = { buffer16, src->height, src->width, src->width * sizeof(short) };
	for (i = 0; i < 4; i++) {
		err = vImageConvert_PlanarFtoPlanar16F(&src[i], &stage, flags);
		err = vImageConvert_Planar16FtoPlanarF(&stage, &dest[i], flags);
	}

	free(buffer16);
	return err;
}

int Convert_Planar8To16U( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
	int				i;
	vImage_Error	err;

	short         *buffer16 = malloc(src->height * src->width * sizeof(short));
	if (buffer16 == NULL)
		return -1;
	
	vImage_Buffer stage = { buffer16, src->height, src->width, src->width * sizeof(short) };
	for (i = 0; i < 4; i++) {
		err = vImageConvert_Planar8To16U(&src[i], &stage, flags);
		err = vImageConvert_16UToPlanar8(&stage, &dest[i], flags);
	}

	free(buffer16);
	return err;
}

int Convert_Planar8To888( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
	vImage_Error	err;

	unsigned char        *buffer24 = malloc(3 * src->height * src->width);
	if (buffer24 == NULL)
		return -1;
	
	vImage_Buffer stage = { buffer24, src->height, src->width, 3 * src->width };
	err = vImageConvert_Planar8toRGB888(&src[1], &src[2], &src[3], &stage, flags);
	err = vImageConvert_RGB888toPlanar8(&stage, &dest[1], &dest[2], &dest[3], flags);
	CopyFilter(src, dest, flags, params);		// copy alpha channel

	free(buffer24);
	return err;
}

int Convert_ARGB8888To888( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
	vImage_Buffer	alpha;
	vImage_Error	err;

	unsigned char        *buffer24 = malloc(3 * src->height * src->width);
	if (buffer24 == NULL)
		return -1;
	
	vImage_Buffer stage = { buffer24, src->height, src->width, 3 * src->width };
	err = vImageConvert_ARGB8888toRGB888(src, &stage, flags);
	
	err = Extract8BitChannel( src, &alpha, 0 );
	if (err)
		return err;
	
	err = vImageConvert_RGB888toARGB8888(&stage, &alpha, 0, dest, 1, flags);

	free(buffer24);
	free(alpha.data);
	return err;
}

int Flatten_ARGB8888To888( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
	vImage_Error	err;
	Pixel_8888		backgroundColor;
	vImage_Buffer	alpha;

	backgroundColor[0] = (uint8_t) ( 255.0 * params->backgroundColor[0] );
	backgroundColor[1] = (uint8_t) ( 255.0 * params->backgroundColor[1] );
	backgroundColor[2] = (uint8_t) ( 255.0 * params->backgroundColor[2] );
	backgroundColor[3] = (uint8_t) ( 255.0 * params->backgroundColor[3] );

	unsigned char        *buffer24 = malloc(3 * src->height * src->width);
	if (buffer24 == NULL)
		return -1;
	
	vImageOverwriteChannelsWithScalar_ARGB8888( 127, src, src, 8, 0 );
	vImage_Buffer stage = { buffer24, src->height, src->width, 3 * src->width };
	vImageFlatten_ARGB8888ToRGB888( src, &stage, backgroundColor, 1, flags );
	
	err = Extract8BitChannel( src, &alpha, 0 );
	if (err)
		return err;
	
	err = vImageConvert_RGB888toARGB8888(&stage, NULL, 128, dest, 1, flags);

	free(buffer24);
	free(alpha.data);
	return err;
}

int Convert_PlanarFToFFF( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
	vImage_Error	err;

	float    *buffer24 = malloc(3 * src->height * src->width * sizeof(float));
	if (buffer24 == NULL)
		return -1;
	
	vImage_Buffer stage = { buffer24, src->height, src->width, 3 * src->width * sizeof(float)};
	err = vImageConvert_PlanarFtoRGBFFF(&src[1], &src[2], &src[3], &stage, flags);
	err = vImageConvert_RGBFFFtoPlanarF(&stage, &dest[1], &dest[2], &dest[3], flags);
	CopyFilterFP(src, dest, flags, params);		// copy alpha channel

	free(buffer24);
	return err;
}

int Flatten_ARGBFFFFToFFF( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
	vImage_Error	err;
	vImage_Buffer	alpha;

	unsigned char        *buffer24 = malloc(3 * src->height * src->width * sizeof(float));
	if (buffer24 == NULL)
		return -1;
	
	vImageOverwriteChannelsWithScalar_ARGBFFFF( 0.5, src, src, 8, 0 );
	vImage_Buffer stage = { buffer24, src->height, src->width, 3 * src->width * sizeof(float)};
	vImageFlatten_ARGBFFFFToRGBFFF( src, &stage, params->backgroundColor, 1, flags );
	
	err = Extract32BitChannel( src, &alpha, 0 );
	if (err)
		return err;
	CopyFilterFP(&alpha, dest, flags, params);		// copy alpha channel	
	
	err = vImageConvert_RGBFFFtoPlanarF(&stage, &dest[1], &dest[2], &dest[3], flags);

	free(buffer24);
	free(alpha.data);
	return err;
}

int Convert_Planar8To565( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
	vImage_Error	err;

	unsigned char        *buffer16 = malloc(2 * src->height * src->width);
	if (buffer16 == NULL)
		return -1;
	
	vImage_Buffer stage = { buffer16, src->height, src->width, 2 * src->width };
	err = vImageConvert_Planar8toRGB565(&src[1], &src[2], &src[3], &stage, flags);
	err = vImageConvert_RGB565toPlanar8(&stage, &dest[1], &dest[2], &dest[3], flags);
	CopyFilter(src, dest, flags, params);		// copy alpha channel

	free(buffer16);
	return err;
}

int Convert_Planar8To1555( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
	vImage_Error	err;

	unsigned char        *buffer16 = malloc(2 * src->height * src->width);
	if (buffer16 == NULL)
		return -1;
	
	vImage_Buffer stage = { buffer16, src->height, src->width, 2 * src->width };
	err = vImageConvert_Planar8toARGB1555(&src[0], &src[1], &src[2], &src[3], &stage, flags);
	err = vImageConvert_ARGB1555toPlanar8(&stage, &dest[0], &dest[1], &dest[2], &dest[3], flags);

	free(buffer16);
	return err;
}

int Convert_ARGB8888To1555( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
	vImage_Error	err;

	unsigned char        *buffer16 = malloc(3 * src->height * src->width);
	if (buffer16 == NULL)
		return -1;
	
	vImage_Buffer stage = { buffer16, src->height, src->width, 3 * src->width };
	err = vImageConvert_ARGB8888toARGB1555(src, &stage, flags);
	
	err = vImageConvert_ARGB1555toARGB8888(&stage, dest, flags);

	free(buffer16);
	return err;
}

int Convert_ARGB8888To565( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
	vImage_Error	err;

	unsigned char        *buffer16 = malloc(2 * src->height * src->width);
	if (buffer16 == NULL)
		return -1;
	
	vImage_Buffer stage = { buffer16, src->height, src->width, 2 * src->width };
	err = vImageConvert_ARGB8888toRGB565(src, &stage, flags);
	err = vImageConvert_RGB565toARGB8888(255, &stage, dest, flags);
	CopyFilter(src, dest, flags, params);		// copy alpha channel

	free(buffer16);
	return err;
}

// NOTE: overwriting alpha can cause invalid premultiplied data
int OverwriteChannelsWithScalar_Planar8( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
	int		i;
	vImage_Error	err;
	
	for (i = 0; i < 4; i++)
		err = vImageOverwriteChannelsWithScalar_Planar8((Pixel_8) (255.0 * params->scalarForOverwrite), &dest[i], flags);
	
	return err;
}

// NOTE: overwriting alpha can cause invalid premultiplied data
int OverwriteChannelsWithScalar_PlanarF( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
	return vImageOverwriteChannelsWithScalar_PlanarF((Pixel_8) params->scalarForOverwrite, &src[params->sourceOverwrite], flags);
}

int OverwriteChannelsWithScalar_ARGB8888( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
	return vImageOverwriteChannelsWithScalar_ARGB8888( 127, src, dest, 8, flags);
}

int OverwriteChannelsWithScalar_ARGBFFFF( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
	return vImageOverwriteChannelsWithScalar_ARGBFFFF( 0.5, src, dest, 8, flags);
}

int OverwriteChannels_ARGB8888( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
	ViewController	 *view = [imageController getViewController: 0];
	vImage_Buffer	 newSrc;
	int			  height, width, dstMask = 1 << (3 - params->destOverwrite); 
	unsigned char *data[5];

	if (view == NULL)
		return -1;
	
	// use smaller of the 2 heights and widths
	height = [view height];
	width = [view width];
	if (height > src->height)
		height = src->height;
	if (width > src->width)
		width = src->width;
	
	[[view refImageRep] getBitmapDataPlanes: data];
	newSrc.data = data[0];
	newSrc.height = height;
	newSrc.width = width;
	newSrc.rowBytes = width * sizeof(Pixel_8888);
	
	return vImageOverwriteChannels_ARGB8888(&newSrc, src, dest, dstMask, flags);
}

int OverwriteChannels_ARGBFFFF( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
	ViewController	 *view = [imageController getViewController: 0];
	vImage_Buffer	 newSrc;
	int			  height, width, dstMask = 1 << (3 - params->destOverwrite); 
	unsigned char *data[5];

	if (view == NULL)
		return -1;
	
	// use smaller of the 2 heights and widths
	height = [view height];
	width = [view width];
	if (height > src->height)
		height = src->height;
	if (width > src->width)
		width = src->width;
	
	[[view refImageRep] getBitmapDataPlanes: data];
	newSrc.data = data[0];
	newSrc.height = height;
	newSrc.width = width;
	newSrc.rowBytes = width * sizeof(Pixel_FFFF);
	
	return vImageOverwriteChannels_ARGBFFFF(&newSrc, src, dest, dstMask, flags);
}

int Convert_BufferFill8888( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
	Pixel_8888    fill;
	unsigned char   i;

	for (i = 0; i < 4; i++)
		fill[i] = (Pixel_8) (255.0 * params->backgroundColor[i]);

	return vImageBufferFill_ARGB8888(src, fill, flags);
}

int Convert_BufferFillFFFF( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
	Pixel_FFFF    fill;
	unsigned char   i;

	for (i = 0; i < 4; i++)
		fill[i] = (Pixel_F) params->backgroundColor[i];

	return vImageBufferFill_ARGBFFFF(src, fill, flags);
}

void MMult(  float r[16],  const float a[16],  const float b[16] );
void MMult(  float r[16],  const float a[16],  const float b[16] )
{
    
    float r0 = a[0] * b[0] + a[1] * b[4] + a[2] * b[8] + a[3] * b[12];
    float r1 = a[0] * b[1] + a[1] * b[5] + a[2] * b[9] + a[3] * b[13];
    float r2 = a[0] * b[2] + a[1] * b[6] + a[2] * b[10] + a[3] * b[14];
    float r3 = a[0] * b[3] + a[1] * b[7] + a[2] * b[11] + a[3] * b[15];

    float r4 = a[4] * b[0] + a[5] * b[4] + a[6] * b[8] + a[7] * b[12];
    float r5 = a[4] * b[1] + a[5] * b[5] + a[6] * b[9] + a[7] * b[13];
    float r6 = a[4] * b[2] + a[5] * b[6] + a[6] * b[10] + a[7] * b[14];
    float r7 = a[4] * b[3] + a[5] * b[7] + a[6] * b[11] + a[7] * b[15];

    float r8 = a[8] * b[0] + a[9] * b[4] + a[10] * b[8] + a[11] * b[12];
    float r9 = a[8] * b[1] + a[9] * b[5] + a[10] * b[9] + a[11] * b[13];
    float r10 = a[8] * b[2] + a[9] * b[6] + a[10] * b[10] + a[11] * b[14];
    float r11 = a[8] * b[3] + a[9] * b[7] + a[10] * b[11] + a[11] * b[15];

    float r12 = a[12] * b[0] + a[13] * b[4] + a[14] * b[8] + a[15] * b[12];
    float r13 = a[12] * b[1] + a[13] * b[5] + a[14] * b[9] + a[15] * b[13];
    float r14 = a[12] * b[2] + a[13] * b[6] + a[14] * b[10] + a[15] * b[14];
    float r15 = a[12] * b[3] + a[13] * b[7] + a[14] * b[11] + a[15] * b[15];

    r[0] = r0;      r[1] = r1;      r[2] = r2;      r[3] = r3;
    r[4] = r4;      r[5] = r5;      r[6] = r6;      r[7] = r7;
    r[8] = r8;      r[9] = r9;      r[10] = r10;      r[11] = r11;
    r[12] = r12;      r[13] = r13;      r[14] = r14;      r[15] = r15;
}

void InitRotationMatrix( float xyz[3], float degrees, float matrix[16] );
void InitRotationMatrix( float xyz[3], float degrees, float matrix[16] )
{
    float x = xyz[0];
    float y = xyz[1];
    float z = xyz[2];
    double theta = degrees * 2.0 * M_PI / 360.0;
    double c = cos(theta);
    double s = sin(theta);
    double t = 1.0-c;

    matrix[0] = (t*x*x+c);
    matrix[1] = (t*x*y-s*z);
    matrix[2] = (t*x*z+s*y);
    matrix[3] = 0;
    matrix[4] = (t*x*y+s*z);
    matrix[5] = (t*y*y+c);
    matrix[6] = (t*y*z-s*x);
    matrix[7] = 0;
    matrix[8] = (t*x*z-s*y);
    matrix[9] = (t*y*z+s*x);
    matrix[10] = (t*z*z+c);
    matrix[11] = 0;
    matrix[12] = 0;
    matrix[13] = 0;
    matrix[14] = 0;
    matrix[15] = 1.0;
}

void InitKernelRGBA( float matrix[16], int16_t imatrix[16], float hueRotation, float sat, float brightness, float contrast );
void InitKernelRGBA( float matrix[16], int16_t imatrix[16], float hueRotation, float sat, float brightness, float contrast )
{
    float phi =  hueRotation / 360.0f * 2.0f * M_PI;
    float c = cos(phi);
    float s = sin(phi);
    int i;

    float start[16] = { 1.0, 0.0, 0.0, 0.0,
                        0.0, 1.0, 0.0, 0.0,
                        0.0, 0.0, 1.0, 0.0,
                        0.0, 0.0, 0.0, 1.0 };

    //scale along the x,y plane for saturation, and along Z for contrast and brightness
    float scale[16] = { sat,    0.0,    0.0,    0.0,
                        0.0,    sat,    0.0,    0.0,
                        0.0,    0.0,    contrast,    0.0,
                        0.0,    0.0,    0.0,    1.0 };

    //rotate around the z axis for hue rotation
    float rotate[16] = { c,     s,      0.0,    0.0,
                        -s,     c,      0.0,    0.0,
                        0.0,    0.0,    1.0,    0.0,
                        0.0,    0.0,    0.0,    1.0 };
                        
    //Rotate the Z axis around to 1,1,1
    //We do this by rotating the matrix 45 degrees around Z cross {1,1,1}
    // {0,0,1} x {1,1,1}/sqrt(3) = { -sqrt(3), sqrt(3), 0 }
    float xyz[3] = { -1.0/sqrt(2), 1.0/sqrt(2), 0.0f };
    float to111[16];
    float angle111to001 = acos( 1.0/sqrt(3)) * 360 / (2.0 * M_PI);
    InitRotationMatrix( xyz, angle111to001, to111 );

    //Rotate the brightness axis to Z
    MMult( matrix, start, to111 );

    //Apply the color rotation and scale matrices
    MMult( matrix, matrix, scale );
    MMult( matrix, matrix, rotate );

    //Rotate the result back around to 1,1,1
    InitRotationMatrix( xyz, -angle111to001, to111 );
    MMult( matrix, matrix, to111 );
    
    //convert the results for use for the integer matrix multiply
    for( i = 0; i < 16; i++ )
        imatrix[i] = matrix[i] * 8192.0f + 0.5f;
}

int MatrixMultiply2_ARGB8888( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    int16_t             rgbaMatrix[16];
    int16_t             argbMatrix[16];
    int32_t             brightness[4];
    float               matrix[16];
    HSBInfo             *v = params->hsbInfo; // hue rotation, saturation, brightness, contrast
    
    InitKernelRGBA( matrix, rgbaMatrix, v->hue, v->saturation, v->brightness, v->contrast );

    argbMatrix[0] = rgbaMatrix[15];
    argbMatrix[1] = rgbaMatrix[12];
    argbMatrix[2] = rgbaMatrix[13];
    argbMatrix[3] = rgbaMatrix[14];

    argbMatrix[4] = rgbaMatrix[3];
    argbMatrix[5] = rgbaMatrix[0];
    argbMatrix[6] = rgbaMatrix[1];
    argbMatrix[7] = rgbaMatrix[2];

    argbMatrix[8] = rgbaMatrix[7];
    argbMatrix[9] = rgbaMatrix[4];
    argbMatrix[10] = rgbaMatrix[5];
    argbMatrix[11] = rgbaMatrix[6];

    argbMatrix[12] = rgbaMatrix[11];
    argbMatrix[13] = rgbaMatrix[8];
    argbMatrix[14] = rgbaMatrix[9];
    argbMatrix[15] = rgbaMatrix[10];
    
    //sqrt(3) to account for the length of the unit {1,1,1} vector from black to white. 
    //It isn't really required. Its just provided so that the brightness has the same magnitude of effect
    //as the contrast.
    brightness[1] = brightness[2]= brightness[3] = 8192 * 255 * (v->brightness / sqrt(3) );
    brightness[0] = 0;

    return vImageMatrixMultiply_ARGB8888( src, dest, argbMatrix, 8192, NULL, brightness, flags);
        
}

int MatrixMultiply2_ARGBFFFF( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    int16_t             rgbaMatrix[16];
    float               argbMatrix[16];
    float               brightness[4];
    float               matrix[16];
    HSBInfo             *v = params->hsbInfo; // hue rotation, saturation, brightness, contrast
    
    InitKernelRGBA( matrix, rgbaMatrix, v->hue, v->saturation, v->brightness, v->contrast );

    argbMatrix[0] = matrix[15];
    argbMatrix[1] = matrix[12];
    argbMatrix[2] = matrix[13];
    argbMatrix[3] = matrix[14];

    argbMatrix[4] = matrix[3];
    argbMatrix[5] = matrix[0];
    argbMatrix[6] = matrix[1];
    argbMatrix[7] = matrix[2];

    argbMatrix[8] = matrix[7];
    argbMatrix[9] = matrix[4];
    argbMatrix[10] = matrix[5];
    argbMatrix[11] = matrix[6];

    argbMatrix[12] = matrix[11];
    argbMatrix[13] = matrix[8];
    argbMatrix[14] = matrix[9];
    argbMatrix[15] = matrix[10];
    
    //sqrt(3) to account for the length of the unit {1,1,1} vector from black to white. 
    //It isn't really required. Its just provided so that the brightness has the same magnitude of effect
    //as the contrast.
    brightness[1] = brightness[2]= brightness[3] =  (v->brightness / sqrt(3) );
    brightness[0] = 0;

    return vImageMatrixMultiply_ARGBFFFF( src, dest, argbMatrix, NULL, brightness, flags);
        
}


int MatrixMultiply_ARGB8888( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    return vImageMatrixMultiply_ARGB8888( src, dest, params->kernel, 8192, NULL, NULL, flags);
}

int MatrixMultiply_ARGBFFFF( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    return vImageMatrixMultiply_ARGBFFFF( src, dest, params->kernel, NULL, NULL, flags);        
}

int ClipFilter_FP( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    float *clips = params->kernel;
    return vImageClip_PlanarF( src, dest, clips[0], clips[1], flags);
}

int ClipFilterFP_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    float *clips = params->kernel;
    vImage_Buffer s = *src;
    vImage_Buffer d = *dest;

    s.width *= 4;
    d.width *= 4;
    
    return vImageClip_PlanarF( &s, &d, clips[0], clips[1], flags);
}

int Rotate90Filter( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int Rotate90Filter( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    Pixel_8 backColor = params->backgroundColor[params->colorChannel];
    uint8_t rotationConstant = (uint8_t)(params->info->rotate/ 90.0f) & 3;
    return vImageRotate90_Planar8( src, dest,  rotationConstant, backColor, flags );
}

int Rotate90FilterFP( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int Rotate90FilterFP( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    Pixel_F backColor = params->backgroundColor[params->colorChannel];
    uint8_t rotationConstant = (uint8_t)(params->info->rotate/ 90.0f) & 3;
    return vImageRotate90_PlanarF( src, dest,  rotationConstant, backColor, flags );
}

int Rotate90Filter_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int Rotate90Filter_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    Pixel_8888 backColor;
    uint8_t rotationConstant = (uint8_t)(params->info->rotate/ 90.0f) & 3;
    
    backColor[0] = params->backgroundColor[0];
    backColor[1] = params->backgroundColor[1];
    backColor[2] = params->backgroundColor[2];
    backColor[3] = params->backgroundColor[3];
    
    return vImageRotate90_ARGB8888( src, dest,  rotationConstant, backColor, flags );
}

int Rotate90FilterFP_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int Rotate90FilterFP_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    Pixel_FFFF backColor;
    uint8_t rotationConstant = (uint8_t)(params->info->rotate/ 90.0f) & 3;

    backColor[0] = params->backgroundColor[0];
    backColor[1] = params->backgroundColor[1];
    backColor[2] = params->backgroundColor[2];
    backColor[3] = params->backgroundColor[3];

    return vImageRotate90_ARGBFFFF( src, dest, rotationConstant, backColor, flags );
}
