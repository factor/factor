! Copyright (C) 2011-2012 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors combinators formatting io kernel math
pdf.values sequences ;

IN: pdf.text

: comment ( string -- ) "% " write print ;

: foreground-color ( color -- ) pdf-write " rg" print ;

: background-color ( color -- ) pdf-write " RG" print ;


! text

: text-start ( -- ) "BT" print ;

: text-end ( -- ) "ET" print ;

: text-location ( x y -- ) "1 0 0 1 %f %f Tm\n" printf ;

: text-leading ( n -- ) "%d TL\n" printf ;

: text-rise ( n -- ) "%d Ts\n" printf ;

: text-size ( font -- )
    [
        [
            name>> {
                { "Helvetica" [ 1 ] }
                { "Times"     [ 2 ] }
                { "Courier"   [ 3 ] }
                [ " is unsupported" append throw ]
            } case
        ]
        [
            {
                { [ dup [ bold?>> ] [ italic?>> ] bi and ] [ 9 ] }
                { [ dup bold?>> ] [ 3 ] }
                { [ dup italic?>> ] [ 6 ] }
                [ 0 ]
            } cond nip +
        ] bi
    ] [ size>> ] bi "/F%d %d Tf\n" printf ;

: text-write ( string -- ) pdf-write " Tj" print ;

: text-nl ( -- ) "T*" print ;

: text-print ( string -- ) pdf-write " '" print ;



! graphics

: line-width ( n -- ) "%d w\n" printf ;

: line-dashed ( on off -- ) "[ %d %d ] 0 d\n" printf ;

: line-solid ( -- ) "[] 0 d" print ;

: line-move ( x y -- ) "%f %f m\n" printf ;

: line-line ( x y -- ) "%f %f l\n" printf ;

: gray ( percent -- ) "%.f g\n" printf ;

: rectangle ( x y width height -- ) "%d %d %d %d re\n" printf ;

: stroke ( -- ) "S" print ;

: fill ( -- ) "f" print ;

: B ( -- ) "B" print ;

: b ( -- ) "b" print ;

: c ( -- ) "300 400 400 400 400 300 c" print ; ! FIXME:
