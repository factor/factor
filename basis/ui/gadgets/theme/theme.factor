! Copyright (C) 2009, 2010 Slava Pestov, Joe Groff.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors io.pathnames sequences ui.images ui.theme ;
IN: ui.gadgets.theme

SLOT: font ! Temporarily necessary to fix Windows bootstrap.

: theme-image ( name -- image-name )
    "vocab:ui/gadgets/theme/" prepend-path ".tiff" append <image-name> ;

: theme-font-colors ( gadget -- gadget )
    [ content-background >>background text-color >>foreground ] change-font ;
