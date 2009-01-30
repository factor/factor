! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel colors accessors combinators ;
IN: fonts

TUPLE: font name size bold? italic? foreground background ;

: <font> ( -- font )
    font new
        black >>foreground
        white >>background ; inline

: font-with-foreground ( font color -- font' )
    [ clone ] dip >>foreground ; inline

: font-with-background ( font color -- font' )
    [ clone ] dip >>background ; inline

: reverse-video-font ( font -- font )
    clone dup
    [ foreground>> ] [ background>> ] bi
    [ >>background ] [ >>foreground ] bi* ;

: derive-font ( base font -- font' )
    [ clone ] dip over {
        [ [ name>> ] either? >>name ]
        [ [ size>> ] either? >>size ]
        [ [ bold?>> ] either? >>bold? ]
        [ [ italic?>> ] either? >>italic? ]
        [ [ foreground>> ] either? >>foreground ]
        [ [ background>> ] either? >>background ]
    } 2cleave ;

: serif-font ( -- font )
    <font>
        "serif" >>name
        12 >>size ; foldable

: sans-serif-font ( -- font )
    <font>
        "sans-serif" >>name
        12 >>size ; foldable

: monospace-font ( -- font )
    <font>
        "monospace" >>name
        12 >>size ; foldable