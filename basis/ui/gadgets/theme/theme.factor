! (c)2009, 2010 Slava Pestov, Joe Groff bsd license
USING: io.pathnames sequences ui.images ;
IN: ui.gadgets.theme

: theme-image ( name -- image-name )
    "vocab:ui/gadgets/theme/" prepend-path ".tiff" append <image-name> ;
