! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors ;
IN: boxes

TUPLE: box value full? ;

: <box> ( -- box ) box new ;

ERROR: box-full box ;

: >box ( value box -- )
    dup full?>>
    [ box-full ] [ t >>full? (>>value) ] if ;

ERROR: box-empty box ;

: box> ( box -- value )
    dup full?>>
    [ [ f ] change-value f >>full? drop ] [ box-empty ] if ;

: ?box ( box -- value/f ? )
    dup full?>> [ box> t ] [ drop f f ] if ;

: if-box? ( box quot -- )
    >r ?box r> [ drop ] if ; inline
