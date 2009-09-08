! Copyright (C) 2009 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences math arrays locals fry accessors
lists splitting make combinators.short-circuit namespaces
grouping splitting.monotonic ;
IN: wrap

! black is the text length, white is the whitespace length
TUPLE: element contents black white ;
C: <element> element

: element-length ( element -- n )
    [ black>> ] [ white>> ] bi + ;

TUPLE: paragraph lines head-width tail-cost ;
C: <paragraph> paragraph

SYMBOL: line-max
SYMBOL: line-ideal

: deviation ( length -- n )
    line-ideal get - sq ;

: top-fits? ( paragraph -- ? )
    [ head-width>> ]
    [ lines>> 1list? line-ideal line-max ? get ] bi <= ;

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
        [ head-width>> deviation ]
        [ tail-cost>> ] bi +
    ] if ;

: min-cost ( paragraphs -- paragraph )
    [ paragraph-cost ] min-by ;

: new-line ( paragraph element -- paragraph )
    [ [ lines>> ] [ 1list ] bi* swons ]
    [ nip black>> ]
    [ drop paragraph-cost ] 2tri
    <paragraph> ;

: glue ( paragraph element -- paragraph )
    [ [ lines>> unswons ] dip swons swons ]
    [ [ head-width>> ] [ element-length ] bi* + ]
    [ drop tail-cost>> ] 2tri
    <paragraph> ;

: wrap-step ( paragraphs element -- paragraphs )
    [ '[ _ glue ] map ]
    [ [ min-cost ] dip new-line ]
    2bi prefix
    [ fits? ] filter ;

: 1paragraph ( element -- paragraph )
    [ 1list 1list ]
    [ black>> ] bi
    0 <paragraph> ;

: post-process ( paragraph -- array )
    lines>> [ [ contents>> ] lmap>array ] lmap>array ;

: initialize ( elements -- elements paragraph )
    <reversed> unclip-slice 1paragraph 1array ;

: wrap ( elements line-max line-ideal -- paragraph )
    [
        line-ideal set
        line-max set
        [ { } ] [
            initialize
            [ wrap-step ] reduce
            min-cost
            post-process
        ] if-empty
    ] with-scope ;
