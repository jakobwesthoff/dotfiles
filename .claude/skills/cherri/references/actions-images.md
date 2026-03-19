---
name: actions-images
description: Image editing, GIF creation, and photo library management actions
metadata:
  tags: cherri, actions, images, photos, gif
---

## Images (`#include 'actions/images'`)

**imageCombineMode**: `Vertically`, `In a Grid`

**cropImagePosition**: `Center`, `Top Left`, `Top Right`, `Bottom Left`, `Bottom Right`, `Custom`

**flipImageDirection**: `Horizontal`, `Vertical`

**maskImageType**: `Rounded Rectangle`, `Ellipse`, `Icon`

**customImageOverlayPosition**: `Center`, `Top Left`, `Top Right`, `Bottom Left`, `Bottom Right`, `Custom`

**convertImageFormats**: `TIFF`, `GIF`, `PNG`, `BMP`, `PDF`, `HEIF`

**imageDetail**: `Album`, `Width`, `Height`, `Date Taken`, `Media Type`, `Photo Type`, `Is a Screenshot`, `Is a Screen Recording`, `Location`, `Duration`, `Frame Rate`, `Orientation`, `Camera Make`, `Camera Model`, `Metadata Dictionary`, `Is Favorite`, `File Size`, `File Extension`, `Creation Date`, `File Path`, `Last Modified Date`, `Name`

Combine multiple images into one.
`combineImages(variable images, imageCombineMode ?mode = "Vertically", number ?spacing = 1)`

Crop an image to specified dimensions and position.
`cropImage(variable image, text ?width = "100", text ?height = "100", cropImagePosition ?position = "Center", text ?customPositionX, text ?customPositionY)`

Flip an image horizontally or vertically.
`flipImage(variable image, flipImageDirection direction)`

Mask an image with a shape type.
`maskImage(variable image, maskImageType type, text ?radius)`

Mask an image with a custom image.
`customImageMask(variable image, variable customMaskImage)`

Overlay an image on top of another image (shows editor).
`overlayImage(variable image, variable overlayImage)`

Specify custom image overlay configuration programmatically.
`customImageOverlay(variable image, variable overlayImage, text ?width, text ?height, text ?rotation = "0", text ?opacity = "100", customImageOverlayPosition ?position = "Center", text ?customPositionX, text ?customPositionY)`

Resize an image to specific pixel dimensions.
`resizeImage(variable image, text width, text ?height)`

Resize an image by a percentage of its original size.
`resizeImageByPercent(variable image, text percentage)`

Resize an image so its longest edge matches a given length.
`resizeImageByLongestEdge(variable image, text length)`

Remove the background from an image, with optional crop.
`removeBackground(variable image, bool ?crop = false)`

Rotate an image or video by a specified number of degrees.
`rotateMedia(variable media, text degrees)`

Convert an image to another format with optional quality and metadata control.
`convertImage(variable image, convertImageFormats format, float ?quality, bool ?preserveMetadata = true)`

Convert an image to JPEG with optional compression quality.
`convertToJPEG(variable image, number ?compressionQuality, bool ?preserveMetadata = true)`

Strip all metadata from an image.
`stripImageMetadata(variable image)`

Get a specific detail about an image.
`getImageDetail(variable image, imageDetail detail)`

Create an image from rich text (PDF).
`makeImageFromRichText(variable pdf, text width, text height)`

Extract text content from an image using OCR.
`extractImageText(variable image): text`

Detect and return all images from the input.
`getImages(variable input): array`

Create a GIF from images or video with configurable delay and dimensions.
`makeGIF(variable input, text ?delay = "0.3", number ?loops, text ?width, text ?height)`

Add a frame to an existing GIF.
`addToGIF(variable image, variable gif, text ?delay = "0.25", bool ?autoSize = true, text ?width, text ?height)`

Convert a GIF to a video with a specified number of loops.
`makeVideoFromGIF(variable gif, number ?loops = 1)`

Extract individual frames from a GIF.
`getImageFrames(variable image)`

---

## Photos (`#include 'actions/photos'`)

Create a new photo album, optionally adding images immediately.
`createAlbum(text name, variable ?images)`

Rename an existing photo album.
`renameAlbum(variable album, text newTitle)`

Search the photo library by criteria string.
`searchPhotos(text criteria): array`

Delete photos from the library.
`deletePhotos(variable photos)`

Get the photos from the most recent import.
`getLastImport()`

Get the most recent burst photos.
`getLatestBursts(number count)`

Get the most recent Live Photos.
`getLatestLivePhotos(number count)`

Get the most recent screenshots.
`getLatestScreenshots(number count)`

Get the most recently taken photos, with optional screenshot inclusion.
`getLatestPhotos(number count, bool ?includeScreenshots = true)`

Get the most recently taken videos.
`getLatestVideos(number count)`

Remove a photo from a named album.
`removeFromAlbum(variable photo, text album)`

Save an image to the photo library in a named album.
`savePhoto(variable image, text ?album = "Recents")`

Prompt the user to select photos from their library.
`selectPhotos(bool ?selectMultiple = false)`
