! Copyright (C) 2005, 2009 Daniel Ehrenberg, Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors circular combinators.short-circuit io kernel
math math.order sequences sequences.parser sequences.private
sorting unicode ;
IN: sequences.parser

TUPLE: sequence-parser sequence n ;

: <sequence-parser> ( sequence -- sequence-parser )
    sequence-parser new
        swap >>sequence
        0 >>n ;

:: with-sequence-parser ( sequence-parser quot -- seq/f )
    sequence-parser n>> :> n
    sequence-parser quot call [
        n sequence-parser n<< f
    ] unless* ; inline

: offset  ( sequence-parser offset -- char/f )
    swap
    [ n>> + ] [ sequence>> ?nth ] bi ; inline

: current ( sequence-parser -- char/f ) 0 offset ; inline

: previous ( sequence-parser -- char/f ) -1 offset ; inline

: peek-next ( sequence-parser -- char/f ) 1 offset ; inline

: advance ( sequence-parser -- sequence-parser )
    [ 1 + ] change-n ; inline

: next ( sequence-parser -- char/f )
    [ current ] [ advance drop ] bi ; inline

:: skip-until ( ... sequence-parser quot: ( ... obj -- ... ? ) -- ... )
    sequence-parser current [
        sequence-parser quot call
        [ sequence-parser advance quot skip-until ] unless
    ] when ; inline recursive

: sequence-parse-end? ( sequence-parser -- ? ) current not ;

: take-until ( ... sequence-parser quot: ( ... obj -- ... ? ) -- ... sequence/f )
    over sequence-parse-end? [
        2drop f
    ] [
        [ drop n>> ]
        [ skip-until ]
        [ drop [ n>> ] [ sequence>> ] bi ] 2tri subseq f like
    ] if ; inline

: take-while ( ... sequence-parser quot: ( ... obj -- ... ? ) -- ... sequence/f )
    [ not ] compose take-until ; inline

: <safe-slice> ( from to seq -- slice/f )
    3dup {
        [ 2drop 0 < ]
        [ nipd length > ]
        [ drop > ]
    } 3|| [ 3drop f ] [ <slice-unsafe> ] if ; inline

:: take-sequence ( sequence-parser sequence -- obj/f )
    sequence-parser [ n>> dup sequence length + ] [ sequence>> ] bi
    <safe-slice> sequence sequence= [
        sequence
        sequence-parser [ sequence length + ] change-n drop
    ] [
        f
    ] if ;

: take-sequence* ( sequence-parser sequence -- )
    take-sequence drop ;

:: take-until-sequence ( sequence-parser sequence -- sequence'/f )
    sequence-parser n>> :> saved
    sequence length <growing-circular> :> growing
    sequence-parser
    [
        current growing growing-circular-push
        sequence growing sequence=
    ] take-until :> found
    growing sequence sequence= [
        found dup length
        growing length 1 - - head
        sequence-parser [ growing length - 1 + ] change-n drop
        ! sequence-parser advance drop
    ] [
        saved sequence-parser n<<
        f
    ] if ;

:: take-until-sequence* ( sequence-parser sequence -- sequence'/f )
    sequence-parser sequence take-until-sequence :> out
    out [
        sequence-parser [ sequence length + ] change-n drop
    ] when out ;

: skip-whitespace ( sequence-parser -- sequence-parser )
    [ [ current blank? not ] take-until drop ] keep ;

: skip-whitespace-eol ( sequence-parser -- sequence-parser )
    [ [ current " \t\r" member? not ] take-until drop ] keep ;

: take-rest-slice ( sequence-parser -- sequence/f )
    [ sequence>> ] [ n>> ] bi
    2dup [ length ] dip < [ 2drop f ] [ tail-slice ] if ; inline

: take-rest ( sequence-parser -- sequence )
    [ take-rest-slice ] [ sequence>> like ] bi f like ;

: take-until-object ( sequence-parser obj -- sequence )
    '[ current _ = ] take-until ;

: parse-sequence ( sequence quot -- )
    [ <sequence-parser> ] dip call ; inline

: take-integer ( sequence-parser -- n/f )
    [ current digit? ] take-while ;

:: take-n ( sequence-parser n -- seq/f )
    n sequence-parser [ n>> + ] [ sequence>> length ] bi > [
        sequence-parser take-rest
    ] [
        sequence-parser n>> dup n + sequence-parser sequence>> subseq
        sequence-parser [ n + ] change-n drop
    ] if ;

: sort-tokens ( seq -- seq' ) [ length ] inv-sort-by ;

: take-first-matching ( sequence-parser seq -- seq )
    swap
    '[ _ [ swap take-sequence ] with-sequence-parser ] find nip ;

: take-longest ( sequence-parser seq -- seq )
    sort-tokens take-first-matching ;

: write-full ( sequence-parser -- ) sequence>> write ;
: write-rest ( sequence-parser -- ) take-rest write ;
