USING: graphics.bitmap graphics.viewer ;
IN: graphics.bitmap.tests

: test-bitmap24 ( -- )
    "resource:extra/graphics/bitmap/test-images/thiswayup24.bmp" bitmap. ;

: test-bitmap8 ( -- )
    "resource:extra/graphics/bitmap/test-images/rgb8bit.bmp" bitmap. ;

: test-bitmap4 ( -- )
    "resource:extra/graphics/bitmap/test-images/rgb4bit.bmp" bitmap. ;

: test-bitmap1 ( -- )
    "resource:extra/graphics/bitmap/test-images/1bit.bmp" bitmap. ;

