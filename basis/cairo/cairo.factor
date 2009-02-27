! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: cairo.ffi alien.c-types kernel accessors sequences
namespaces fry continuations destructors ;
IN: cairo

ERROR: cairo-error message ;

: (check-cairo) ( cairo_status_t -- )
    dup CAIRO_STATUS_SUCCESS =
    [ drop ] [ cairo_status_to_string cairo-error ] if ;

: check-cairo ( cairo -- ) cairo_status (check-cairo) ;

: with-cairo ( cairo quot -- )
    '[
        _ &cairo_destroy
        _ [ check-cairo ] bi
    ] with-destructors ; inline

: check-surface ( surface -- ) cairo_surface_status check-cairo ;

: with-surface ( cairo_surface quot -- )
    '[
        _ &cairo_surface_destroy
        _ [ check-surface ] bi
    ] with-destructors ; inline

: with-cairo-from-surface ( cairo_surface quot -- )
    '[ cairo_create _ with-cairo ] with-surface ; inline

: width>stride ( width -- stride ) "uint" heap-size * ; inline

: <image-surface> ( data dim -- surface )
    first2 over width>stride CAIRO_FORMAT_ARGB32
    cairo_image_surface_create_for_data
    dup check-surface ;

: make-bitmap-image ( dim quot -- image )
    '[ <image-surface> &cairo_surface_destroy @ ] make-memory-bitmap ; inline
