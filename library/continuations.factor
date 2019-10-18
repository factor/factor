! Copyright (C) 2003, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: kernel USING: errors lists namespaces sequences ;

TUPLE: interp data call name catch ;

: interp ( -- interp )
    datastack callstack >pop> >pop>
    namestack catchstack <interp> ;

: >interp< ( interp -- data call name catch )
    [ interp-data ] keep
    [ interp-call ] keep
    [ interp-name ] keep
    interp-catch ;

: set-interp ( interp -- )
    >interp< set-catchstack set-namestack
    >r set-datastack r> set-callstack ;

: continuation ( interp -- )
    interp dup interp-call >pop> >pop> drop
    dup interp-data >pop> drop ;

: callcc0 ( quot ++ | quot: cont -- | cont: ++ )
    continuation
    [ set-interp ] cons swap call ;

: callcc1 ( quot ++ obj | quot: cont -- | cont: obj ++ obj )
    continuation
    [ [ interp-data push ] keep set-interp ] cons swap call ;
