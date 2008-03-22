! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types cairo.ffi continuations destructors
kernel libc locals math combinators.cleave shuffle
accessors ;
IN: cairo.lib

TUPLE: cairo-t alien ;
C: <cairo-t> cairo-t
M: cairo-t dispose ( alien -- ) alien>> cairo_destroy ;
: cairo-t-destroy-always ( alien -- ) <cairo-t> add-always-destructor ;
: cairo-t-destroy-later ( alien -- ) <cairo-t> add-error-destructor ;
    
TUPLE: cairo-surface-t alien ;
C: <cairo-surface-t> cairo-surface-t
M: cairo-surface-t dispose ( alien -- ) alien>> cairo_surface_destroy ;

: cairo-surface-t-destroy-always ( alien -- )
    <cairo-surface-t> add-always-destructor ;

: cairo-surface-t-destroy-later ( alien -- )
    <cairo-surface-t> add-error-destructor ;

: cairo-surface>array ( surface -- cairo-t byte-array )
    [
        dup
        [ drop CAIRO_FORMAT_ARGB32 ]
        [ cairo_image_surface_get_width ]
        [ cairo_image_surface_get_height ] tri
        over 4 *
        2dup * [
            malloc dup free-always [
                5 -nrot cairo_image_surface_create_for_data
                dup cairo-surface-t-destroy-always
                cairo_create dup cairo-t-destroy-later
                [ swap 0 0 cairo_set_source_surface ] keep
                dup cairo_paint
            ] keep
        ] keep memory>byte-array
    ] with-destructors ;
