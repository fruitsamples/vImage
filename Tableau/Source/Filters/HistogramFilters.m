/*
 *  ConvolutionFilters.c
 *
 *  Created by Robert Murley on Fri Feb 21 2003.
 *  Copyright (c) 2003 Apple Computer, Inc. All rights reserved.
 *
 */

#import "Filters.h"

void StdToSpecified_PlanarF( vImage_Buffer *src, paramList *params );
void StdToSpecified_PlanarF( vImage_Buffer *src, paramList *params )
{
    float	*srcRow;
    int		h, w;
    
    srcRow = (float *) src->data;
    for ( h = 0; h < src->height; h++ )
    {
        for ( w = 0; w < src->width; w++ )
            srcRow[w] = srcRow[w] * ( params->max - params->min ) + params->min;
        srcRow += src->rowBytes/4;
    }
}

void SpecifiedToStd_PlanarF( vImage_Buffer *src, paramList *params );
void SpecifiedToStd_PlanarF( vImage_Buffer *src, paramList *params )
{
    float	*srcRow;
    int		h, w;
    
    srcRow = (float *) src->data;
    for ( h = 0; h < src->height; h++ )
    {
        for ( w = 0; w < src->width; w++ )
            srcRow[w] = ( srcRow[w] - params->min ) / ( params->max - params->min );
        srcRow += src->rowBytes/4;
    }
}

void StdToSpecified_ARGBFFFF( vImage_Buffer *src, paramList *params );
void StdToSpecified_ARGBFFFF( vImage_Buffer *src, paramList *params )
{
    float	*srcRow;
    int		h, w;
    
    srcRow = (float *) src->data;
    for ( h = 0; h < src->height; h++ )
    {
        for ( w = 0; w < src->width; w++ )
        {
            srcRow[4*w] = srcRow[4*w] * ( params->max - params->min ) + params->min;
            srcRow[4*w+1] = srcRow[4*w+1] * ( params->max - params->min ) + params->min;
            srcRow[4*w+2] = srcRow[4*w+2] * ( params->max - params->min ) + params->min;
            srcRow[4*w+3] = srcRow[4*w+3] * ( params->max - params->min ) + params->min;
        }
        srcRow += src->rowBytes/4;
    }
}

void SpecifiedToStd_ARGBFFFF( vImage_Buffer *src, paramList *params );
void SpecifiedToStd_ARGBFFFF( vImage_Buffer *src, paramList *params )
{
    float	*srcRow;
    int		h, w;
    
    srcRow = (float *) src->data;
    for ( h = 0; h < src->height; h++ )
    {
        for ( w = 0; w < src->width; w++ )
        {
            srcRow[4*w] = ( srcRow[4*w] - params->min ) / ( params->max - params->min );
            srcRow[4*w+1] = ( srcRow[4*w+1] - params->min ) / ( params->max - params->min );
            srcRow[4*w+2] = ( srcRow[4*w+2] - params->min ) / ( params->max - params->min );
            srcRow[4*w+3] = ( srcRow[4*w+3] - params->min ) / ( params->max - params->min );
        }
        srcRow += src->rowBytes/4;
    }
}

int Histogram( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int Histogram( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    vImage_Error err;
    unsigned long   histogram[256];

    err = vImageHistogramCalculation_Planar8(	src, 	//const vImage_Buffer *src
                                        histogram,	//array to receive histogram, 
                                        flags
                                    );

    return err;
}


int HistogramFP( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int HistogramFP( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    vImage_Error err;
    unsigned long   histogram[256];

    err = vImageHistogramCalculation_PlanarF(	src, 	//const vImage_Buffer *src
                                        histogram,	//array to receive histogram, 
										params->histogramEntries,
                                        params->max,
                                        params->min,
                                        flags
                                    );
    
    return err;
}


int Histogram_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int Histogram_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    vImage_Error err;
    unsigned long   hist0[256], hist1[256], hist2[256], hist3[256];
	unsigned long   *histogram[4] = { hist0, hist1, hist2, hist3 };

    err = vImageHistogramCalculation_ARGB8888(	src, 	//const vImage_Buffer *src
                                        histogram,	//array to receive histogram, 
                                        flags
                                    );

    return err;
}


int HistogramFP_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int HistogramFP_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    vImage_Error err;
    unsigned long   hist0[256], hist1[256], hist2[256], hist3[256];
    unsigned long   *histogram[4] = { hist0, hist1, hist2, hist3 };

    err = vImageHistogramCalculation_ARGBFFFF(	src, 	//const vImage_Buffer *src
                                        histogram,	//array to receive histogram, 
										params->histogramEntries,
                                        params->max,
                                        params->min,
                                        flags
                                    );
    
    return err;
}


