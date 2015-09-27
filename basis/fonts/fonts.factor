! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel colors colors.constants accessors combinators math ;
IN: fonts

TUPLE: font
name
size
bold?
italic?
{ foreground initial: COLOR: black }
{ background initial: COLOR: white } ;

: <font> ( -- font )
    font new ; inline

: font-with-foreground ( font color -- font' )
    [ clone ] dip >>foreground ; inline

: font-with-background ( font color -- font' )
    [ clone ] dip >>background ; inline

: font-with-size ( font size -- font' )
    [ clone ] dip >>size ; inline

: reverse-video-font ( font -- font )
    clone dup
    [ foreground>> ] [ background>> ] bi
    [ >>background ] [ >>foreground ] bi* ;

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
        "serif" >>name
        12 >>size ;

: sans-serif-font ( -- font )
    <font>
        "sans-serif" >>name
        12 >>size ;

: monospace-font ( -- font )
    <font>
        "monospace" >>name
        12 >>size ;

: strip-font-colors ( font -- font' )
    clone f >>background f >>foreground ;

TUPLE: metrics width ascent descent height leading cap-height x-height ;

: compute-height ( metrics -- metrics )
    dup [ ascent>> ] [ descent>> ] bi + >>height ; inline

TUPLE: selection string start end color ;

C: <selection> selection
