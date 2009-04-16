! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays kernel math math.parser strings sequences
words ;
IN: db2.utils

: ?when ( object quot -- object' ) dupd when ; inline
: ?1array ( obj -- array ) dup string? [ 1array ] when ; inline
: ??1array ( obj -- array/f ) [ ?1array ] ?when ; inline

: ?first ( sequence -- object/f ) 0 ?nth ;
: ?second ( sequence -- object/f ) 1 ?nth ;

: ?first2 ( sequence -- object1/f object2/f )
    [ ?first ] [ ?second ] bi ;

: assoc-with ( object sequence quot -- obj curry )
    swapd [ [ -rot ] dip  call ] 2curry ; inline

: ?number>string ( n/string -- string )
    dup number? [ number>string ] when ;

ERROR: no-accessor name ;

: lookup-accessor ( string -- accessor )
    dup ">>" append "accessors" lookup
    [ nip ] [ no-accessor ] if* ;

ERROR: string-expected object ;

: ensure-string ( object -- string )
    dup string? [ string-expected ] unless ;
