#import "GPUImageFilterGroup.h"

@class GPUImageGaussianBlurFilter;
@class GPUImageTwoInputFilter;

/** The Texture filter enhances mid-frequency detail in images, similar to Adobe Lightroom's Texture slider.
 
 This filter uses a band-pass approach to isolate and enhance texture details without affecting 
 fine edges or overall tone. It's particularly useful for:
 - Enhancing skin texture details in portraits
 - Bringing out surface details in landscapes
 - Smoothing textures when used with negative values
 
 The texture parameter ranges from -1.0 (smooth textures) to 1.0 (enhance textures), with 0.0 having no effect.
 */
@interface GPUImageTextureFilter : GPUImageFilterGroup
{
    GPUImageGaussianBlurFilter *blurFilter1;
    GPUImageGaussianBlurFilter *blurFilter2;
    GPUImageTwoInputFilter *bandPassFilter;
    GPUImageTwoInputFilter *combineFilter;
}

/** The intensity of texture enhancement. Ranges from -1.0 (smooth) to 1.0 (enhance), with 0.0 being neutral.
 */
@property(readwrite, nonatomic) CGFloat texture;

@end
