! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors arrays assocs colors.hex combinators formatting
http.client images.http images.loader images.loader.private
images.viewer kernel math math.order present sequences splitting
urls ;

IN: google.charts

TUPLE: chart type width height title data data-scale labels
background foreground margin bar-width ;

: <chart> ( type -- chart )
    chart new
        swap >>type
        320 >>width
        240 >>height ;

<PRIVATE

: x,y ( seq -- str ) [ present ] map "," join ;

: x|y ( seq -- str ) [ present ] map "|" join ;

: chd ( chart seq -- chart )
    [ x,y >>data ] [
        [ infimum 0 min ] [ supremum 0 max ] bi 2array
        x,y >>data-scale
    ] bi ;

: chl ( chart seq -- chart ) x|y >>labels ;

: chd/chl ( chart assoc -- chart )
    [ values chd ] [ keys chl ] bi ;

PRIVATE>

: <pie> ( assoc -- chart )
    [ "p" <chart> ] dip chd/chl ;

: <pie-3d> ( assoc -- chart )
    [ "p3" <chart> ] dip chd/chl ;

: <bar> ( assoc -- chart )
    [ "bvs" <chart> ] dip chd/chl ;

: <line> ( seq -- chart )
    [ "lc" <chart> ] dip chd ;

: <line-xy> ( seq -- chart )
    [ "lxy" <chart> ] dip [ keys ] [ values ] bi
    [ x,y ] bi@ "|" glue >>data ;

: <scatter> ( seq -- chart )
    [ "s" <chart> ] dip [ keys ] [ values ] bi
    [ x,y ] bi@ "|" glue >>data ;

: <sparkline> ( seq -- chart )
    [ "ls" <chart> ] dip chd ;

: <radar> ( seq -- chart )
    [ "rs" <chart> ] dip chd ;

: <qr-code> ( str -- chart )
    [ "qr" <chart> ] dip 1array chl ;

: <formula> ( str -- chart )
    [ "tx" <chart> ] dip 1array chl f >>width f >>height ;

<PRIVATE

: chart>url ( chart -- url )
    [ URL" http://chart.googleapis.com/chart" ] dip {
        [ type>> "cht" set-query-param ]
        [
            [ width>> ] [ height>> ] bi 2dup and [
                "%sx%s" sprintf "chs" set-query-param
            ] [ 2drop ] if
        ]
        [ title>> "chtt" set-query-param ]
        [ data>> "t:" prepend "chd" set-query-param ]
        [ data-scale>> [ "chds" set-query-param ] when* ]
        [ labels>> "chl" set-query-param ]
        [
            background>> [
                rgba>hex "bg,s," prepend "chf" set-query-param
            ] when*
        ]
        [
            foreground>> [
                rgba>hex "chco" set-query-param
            ] when*
        ]
        [ margin>> [ x,y "chma" set-query-param ] when* ]
        [ bar-width>> [ "chbh" set-query-param ] when* ]
    } cleave ;

PRIVATE>

: chart. ( chart -- )
    chart>url present dup length 2000 < [ http-image. ] [
        "?" split1 swap http-post*
        "png" (image-class) load-image* image.
    ] if ;
