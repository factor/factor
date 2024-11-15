! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors colors combinators kernel math namespaces ;
IN: fonts

: default-serif-font-name ( -- name )
    \ default-serif-font-name get "serif" or ;

: default-sans-serif-font-name ( -- name )
    \ default-sans-serif-font-name get "sans-serif" or ;

: default-monospace-font-name ( -- name )
    \ default-monospace-font-name get "monospace" or ;

: default-font-size ( -- size )
    \ default-font-size get 12 or ;

: default-font-foreground ( -- color )
    \ default-font-foreground get COLOR: black or ;

: default-font-background ( -- color )
    \ default-font-background get COLOR: white or ;

TUPLE: font name size bold? italic? foreground background ;

: <font> ( name -- font )
    font new
        swap >>name
        default-font-size >>size
        default-font-foreground >>foreground
        default-font-background >>background ; inline

: font-with-foreground ( font color -- font' )
    [ clone ] dip >>foreground ; inline

: font-with-background ( font color -- font' )
    [ clone ] dip >>background ; inline

: font-with-size ( font size -- font' )
    [ clone ] dip >>size ; inline

: reverse-video-font ( font -- font )
    clone dup
    [ foreground>> >>background ]
    [ background>> >>foreground ] bi ;

: derive-font ( base font -- font' )
    [
        [ clone ] dip over {
            [ [ name>> ] either? >>name ]
            [ [ size>> ] either? >>size ]
            [ [ bold?>> ] either? >>bold? ]
            [ [ italic?>> ] either? >>italic? ]
            [ [ foreground>> ] either? >>foreground ]
            [ [ background>> ] either? >>background ]
        } 2cleave
    ] when* ;

: serif-font ( -- font )
    default-serif-font-name <font> ;

: sans-serif-font ( -- font )
    default-sans-serif-font-name <font> ;

: monospace-font ( -- font )
    default-monospace-font-name <font> ;

: strip-font-colors ( font -- font' )
    clone f >>background f >>foreground ;

TUPLE: metrics width ascent descent height leading cap-height x-height ;

: compute-height ( metrics -- metrics )
    dup [ ascent>> ] [ descent>> ] bi + >>height ; inline

TUPLE: selection string start end color ;

C: <selection> selection
