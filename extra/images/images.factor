! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: constructors kernel splitting unicode.case combinators
accessors images.bitmap images.tiff images.backend io.backend
io.pathnames ;
IN: images

: <image> ( path -- image )
    dup file-extension >lower {
        { "bmp" [ bitmap-image load-image ] }
        { "tiff" [ tiff-image load-image ] }
    } case ;
