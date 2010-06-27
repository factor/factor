! (c)2010 Joe Groff bsd license
USING: accessors alien.data cocoa cocoa.classes cocoa.messages
combinators core-foundation.data core-graphics.types fry images
images.loader io kernel literals ;
IN: images.cocoa

SINGLETON: ns-image
! "png" ns-image register-image-class
! "tif" ns-image register-image-class
! "tiff" ns-image register-image-class
! "gif" ns-image register-image-class
! "jpg" ns-image register-image-class
! "jpeg" ns-image register-image-class
! "bmp" ns-image register-image-class
! "ico" ns-image register-image-class

CONSTANT: NSImageRepLoadStatusUnknownType     -1
CONSTANT: NSImageRepLoadStatusReadingHeader   -2
CONSTANT: NSImageRepLoadStatusWillNeedAllData -3
CONSTANT: NSImageRepLoadStatusInvalidData     -4
CONSTANT: NSImageRepLoadStatusUnexpectedEOF   -5
CONSTANT: NSImageRepLoadStatusCompleted       -6

CONSTANT: NSColorRenderingIntentDefault                 0
CONSTANT: NSColorRenderingIntentAbsoluteColorimetric    1
CONSTANT: NSColorRenderingIntentRelativeColorimetric    2
CONSTANT: NSColorRenderingIntentPerceptual              3
CONSTANT: NSColorRenderingIntentSaturation              4

ERROR: ns-image-unknown-type ;
ERROR: ns-image-invalid-data ;
ERROR: ns-image-unexpected-eof ;
ERROR: ns-image-planar-images-not-supported ;

<PRIVATE

: check-return ( n -- )
    {
        { $ NSImageRepLoadStatusUnknownType   [ ns-image-unknown-type   ] }
        { $ NSImageRepLoadStatusInvalidData   [ ns-image-invalid-data   ] }
        { $ NSImageRepLoadStatusUnexpectedEOF [ ns-image-unexpected-eof ] }
        [ drop ]
    } case ;

PRIVATE>

: load-image-rep ( -- image-rep )
    NSBitmapImageRep contents <CFData> -> autorelease -> imageRepWithData:
    NSColorSpace -> genericRGBColorSpace
    NSColorRenderingIntentDefault
    -> bitmapImageRepByConvertingToColorSpace:renderingIntent: ;

: image-rep>image ( image-rep -- image )
    image new swap {
        [ -> size CGSize>dim >>dim ]
        [ -> bitmapData ]
        [ -> bytesPerPlane memory>byte-array >>bitmap ]
    } cleave
        RGBA >>component-order
        ubyte-components >>component-type
        f >>upside-down? ;

M: ns-image stream>image
    drop [ load-image-rep ] with-input-stream image-rep>image ;
