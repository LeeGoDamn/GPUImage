#import "GPUImageTextureFilter.h"
#import "GPUImageFilter.h"
#import "GPUImageTwoInputFilter.h"
#import "GPUImageGaussianBlurFilter.h"

// Shader for subtracting two blur levels to create band-pass
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
NSString *const kGPUImageTextureBandPassFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 varying highp vec2 textureCoordinate2;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 
 void main()
 {
     lowp vec4 smallBlur = texture2D(inputImageTexture, textureCoordinate);
     lowp vec4 largeBlur = texture2D(inputImageTexture2, textureCoordinate2);
     
     // Band-pass: subtract large blur from small blur to isolate mid-frequency details
     gl_FragColor = vec4(smallBlur.rgb - largeBlur.rgb + vec3(0.5), smallBlur.a);
 }
);
#else
NSString *const kGPUImageTextureBandPassFragmentShaderString = SHADER_STRING
(
 varying vec2 textureCoordinate;
 varying vec2 textureCoordinate2;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 
 void main()
 {
     vec4 smallBlur = texture2D(inputImageTexture, textureCoordinate);
     vec4 largeBlur = texture2D(inputImageTexture2, textureCoordinate2);
     
     // Band-pass: subtract large blur from small blur to isolate mid-frequency details
     gl_FragColor = vec4(smallBlur.rgb - largeBlur.rgb + vec3(0.5), smallBlur.a);
 }
);
#endif

// Shader for combining original image with band-pass detail
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
NSString *const kGPUImageTextureCombineFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 varying highp vec2 textureCoordinate2;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 
 uniform highp float texture;
 
 void main()
 {
     lowp vec4 originalColor = texture2D(inputImageTexture, textureCoordinate);
     lowp vec4 bandPassDetail = texture2D(inputImageTexture2, textureCoordinate2);
     
     // Extract the detail (centered at 0.5)
     lowp vec3 detail = bandPassDetail.rgb - vec3(0.5);
     
     // Apply texture enhancement/smoothing
     lowp vec3 result = originalColor.rgb + detail * texture;
     
     gl_FragColor = vec4(result, originalColor.a);
 }
);
#else
NSString *const kGPUImageTextureCombineFragmentShaderString = SHADER_STRING
(
 varying vec2 textureCoordinate;
 varying vec2 textureCoordinate2;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 
 uniform float texture;
 
 void main()
 {
     vec4 originalColor = texture2D(inputImageTexture, textureCoordinate);
     vec4 bandPassDetail = texture2D(inputImageTexture2, textureCoordinate2);
     
     // Extract the detail (centered at 0.5)
     vec3 detail = bandPassDetail.rgb - vec3(0.5);
     
     // Apply texture enhancement/smoothing
     vec3 result = originalColor.rgb + detail * texture;
     
     gl_FragColor = vec4(result, originalColor.a);
 }
);
#endif

@implementation GPUImageTextureFilter

@synthesize texture = _texture;

- (id)init;
{
    if (!(self = [super init]))
    {
        return nil;
    }
    
    // First blur: small radius (captures more frequencies)
    blurFilter1 = [[GPUImageGaussianBlurFilter alloc] init];
    blurFilter1.blurRadiusInPixels = 1.0;
    [self addFilter:blurFilter1];
    
    // Second blur: larger radius (captures fewer frequencies) 
    blurFilter2 = [[GPUImageGaussianBlurFilter alloc] init];
    blurFilter2.blurRadiusInPixels = 4.0;
    [self addFilter:blurFilter2];
    
    // Create band-pass by subtracting the two blurs
    bandPassFilter = [[GPUImageTwoInputFilter alloc] initWithFragmentShaderFromString:kGPUImageTextureBandPassFragmentShaderString];
    [self addFilter:bandPassFilter];
    
    [blurFilter1 addTarget:bandPassFilter atTextureLocation:0];
    [blurFilter2 addTarget:bandPassFilter atTextureLocation:1];
    
    // Combine original image with the band-pass detail
    combineFilter = [[GPUImageTwoInputFilter alloc] initWithFragmentShaderFromString:kGPUImageTextureCombineFragmentShaderString];
    [self addFilter:combineFilter];
    
    [bandPassFilter addTarget:combineFilter atTextureLocation:1];
    
    // Setup filter chain:
    // Input -> blurFilter1 -> bandPassFilter
    //      \-> blurFilter2 -/                \
    //      \---------------------------------> combineFilter -> Output
    self.initialFilters = [NSArray arrayWithObjects:blurFilter1, blurFilter2, combineFilter, nil];
    self.terminalFilter = combineFilter;
    
    self.texture = 0.0;
    
    return self;
}

#pragma mark -
#pragma mark Accessors

- (void)setTexture:(CGFloat)newValue;
{
    _texture = newValue;
    [combineFilter setFloat:newValue forUniformName:@"texture"];
}

@end
