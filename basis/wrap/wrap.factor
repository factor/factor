! Copyright (C) 2009 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators combinators.short-circuit
fry kernel lists locals math sequences typed ;
IN: wrap

! black is the text length, white is the whitespace length
TUPLE: element contents black white ;
C: <element> element

<PRIVATE

TYPED: element-length ( element: element -- n )
    [ black>> ] [ white>> ] bi + ;

TUPLE: paragraph line-max line-ideal lines head-width tail-cost ;
C: <paragraph> paragraph

TYPED: top-fits? ( paragraph: paragraph -- ? )
    [ head-width>> ]
    [ dup lines>> 1list? [ line-ideal>> ] [ line-max>> ] if ] bi <= ;

TYPED: fits? ( paragraph: paragraph -- ? )
    ! Make this not count spaces at end
    { [ lines>> car 1list? ] [ top-fits? ] } 1|| ;

:: min-by ( seq quot -- elt )
    f 1/0. seq [| key value newkey |
        newkey quot call :> newvalue
        newvalue value < [ newkey newvalue ] [ key value ] if
    ] each drop ; inline

TYPED: paragraph-cost ( paragraph: paragraph -- cost )
    dup lines>> 1list? [ drop 0 ] [
        [ [ head-width>> ] [ line-ideal>> ] bi - sq ]
        [ tail-cost>> ] bi +
    ] if ;

: min-cost ( paragraphs -- paragraph )
    [ paragraph-cost ] min-by ;

: new-line ( paragraph element -- paragraph )
    {
        [ drop [ line-max>> ] [ line-ideal>> ] bi ]
        [ [ lines>> ] [ 1list ] bi* swons ]
        [ nip black>> ]
        [ drop paragraph-cost ]
    } 2cleave <paragraph> ;

TYPED: add-element ( paragraph: paragraph element: element -- )
    [ element-length [ + ] curry change-head-width ]
    [ [ [ unswons ] dip swons swons ] curry change-lines ]
    bi drop ;

: wrap-step ( paragraphs element -- paragraphs )
    [ [ min-cost ] dip new-line ]
    [ dupd '[ _ add-element ] each ]
    2bi swap prefix
    [ fits? ] filter ;

: 1paragraph ( line-max line-ideal element -- paragraph )
    [ 1list 1list ] [ black>> ] bi 0 <paragraph> ;

: post-process ( paragraph -- array )
    lines>> [ [ contents>> ] lmap>array ] lmap>array ;

: initialize ( line-max line-ideal elements -- elements paragraph )
    reverse unclip [ -rot ] dip 1paragraph 1array ;

PRIVATE>

: wrap ( elements line-max line-ideal -- array )
    rot [ 2drop { } ] [
        initialize
        [ wrap-step ] reduce
        min-cost
        post-process
    ] if-empty ;
