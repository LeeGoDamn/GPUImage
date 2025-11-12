# Texture Filter - Quick Start Guide

## What is This?

A new `GPUImageTextureFilter` has been added to the GPUImage framework that replicates Adobe Lightroom's Texture effect. This filter enhances or smooths mid-frequency texture details in images.

## Quick Usage

```objc
#import "GPUImage.h"

GPUImageTextureFilter *filter = [[GPUImageTextureFilter alloc] init];
filter.texture = 0.5;  // Range: -1.0 (smooth) to +1.0 (enhance)

[imageSource addTarget:filter];
[filter addTarget:output];
```

## Documentation Files

📖 **New to this filter?** Start here:
- **[VISUAL_GUIDE.md](VISUAL_GUIDE.md)** - Diagrams and visual examples

📚 **Ready to use it?** Read this:
- **[TextureFilter_README.md](TextureFilter_README.md)** - Complete API reference and examples

🔧 **Want to build it?** Follow this:
- **[XCODE_INTEGRATION.md](XCODE_INTEGRATION.md)** - Add files to Xcode project

🏗 **Technical details?** Check this:
- **[IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md)** - Architecture and implementation

## Quick Parameter Guide

| Value | Effect | Best For |
|-------|--------|----------|
| -0.3 | Subtle smoothing | Portrait skin |
| 0.0 | No effect | Neutral |
| +0.5 | Moderate enhancement | Landscapes, textures |

## Files Added

**Core Implementation:**
- `framework/Source/GPUImageTextureFilter.h`
- `framework/Source/GPUImageTextureFilter.m`

**Documentation:**
- `TextureFilter_README.md`
- `VISUAL_GUIDE.md`
- `IMPLEMENTATION_SUMMARY.md`
- `XCODE_INTEGRATION.md`

**Modified:**
- `framework/Source/GPUImage.h` (added import)
- `framework/Source/Mac/GPUImage.h` (added import)
- FilterShowcase example (added demo)

## Next Steps

1. **Add to Xcode Project**: See [XCODE_INTEGRATION.md](XCODE_INTEGRATION.md)
2. **Build Framework**: `xcodebuild -project framework/GPUImage.xcodeproj`
3. **Test**: Run FilterShowcase app and select "Texture" filter
4. **Use**: Import in your project and use as shown above

## Try It Now

The FilterShowcase example already includes the Texture filter:
1. Open `examples/iOS/FilterShowcase/FilterShowcase.xcodeproj`
2. Build and run
3. Select "Texture" from the filter list
4. Adjust the slider to see real-time effects

## Support

For detailed information, see the documentation files listed above.
