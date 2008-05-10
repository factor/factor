! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: cairo kernel accessors sequences
namespaces fry continuations ;
IN: cairo.lib

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
: cr ( -- cairo ) cairo get ;

: (with-cairo) ( cairo-t quot -- )
    >r alien>> cairo r> [ cr cairo_status check-cairo ]
    compose with-variable ; inline
    
: with-cairo ( cairo quot -- )
    >r <cairo-t> r> [ (with-cairo) ] curry with-disposal ; inline

: (with-surface) ( cairo-surface-t quot -- )
    >r alien>> r> [ cairo_surface_status check-cairo ] bi ; inline

: with-surface ( cairo_surface quot -- )
    >r <cairo-surface-t> r> [ (with-surface) ] curry with-disposal ; inline

: with-cairo-from-surface ( cairo_surface quot -- )
    '[ cairo_create , with-cairo ] with-surface ; inline
