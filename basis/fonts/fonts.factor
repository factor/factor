! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors colors combinators kernel math namespaces ;
IN: fonts

CONSTANT: default-serif-font-name "serif"
CONSTANT: default-sans-serif-font-name "sans-serif"
CONSTANT: default-monospace-font-name "monospace"

CONSTANT: default-font-size 12

SYMBOL: default-font-foreground-color
COLOR: black default-font-foreground-color set-global

SYMBOL: default-font-background-color
COLOR: white default-font-background-color set-global

TUPLE: font name size bold? italic? foreground background ;

: <font> ( -- font )
    font new
        default-font-foreground-color get >>foreground
        default-font-background-color get >>background ; inline

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
    <font>
        default-serif-font-name >>name
        default-font-size >>size ;

: sans-serif-font ( -- font )
    <font>
        default-sans-serif-font-name >>name
        default-font-size >>size ;

: monospace-font ( -- font )
    <font>
        default-monospace-font-name >>name
        default-font-size >>size ;

: strip-font-colors ( font -- font' )
    clone f >>background f >>foreground ;

TUPLE: metrics width ascent descent height leading cap-height x-height ;

: compute-height ( metrics -- metrics )
    dup [ ascent>> ] [ descent>> ] bi + >>height ; inline

TUPLE: selection string start end color ;

C: <selection> selection
