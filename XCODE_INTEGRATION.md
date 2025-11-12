# Adding GPUImageTextureFilter to Xcode Project

## Quick Guide

Since the files have been created but need to be added to the Xcode project, follow these steps:

## Method 1: Using Xcode (Recommended)

1. Open `framework/GPUImage.xcodeproj` in Xcode
2. In the Project Navigator (left sidebar), find the "Source" folder
3. Right-click on "Source" and select "Add Files to 'GPUImage'..."
4. Navigate to `framework/Source/`
5. Select both files:
   - `GPUImageTextureFilter.h`
   - `GPUImageTextureFilter.m`
6. In the dialog:
   - ✓ Check "Copy items if needed"
   - ✓ Select "GPUImage" target
   - ✓ Choose "Create groups" (not references)
7. Click "Add"
8. Build the project (⌘+B)

## Method 2: Manually Edit project.pbxproj

If you need to manually edit the project file, you'll need to add entries in three sections:

### 1. PBXFileReference Section

Add these two lines (generate new UUIDs for the keys):

```
XXXXXXXX /* GPUImageTextureFilter.h */ = {isa = PBXFileReference; fileEncoding = 4; lastKnownFileType = sourcecode.c.h; name = GPUImageTextureFilter.h; path = Source/GPUImageTextureFilter.h; sourceTree = SOURCE_ROOT; };
YYYYYYYY /* GPUImageTextureFilter.m */ = {isa = PBXFileReference; fileEncoding = 4; lastKnownFileType = sourcecode.c.objc; name = GPUImageTextureFilter.m; path = Source/GPUImageTextureFilter.m; sourceTree = SOURCE_ROOT; };
```

### 2. PBXBuildFile Section

Add these two lines (generate new UUIDs for the keys):

```
ZZZZZZZZ /* GPUImageTextureFilter.h in Headers */ = {isa = PBXBuildFile; fileRef = XXXXXXXX /* GPUImageTextureFilter.h */; };
WWWWWWWW /* GPUImageTextureFilter.m in Sources */ = {isa = PBXBuildFile; fileRef = YYYYYYYY /* GPUImageTextureFilter.m */; };
```

For the framework target, also add:

```
VVVVVVVV /* GPUImageTextureFilter.h in Headers */ = {isa = PBXBuildFile; fileRef = XXXXXXXX /* GPUImageTextureFilter.h */; settings = {ATTRIBUTES = (Public, ); }; };
```

### 3. Add to Source Group

In the `PBXGroup` section, find the "Source" group and add the file references:

```
children = (
    ...
    BCC1E60E152156620006EFA5 /* GPUImageUnsharpMaskFilter.h */,
    BCC1E60F152156620006EFA5 /* GPUImageUnsharpMaskFilter.m */,
    XXXXXXXX /* GPUImageTextureFilter.h */,
    YYYYYYYY /* GPUImageTextureFilter.m */,
    ...
);
```

### 4. Add to Build Phases

Find the "Headers" build phase and add:
```
ZZZZZZZZ /* GPUImageTextureFilter.h in Headers */,
```

Find the "Sources" build phase and add:
```
WWWWWWWW /* GPUImageTextureFilter.m in Sources */,
```

For the Framework target, add to its Headers phase:
```
VVVVVVVV /* GPUImageTextureFilter.h in Headers */,
```

## Generating UUIDs

To generate UUIDs for the project file:
```bash
uuidgen | tr '[:upper:]' '[:lower:]' | tr -d '\n' | cut -c 1-24 | tr '-' '0'
```

Run this command 5-6 times to generate unique identifiers for each reference.

## Verification

After adding the files, verify the build:

```bash
cd framework
xcodebuild -project GPUImage.xcodeproj -target GPUImage -configuration Release -sdk iphoneos build
```

## Adding to Mac Project

Repeat the same steps for `framework/GPUImageMac.xcodeproj` to support Mac builds.

## Testing

Create a simple test in one of the example projects:

```objc
#import "GPUImage.h"

GPUImageTextureFilter *textureFilter = [[GPUImageTextureFilter alloc] init];
textureFilter.texture = 0.5;

// Test with an image
GPUImagePicture *imageSource = [[GPUImagePicture alloc] initWithImage:[UIImage imageNamed:@"test.jpg"]];
[imageSource addTarget:textureFilter];
// ... add to view or save
[imageSource processImage];
```

## Common Issues

### Issue: "Unknown class GPUImageTextureFilter"
**Solution**: Make sure the .h and .m files are added to the correct target in Xcode.

### Issue: Build fails with missing symbols
**Solution**: Verify that GPUImageTextureFilter.m is listed in the "Compile Sources" build phase.

### Issue: Header not found
**Solution**: Ensure the header is in the "Headers" build phase and marked as Public for framework builds.
