! Copyright (C) 2009 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: combinators kernel sequences math arrays locals fry accessors
lists splitting make combinators.short-circuit namespaces
grouping splitting.monotonic ;
IN: wrap

! black is the text length, white is the whitespace length
TUPLE: element contents black white ;
C: <element> element

: element-length ( element -- n )
    [ black>> ] [ white>> ] bi + ;

TUPLE: paragraph line-max line-ideal lines head-width tail-cost ;
C: <paragraph> paragraph

: top-fits? ( paragraph -- ? )
    [ head-width>> ]
    [ dup lines>> 1list? [ line-ideal>> ] [ line-max>> ] if ] bi <= ;

: fits? ( paragraph -- ? )
    ! Make this not count spaces at end
    { [ lines>> car 1list? ] [ top-fits? ] } 1|| ;

:: min-by ( seq quot -- elt )
    f 1/0. seq [| key value new |
        new quot call :> newvalue
        newvalue value < [ new newvalue ] [ key value ] if
    ] each drop ; inline

: paragraph-cost ( paragraph -- cost )
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

: glue ( paragraph element -- paragraph )
    {
        [ drop [ line-max>> ] [ line-ideal>> ] bi ]
        [ [ lines>> unswons ] dip swons swons ]
        [ [ head-width>> ] [ element-length ] bi* + ]
        [ drop tail-cost>> ]
    } 2cleave <paragraph> ;

: wrap-step ( paragraphs element -- paragraphs )
    [ '[ _ glue ] map ]
    [ [ min-cost ] dip new-line ]
    2bi prefix
    [ fits? ] filter ;

: 1paragraph ( line-max line-ideal element -- paragraph )
    [ 1list 1list ] [ black>> ] bi 0 <paragraph> ;

: post-process ( paragraph -- array )
    lines>> [ [ contents>> ] lmap>array ] lmap>array ;

: initialize ( line-max line-ideal elements -- elements paragraph )
    <reversed> unclip-slice [ -rot ] dip 1paragraph 1array ;

: wrap ( elements line-max line-ideal -- paragraph )
    rot [ 2drop { } ] [
        initialize
        [ wrap-step ] reduce
        min-cost
        post-process
    ] if-empty ;
