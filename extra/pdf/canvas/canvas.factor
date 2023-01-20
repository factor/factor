! Copyright (C) 2011-2012 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors assocs colors combinators fonts io io.styles
kernel math math.order namespaces pdf.text pdf.wrap sequences
ui.text ;

IN: pdf.canvas

SYMBOL: +line-height+

TUPLE: margin left right top bottom ;

C: <margin> margin

TUPLE: canvas x y width height margin col-width font stream
foreground background page-color inset line-height metrics ;

: <canvas> ( -- canvas )
    canvas new
        0 >>x
        0 >>y
        612 >>width
        792 >>height
        54 54 54 54 <margin> >>margin
        612 >>col-width
        sans-serif-font 12 >>size >>font
        SBUF" " >>stream
        0 >>line-height
        { 0 0 } >>inset
    dup font>> font-metrics >>metrics ;

: set-style ( canvas style -- canvas )
    {
        [
            font-name of "sans-serif" or {
                { "sans-serif" [ "Helvetica" ] }
                { "serif"      [ "Times"     ] }
                { "monospace"  [ "Courier"   ] }
                [ " is unsupported" append throw ]
            } case [ dup font>> ] dip >>name drop
        ]
        [
            font-size of 12 or
            [ dup font>> ] dip >>size drop
        ]
        [
            font-style of [ dup font>> ] dip {
                { bold        [ t f ] }
                { italic      [ f t ] }
                { bold-italic [ t t ] }
                [ drop f f ]
            } case [ >>bold? ] [ >>italic? ] bi* drop
        ]
        [ foreground of COLOR: black or >>foreground ]
        [ background of f or >>background ]
        [ page-color of f or >>page-color ]
        [ inset of { 0 0 } or >>inset ]
    } cleave
    dup font>> font-metrics
    [ >>metrics ] [ height>> '[ _ max ] change-line-height ] bi ;

! introduce positioning of elements versus canvas?

: margin-x ( canvas -- n )
    margin>> [ left>> ] [ right>> ] bi + ;

: margin-y ( canvas -- n )
    margin>> [ top>> ] [ bottom>> ] bi + ;

: (width) ( canvas -- n )
    [ width>> ] [ margin>> [ left>> ] [ right>> ] bi + ] bi - ;

: width ( canvas -- n )
    [ (width) ] [ col-width>> ] bi min ;

: height ( canvas -- n )
    [ height>> ] [ margin>> [ top>> ] [ bottom>> ] bi + ] bi - ;

: x ( canvas -- n )
    [ margin>> left>> ] [ x>> ] bi + ;

: y ( canvas -- n )
    [ height>> ] [ margin>> top>> ] [ y>> ] tri + - ;

: inc-x ( canvas n -- )
    '[ _ + ] change-x drop ;

: inc-y ( canvas n -- )
    '[ _ + ] change-y drop ;

<PRIVATE

: (line-height) ( canvas -- n )
    line-height>> +line-height+ get [ * >integer ] when* ;

PRIVATE>

: line-height ( canvas -- n )
    [ (line-height) ] [ inset>> first 2 * ] bi + ;

: line-break ( canvas -- )
    [ (line-height) ] keep [ + ] change-y 0 >>x
    dup metrics>> height>> >>line-height drop ;

: ?line-break ( canvas -- )
    dup x>> 0 > [ line-break ] [ drop ] if ;

: ?break ( canvas -- )
    dup x>> 0 > [ ?line-break ] [
        [ 7 + ] change-y 0 >>x drop
    ] if ;

: inc-lines ( canvas n -- )
    [ 0 >>x ] dip [ dup line-break ] times drop ;

: avail-width ( canvas -- n )
    [ width ] [ x>> ] bi [-] ;

: avail-height ( canvas -- n )
    [ height ] [ y>> ] bi [-] ;

: avail-lines ( canvas -- n )
    [ avail-height ] [ line-height>> ] bi /i ; ! FIXME: 1 +

: text-fits? ( canvas string -- ? )
    [ dup font>> ] [ word-split1 drop ] bi*
    text-width swap avail-width <= ;

: draw-page-color ( canvas -- ) ! FIXME:
    dup page-color>> [
        "0.0 G" print
        foreground-color
        [ 0 0 ] dip [ width>> ] [ height>> ] bi
        rectangle fill
    ] [ drop ] if* ;

: draw-background ( canvas line -- )
    over background>> [
        "0.0 G" print
        foreground-color
        [ drop [ x ] [ y ] bi ]
        [ [ font>> ] [ text-dim first2 neg ] bi* ] 2bi
        rectangle fill
    ] [ 2drop ] if* ;

: draw-text1 ( canvas line -- canvas )
    [ draw-background ] [
        text-start
        over font>> text-size
        over foreground>> [ foreground-color ] when*
        over [ x ] [ y ] [ metrics>> ascent>> - ] tri text-location
        over dup font>> pick text-width inc-x
        text-write
        text-end
    ] 2bi ;

: draw-text ( canvas lines -- )
    [ drop ] [
        unclip-last
        [ [ draw-text1 dup line-break ] each ]
        [ [ draw-text1 ] when* ] bi* drop
    ] if-empty ;

: draw-line ( canvas width -- )
    swap [ x ] [ y ] [ line-height>> 2 / - ] tri
    [ line-move ] [ [ + ] [ line-line ] bi* ] 2bi
    stroke ;