int Histogram_Equalization( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int Histogram_Equalization( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    vImage_Error err;

    err = vImageEqualization_Planar8(	src, 	//const vImage_Buffer *src
                                        dest,	//const vImage_Buffer *dest, 
                                        flags
                                    );

    return err;
}


int Histogram_EqualizationFP( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int Histogram_EqualizationFP( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    vImage_Error err;

    err = vImageEqualization_PlanarF(	src, 	//const vImage_Buffer *src
                                        dest,	//const vImage_Buffer *dest, 
										NULL,	//temp buffer 
										params->histogramEntries,
                                        params->min,
                                        params->max,
                                        flags
                                    );
    
    return err;
}


int Histogram_Equalization_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int Histogram_Equalization_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    vImage_Error err;

    err = vImageEqualization_ARGB8888(	src, 	//const vImage_Buffer *src
                                        dest,	//const vImage_Buffer *dest, 
                                        flags
                                    );

    return err;
}


int Histogram_EqualizationFP_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int Histogram_EqualizationFP_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    vImage_Error err;

    err = vImageEqualization_ARGBFFFF(	src, 	//const vImage_Buffer *src
                                        dest,	//const vImage_Buffer *dest, 
										NULL,	//temp buffer 
										params->histogramEntries,
                                        params->min,
                                        params->max,
                                        flags
                                    );
    
    return err;
}


int Histogram_Specification( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int Histogram_Specification( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    vImage_Error err;
    unsigned long	*histogram;

    switch ( params->colorChannel++ )
    {
        case 0:	histogram = params->alphaHistogram;	break;
        case 1:	histogram = params->redHistogram;	break;
        case 2:	histogram = params->greenHistogram;	break;
        case 3:	histogram = params->blueHistogram;	break;
        default:	return -1;
    }

    err = vImageHistogramSpecification_Planar8(	src, dest, histogram, flags );

    return err;
}


int Histogram_SpecificationFP( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int Histogram_SpecificationFP( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    vImage_Error err;
    unsigned long   *histogram;

    StdToSpecified_PlanarF( src, params );

    switch ( params->colorChannel++ )
    {
        case 0:	histogram = params->redHistogram;	break;
        case 1:	histogram = params->greenHistogram;	break;
        case 2:	histogram = params->blueHistogram;	break;
        case 3:	histogram = params->alphaHistogram;	break;
        default:	return -1;
    }

    err = vImageHistogramSpecification_PlanarF(	src,
                                        dest,
										NULL, 
                                        histogram,
										params->histogramEntries,
                                        params->min,
                                        params->max,
                                        flags
                                    );
    
    SpecifiedToStd_PlanarF( dest, params );
    
    return err;
}


int Histogram_Specification_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int Histogram_Specification_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    vImage_Error		err;
    unsigned long		*histogram[4];
    
    histogram[0] = params->alphaHistogram;    
    histogram[1] = params->redHistogram;
    histogram[2] = params->greenHistogram;
    histogram[3] = params->blueHistogram;

    err = vImageHistogramSpecification_ARGB8888( src, dest, (const unsigned long **) histogram, flags );

    return err;
}


int Histogram_SpecificationFP_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int Histogram_SpecificationFP_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    vImage_Error		err;
    unsigned long		*histogram[4];
    
    StdToSpecified_ARGBFFFF( src, params );

    histogram[0] = params->alphaHistogram;    
    histogram[1] = params->redHistogram;
    histogram[2] = params->greenHistogram;
    histogram[3] = params->blueHistogram;

    err = vImageHistogramSpecification_ARGBFFFF(	src, 	//const vImage_Buffer *src
                                        dest,	//const vImage_Buffer *dest, 
										NULL,	//temp buffer 
                                        (const unsigned long **) histogram,	//array to receive histogram, 
										params->histogramEntries,
                                        params->min,
                                        params->max,
                                        flags
                                    );
    
    SpecifiedToStd_ARGBFFFF( dest, params );
    
    return err;
}


