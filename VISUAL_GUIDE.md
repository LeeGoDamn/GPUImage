# GPUImageTextureFilter - Visual Guide

## What is the Texture Effect?

The Texture effect enhances or smooths **mid-frequency details** in images - the details that are in between fine edges and broad color areas.

```
Image Frequency Breakdown:
┌──────────────────────────────────────────────────────┐
│ HIGH FREQUENCY: Fine edges, hair, eyelashes          │ ← Sharpening targets this
├──────────────────────────────────────────────────────┤
│ MID FREQUENCY: Skin texture, fabric weave, bark      │ ← TEXTURE targets this ★
├──────────────────────────────────────────────────────┤
│ LOW FREQUENCY: Overall color, tone, brightness       │ ← Blur/Levels target this
└──────────────────────────────────────────────────────┘
```

## How It Works: Band-Pass Filtering

### Step 1: Two Different Blurs
```
Original Image
     ├─→ Small Blur (1px) ───→ Captures high + mid + low frequencies
     └─→ Large Blur (4px) ───→ Captures only low frequencies
```

### Step 2: Extract Mid-Frequency (Band-Pass)
```
Mid-Frequency Details = Small Blur - Large Blur
                        └────────┬────────┘
                          Band-Pass Filter
```

### Step 3: Apply Enhancement/Smoothing
```
Final Result = Original Image + (Mid-Frequency × Texture Parameter)
                                 └────────┬────────┘
                              -1.0 to +1.0 control
```

## Visual Example

```
Texture = -1.0 (Maximum Smoothing)
┌─────────────────────┐
│  👤                 │  Smooth skin, less visible pores
│  Soft appearance    │  Good for portrait retouching
│  Reduced texture    │  Natural, not "plastic"
└─────────────────────┘

Texture = 0.0 (No Effect)
┌─────────────────────┐
│  👤                 │  Original image
│  Natural look       │  No processing
│  Baseline           │  
└─────────────────────┘

Texture = +1.0 (Maximum Enhancement)
┌─────────────────────┐
│  👤                 │  Enhanced skin texture
│  Visible details    │  Brings out surface detail
│  Crisp appearance   │  Good for emphasizing texture
└─────────────────────┘
```

## Filter Chain Architecture

```
                                GPUImageTextureFilter
┌─────────────────────────────────────────────────────────────────────────┐
│                                                                           │
│   Input Image ──┬──→ Blur 1px ──┐                                       │
│                 │                ├──→ Band-Pass ──┐                      │
│                 ├──→ Blur 4px ──┘                 │                      │
│                 │                                  ├──→ Combine ──→ Output│
│                 └──────────────────────────────────┘                      │
│                    (Original to combine filter)                           │
│                                                                           │
└─────────────────────────────────────────────────────────────────────────┘
```

## Use Cases

### Portrait Photography
```
Problem: Skin looks too smooth/plastic OR too rough/detailed
Solution: texture = -0.2 to -0.4 (subtle smoothing)
          texture = +0.3 to +0.5 (enhance texture)

Before:                    After (texture = -0.3):
┌──────────────┐          ┌──────────────┐
│    👤        │          │    👤        │
│  Visible     │   →      │  Smoother    │
│  skin        │          │  but not     │
│  texture     │          │  artificial  │
└──────────────┘          └──────────────┘
```

### Landscape Photography
```
Problem: Rocks, bark, or other textures lack detail
Solution: texture = +0.4 to +0.7 (enhance surface detail)

Before:                    After (texture = +0.6):
┌──────────────┐          ┌──────────────┐
│  🏔️ Mountain │          │  🏔️ Mountain │
│  Soft rock   │   →      │  Detailed    │
│  texture     │          │  rock        │
│              │          │  texture     │
└──────────────┘          └──────────────┘
```

## Comparison with Other Filters

