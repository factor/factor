! Copyright (C) 2008 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel math.parser namespaces sequences
sequences.generalizations ;
IN: nmake

SYMBOL: building-seq
: get-building-seq ( n -- seq )
    building-seq get nth ;

: n, ( obj n -- ) get-building-seq push ;
: n% ( seq n -- ) get-building-seq push-all ;
: n# ( num n -- ) [ number>string ] dip n% ;

: 0, ( obj -- ) 0 n, ;
: 0% ( seq -- ) 0 n% ;
: 0# ( num -- ) 0 n# ;
: 1, ( obj -- ) 1 n, ;
: 1% ( seq -- ) 1 n% ;
: 1# ( num -- ) 1 n# ;
: 2, ( obj -- ) 2 n, ;
: 2% ( seq -- ) 2 n% ;
: 2# ( num -- ) 2 n# ;
: 3, ( obj -- ) 3 n, ;
: 3% ( seq -- ) 3 n% ;
: 3# ( num -- ) 3 n# ;
: 4, ( obj -- ) 4 n, ;
: 4% ( seq -- ) 4 n% ;
: 4# ( num -- ) 4 n# ;

MACRO: finish-nmake ( exemplars -- quot )
    length [ firstn ] curry ;

:: nmake ( quot exemplars -- )
    exemplars [ 0 swap new-resizable ] map
    building-seq [
        quot call
        building-seq get
        exemplars [ [ like ] 2map ] [ finish-nmake ] bi
    ] with-variable ; inline