int Histogram_Contrast_Stretch( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int Histogram_Contrast_Stretch( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    vImage_Error err;

    err = vImageContrastStretch_Planar8(	src, 	//const vImage_Buffer *src
                                        dest,	//const vImage_Buffer *dest, 
                                        flags
                                    );
    
    return err;
}


int Histogram_Contrast_StretchFP( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int Histogram_Contrast_StretchFP( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    vImage_Error err;

    err = vImageContrastStretch_PlanarF(	src, 	//const vImage_Buffer *src
                                        dest,	//const vImage_Buffer *dest, 
										NULL,	//temp buffer 
										params->histogramEntries,
                                        params->min,
                                        params->max,
                                        flags
                                    );
    
    return err;
}


int Histogram_Contrast_Stretch_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int Histogram_Contrast_Stretch_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    vImage_Error err;

    err = vImageContrastStretch_ARGB8888(	src, 	//const vImage_Buffer *src
                                        dest,	//const vImage_Buffer *dest, 
                                        flags
                                    );
    
    return err;
}


int Histogram_Contrast_StretchFP_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int Histogram_Contrast_StretchFP_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    vImage_Error err;

    err = vImageContrastStretch_ARGBFFFF(	src, 	//const vImage_Buffer *src
                                        dest,	//const vImage_Buffer *dest, 
										NULL,	//temp buffer 
										params->histogramEntries,
                                        params->min,
                                        params->max,
                                        flags
                                    );
    
    return err;
}


int Histogram_Ends_In_Contrast_Stretch( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int Histogram_Ends_In_Contrast_Stretch( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    vImage_Error err;

    err = vImageEndsInContrastStretch_Planar8(	src, 	//const vImage_Buffer *src
                                        dest,	//const vImage_Buffer *dest, 
										params->low,	// low end
										params->high,	// high end
                                        flags
                                    );
    
    return err;
}


int Histogram_Ends_In_Contrast_StretchFP( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int Histogram_Ends_In_Contrast_StretchFP( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    vImage_Error err;

    err = vImageEndsInContrastStretch_PlanarF(	src, 	//const vImage_Buffer *src
                                        dest,	//const vImage_Buffer *dest, 
										NULL,	//temp buffer 
										params->low,	// low end
										params->high,	// high end
										params->histogramEntries,
                                        params->min,
                                        params->max,
                                        flags
                                    );
    
    return err;
}


int Histogram_Ends_In_Contrast_Stretch_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int Histogram_Ends_In_Contrast_Stretch_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    vImage_Error err;
	unsigned int   lowend[4] = { params->low, params->low, params->low, params->low };
	unsigned int   highend[4] = { params->high, params->high, params->high, params->high };

    err = vImageEndsInContrastStretch_ARGB8888(	src, 	//const vImage_Buffer *src
                                        dest,	//const vImage_Buffer *dest, 
                                        lowend,		// low end
										highend,	// high end
                                        flags
                                    );
    
    return err;
}


int Histogram_Ends_In_Contrast_StretchFP_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params );
int Histogram_Ends_In_Contrast_StretchFP_ARGB( vImage_Buffer *src, vImage_Buffer *dest, vImage_Flags flags, paramList *params )
{
    vImage_Error err;
	unsigned int   lowend[4] = { params->low, params->low, params->low, params->low };
	unsigned int   highend[4] = { params->high, params->high, params->high, params->high };

    err = vImageEndsInContrastStretch_ARGBFFFF(	src, 	//const vImage_Buffer *src
                                        dest,	//const vImage_Buffer *dest, 
										NULL,	//temp buffer 
                                        lowend,		// low end
										highend,	// high end
										params->histogramEntries,
                                        params->min,
                                        params->max,
                                        flags
                                    );
    
    return err;
}
