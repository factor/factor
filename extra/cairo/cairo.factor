! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: cairo.ffi kernel accessors sequences
namespaces fry continuations destructors ;
IN: cairo

TUPLE: cairo-t alien ;
C: <cairo-t> cairo-t
M: cairo-t dispose ( alien -- ) alien>> cairo_destroy ;

TUPLE: cairo-surface-t alien ;
C: <cairo-surface-t> cairo-surface-t
M: cairo-surface-t dispose ( alien -- ) alien>> cairo_surface_destroy ;

: check-cairo ( cairo_status_t -- )
    dup CAIRO_STATUS_SUCCESS = [ drop ]
    [ cairo_status_to_string "Cairo error: " prepend throw ] if ;

SYMBOL: cairo
: cr ( -- cairo ) cairo get ; inline

: (with-cairo) ( cairo-t quot -- )
    [ alien>> cairo ] dip
    '[ @ cr cairo_status check-cairo ]
    with-variable ; inline
    
: with-cairo ( cairo quot -- )
    [ <cairo-t> ] dip '[ _ (with-cairo) ] with-disposal ; inline

: (with-surface) ( cairo-surface-t quot -- )
    [ alien>> ] dip [ cairo_surface_status check-cairo ] bi ; inline

: with-surface ( cairo_surface quot -- )
    [ <cairo-surface-t> ] dip '[ _ (with-surface) ] with-disposal ; inline

: with-cairo-from-surface ( cairo_surface quot -- )
    '[ cairo_create _ with-cairo ] with-surface ; inline