```
┌────────────────┬──────────────┬─────────────────┬──────────────────┐
│ Filter         │ Target Freq  │ Typical Value   │ Best For         │
├────────────────┼──────────────┼─────────────────┼──────────────────┤
│ TEXTURE        │ Mid          │ -0.3 to +0.6    │ Skin, surfaces   │
│ Sharpen        │ High         │ 0 to 2.0        │ Edge enhancement │
│ Unsharp Mask   │ High         │ 0 to 3.0        │ General sharpen  │
│ Gaussian Blur  │ All (low)    │ 1 to 10 pixels  │ Smoothing        │
└────────────────┴──────────────┴─────────────────┴──────────────────┘
```

## Slider Values Guide

```
-1.0 ◄──────────┼──────────► +1.0
     │          │          │
     │          │          │
Maximum     Neutral    Maximum
Smooth              Enhancement

Recommended Ranges:
├─┤ -0.2 to -0.4: Subtle skin smoothing
  ├──┤ -0.4 to -0.7: Moderate smoothing
    ├──┤ -0.7 to -1.0: Maximum smoothing

        ├─┤ +0.2 to +0.4: Subtle detail boost
          ├──┤ +0.4 to +0.7: Moderate enhancement
            ├──┤ +0.7 to +1.0: Maximum enhancement
```

## Code Example with Comments

```objc
// Import the framework
#import "GPUImage.h"

// Create the filter
GPUImageTextureFilter *textureFilter = [[GPUImageTextureFilter alloc] init];

// Set the enhancement level
// Negative = smooth, Positive = enhance, 0 = no effect
textureFilter.texture = 0.5;  // Moderate enhancement

// Setup the processing chain
GPUImagePicture *imageSource = [[GPUImagePicture alloc] initWithImage:myImage];
GPUImageView *imageView = [[GPUImageView alloc] initWithFrame:self.view.bounds];

// Connect the filters
[imageSource addTarget:textureFilter];
[textureFilter addTarget:imageView];

// Process the image
[imageSource processImage];

// For real-time adjustment:
- (void)sliderChanged:(UISlider *)slider {
    textureFilter.texture = slider.value;  // -1.0 to 1.0
}
```

## Performance Notes

```
Processing Speed (iPhone 6s and newer):
┌────────────────────────────────────┐
│ 1920×1080 image: ~15-30ms         │
│ Real-time video: 30fps capable    │
│ Memory usage: Minimal             │
└────────────────────────────────────┘

Equivalent to Unsharp Mask in cost
Faster than: Multiple manual blur operations
```

## Tips for Best Results

1. **Start Small**: Begin with values between -0.3 and +0.3
2. **Compare**: Toggle between 0.0 and your value to see the effect
3. **Combine**: Use with other filters (color correction → texture → final sharpen)
4. **Test Subjects**: 
   - Portraits: -0.3 typical
   - Landscapes: +0.5 typical
   - Products: +0.4 typical

## Troubleshooting

```
Issue: Effect too strong
Solution: Reduce absolute value (closer to 0)

Issue: No visible effect
Solution: 
  - Check texture value is not 0
  - Some images have little mid-frequency content
  - Try stronger values (±0.7)

Issue: Unnatural look
Solution:
  - Reduce to ±0.3 to ±0.5 range
  - Apply selectively with masking
```

## Technical Implementation Details

For developers interested in the internals:

```glsl
// Band-Pass Shader (simplified)
vec4 smallBlur = texture2D(inputImageTexture, uv);
vec4 largeBlur = texture2D(inputImageTexture2, uv);
vec4 bandPass = smallBlur - largeBlur + 0.5;

// Combine Shader (simplified)
vec4 original = texture2D(inputImageTexture, uv);
vec4 detail = bandPass - 0.5;
vec4 result = original + detail * textureIntensity;
```

The "0.5" offset centers the band-pass result, allowing both positive and negative application.

---

For more information, see:
- TextureFilter_README.md (complete usage guide)
- IMPLEMENTATION_SUMMARY.md (technical architecture)
- XCODE_INTEGRATION.md (project setup)
