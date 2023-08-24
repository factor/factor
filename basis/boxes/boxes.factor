! Copyright (C) 2008, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel accessors ;
IN: boxes

TUPLE: box value occupied ;

: <box> ( -- box ) box new ;

ERROR: box-full box ;

: >box ( value box -- )
    dup occupied>>
    [ box-full ] [ t >>occupied value<< ] if ; inline

ERROR: box-empty box ;

: check-box ( box -- box )
    dup occupied>> [ box-empty ] unless ; inline

<PRIVATE

: box-unsafe> ( box -- value )
    [ f ] change-value f >>occupied drop ; inline

PRIVATE>

: box> ( box -- value )
    check-box box-unsafe> ; inline

: ?box ( box -- value/f ? )
    dup occupied>> [ box-unsafe> t ] [ drop f f ] if ; inline

: if-box? ( box quot: ( value -- ) -- )
    [ ?box ] dip [ drop ] if ; inline
