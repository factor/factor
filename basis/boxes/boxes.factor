! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors ;
IN: boxes

TUPLE: box value occupied ;

: <box> ( -- box ) box new ;

ERROR: box-full box ;

: >box ( value box -- )
    dup occupied>>
    [ box-full ] [ t >>occupied (>>value) ] if ;

ERROR: box-empty box ;

: box> ( box -- value )
    dup occupied>>
    [ [ f ] change-value f >>occupied drop ] [ box-empty ] if ;

: ?box ( box -- value/f ? )
    dup occupied>> [ box> t ] [ drop f f ] if ;

: if-box? ( box quot -- )
    [ ?box ] dip [ drop ] if ; inline
