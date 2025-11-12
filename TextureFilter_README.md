# GPUImageTextureFilter

## Overview

The `GPUImageTextureFilter` is a new filter that enhances mid-frequency texture details in images, similar to Adobe Lightroom's Texture slider. This filter is particularly useful for:

- Enhancing skin texture details in portraits
- Bringing out surface details in landscapes  
- Smoothing textures when used with negative values (useful for skin retouching)

## How It Works

The Texture filter uses a **band-pass filtering** approach:

1. **Two Gaussian Blurs**: The input image is blurred with two different radii:
   - Small blur (1.0 pixel radius) - captures more frequencies
   - Large blur (4.0 pixel radius) - captures fewer frequencies

2. **Band-Pass Extraction**: The large blur is subtracted from the small blur to isolate mid-frequency details (the "texture" information)

3. **Enhancement/Smoothing**: The isolated texture detail is added back to the original image with adjustable intensity

This approach targets mid-frequency details without affecting:
- Fine high-frequency edges (like hair or eyelashes)
- Low-frequency tones and colors (overall brightness and color)

## Technical Comparison

| Tool | Frequency Target | Effect | Use Cases |
|------|-----------------|--------|-----------|
| **Texture** | Medium | Enhance/smooth texture | Skin, rocks, fabrics |
| Clarity | Broad/midtone | Edge contrast, adds drama | Skies, landscapes |
| Sharpen | High | Enhances fine detail/edges | Final print sharpness |
| Unsharp Mask | High | Sharpens edges with halo control | General sharpening |

## Usage

### Basic Example

```objc
#import "GPUImage.h"

// Create the filter
GPUImageTextureFilter *textureFilter = [[GPUImageTextureFilter alloc] init];

// Set the texture intensity
textureFilter.texture = 0.5; // Enhance texture (range: -1.0 to 1.0)

// Setup the filter chain
GPUImagePicture *imageSource = [[GPUImagePicture alloc] initWithImage:inputImage];
GPUImageView *imageView = [[GPUImageView alloc] initWithFrame:frame];

[imageSource addTarget:textureFilter];
[textureFilter addTarget:imageView];
[imageSource processImage];
```

### Property

- **`texture`** (CGFloat): Controls the intensity of texture enhancement
  - **-1.0**: Maximum smoothing (softens texture details)
  - **0.0**: No effect (neutral)
  - **+1.0**: Maximum enhancement (emphasizes texture details)

### Portrait Retouching Example

```objc
// For subtle skin smoothing
textureFilter.texture = -0.3;

// For enhanced skin detail
textureFilter.texture = 0.4;
```

### Landscape Enhancement Example

```objc
// Bring out detail in rocks, bark, etc.
textureFilter.texture = 0.6;
```

### Video Processing Example

```objc
GPUImageVideoCamera *videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionBack];
videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;

GPUImageTextureFilter *textureFilter = [[GPUImageTextureFilter alloc] init];
textureFilter.texture = 0.3;

GPUImageView *filteredVideoView = [[GPUImageView alloc] initWithFrame:self.view.bounds];

[videoCamera addTarget:textureFilter];
[textureFilter addTarget:filteredVideoView];

[videoCamera startCameraCapture];
```

## Adding to Xcode Project

The source files are:
- `framework/Source/GPUImageTextureFilter.h`
- `framework/Source/GPUImageTextureFilter.m`

To use this filter in your project:

### Option 1: Using Xcode GUI

1. Open `GPUImage.xcodeproj` in Xcode
2. Right-click on the "Source" group and select "Add Files to 'GPUImage'..."
3. Add both `GPUImageTextureFilter.h` and `GPUImageTextureFilter.m`
4. Make sure "Copy items if needed" is checked and target is selected
5. Build the project

### Option 2: Manual project.pbxproj Editing

If you need to edit the project file manually:

1. Open `framework/GPUImage.xcodeproj/project.pbxproj` in a text editor
2. Add file references in the `PBXFileReference` section
3. Add build files in the `PBXBuildFile` section
4. Add to the source group in the `PBXGroup` section
5. Add to the appropriate build phases

## Implementation Details

### Filter Chain Architecture

The `GPUImageTextureFilter` extends `GPUImageFilterGroup` and chains multiple filters:

```
Input Image
    ├─> Blur Filter 1 (small radius) ─┐
    ├─> Blur Filter 2 (large radius) ─┼─> Band-Pass Filter ─┐
    └────────────────────────────────────────────────────────┴─> Combine Filter -> Output
```

### Shader Details

Two custom GLSL fragment shaders are used:

1. **Band-Pass Shader**: Subtracts the large blur from small blur to isolate mid-frequency details
2. **Combine Shader**: Blends the band-pass detail back with the original image based on intensity

## Performance Considerations

- Uses two Gaussian blur passes (internally uses separable convolution for efficiency)
- Suitable for real-time video processing on modern iOS devices
- Performance is similar to `GPUImageUnsharpMaskFilter` (both use blur + combine approach)

## Comparison with Other Filters

### vs. GPUImageSharpenFilter
- **Sharpen**: Enhances high-frequency edges, can amplify noise
- **Texture**: Targets mid-frequency details, preserves smooth areas

### vs. GPUImageUnsharpMaskFilter  
- **Unsharp Mask**: Single blur with edge enhancement, general sharpening
- **Texture**: Dual blur with band-pass, specific to texture detail

### vs. Clarity (not in GPUImage)
- **Clarity**: Broad midtone contrast enhancement, affects saturation
- **Texture**: Focused on detail structure, minimal color shift

## Tips and Best Practices

1. **Start with low values**: Begin with texture values around ±0.2-0.3 and adjust
2. **Combine with other filters**: Works well after color correction but before final sharpening
3. **Portrait workflow**: Use negative values (-0.2 to -0.4) for natural skin smoothing
4. **Landscape workflow**: Use positive values (0.3 to 0.7) for enhanced detail
5. **Avoid extremes**: Values near ±1.0 can create unnatural results

## License

This filter follows the same BSD-style license as the GPUImage framework.

## Credits

Based on research into Adobe Lightroom's Texture effect and frequency separation techniques used in professional photo editing.
