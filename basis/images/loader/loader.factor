! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: constructors kernel splitting unicode.case combinators
accessors images.bitmap images.tiff images io.pathnames
images.jpeg images.png ;
IN: images.loader

ERROR: unknown-image-extension extension ;

: image-class ( path -- class )
    file-extension >lower {
        { "bmp" [ bitmap-image ] }
        { "tif" [ tiff-image ] }
        { "tiff" [ tiff-image ] }
        { "jpg" [ jpeg-image ] }
        { "jpeg" [ jpeg-image ] }
        { "png" [ png-image ] }
        [ unknown-image-extension ]
    } case ;

: load-image ( path -- image )
    dup image-class new load-image* ;
