! Copyright (C) 2009, 2010 Slava Pestov, Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: io.pathnames sequences ui.images ;
IN: ui.theme.images

: theme-image ( name -- image-name )
    "vocab:ui/theme/images/" prepend-path ".tiff" append <image-name> ;
