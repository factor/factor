! Copyright (C) 2021 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors colors combinators endian generalizations io
io.encodings.binary io.files io.streams.byte-array kernel math
math.bitwise math.functions namespaces sequences ;

IN: tinyvg

! Primitives

: read-varuint ( -- n )
    0 0 [
        read1
        [ 0x7f bitand rot [ 7 * shift bitor ] keep 1 + swap ]
        [ 0x80 bitand zero? not ] bi
    ] loop nip ;

: write-varuint ( n -- )
    [ dup 0x80 >= ] [
        [ 0x7f bitand 0x80 bitor write1 ] [ -7 shift ] bi
    ] while write1 ;

: read-float32 ( -- n )
    4 read le> bits>float ;

: write-float32 ( n -- )
    float>bits 4 >le write ;

ERROR: invalid-length n ;

: write-length ( n -- )
    dup 1 < [ invalid-length ] when 1 - write-varuint ;

! Colors

: read-rgba-8888 ( -- rgba )
    [ read1 255 /f ] 4 call-n <rgba> ;

: write-rgba-8888 ( rgba -- )
    >rgba-components [ 255 * round >integer write1 ] 4 napply ;

: read-rgb-565 ( -- rgba )
    2 read le>
    [ 5 bits 31 /f ]
    [ -5 shift 6 bits 63 /f ]
    [ -11 shift 5 bits 31 /f ] tri
    1.0 <rgba> ;

: write-rgb-565 ( rgba -- )
    >rgba-components drop {
        [ 31 * >integer ]
        [ 63 * >integer 5 shift bitor ]
        [ 31 * >integer 11 shift bitor ]
    } spread 2 >le write ;

: read-rgba-f32 ( -- rgba )
    [ read-float32 ] 4 call-n <rgba> ;

: write-rgba-f32 ( rgba -- )
    >rgba-components [ write-float32 ] 4 napply ;

SYMBOL: color-encoding

: read-color ( -- color )
    color-encoding get {
        { 0 [ read-rgba-8888 ] }
        { 1 [ read-rgb-565 ] }
        { 2 [ read-rgba-f32 ] }
        { 3 [ "unsupported color encoding" throw ] }
    } case ;

: write-color ( color -- )
    color-encoding get {
        { 0 [ write-rgba-8888 ] }
        { 1 [ write-rgb-565 ] }
        { 2 [ write-rgba-f32 ] }
        { 3 [ "unsupported color encoding" throw ] }
    } case ;

! Color Table

SYMBOL: color-table

: read-color-table ( color-count -- color-table )
    [ read-color ] replicate ;

ERROR: invalid-color color-index ;

: check-color ( color-index -- color-index )
    dup color-table get length <= [ invalid-color ] unless ;

: read-color-index ( -- color-index )
    read-varuint check-color ;

! Coordinates

SYMBOL: coordinate-range

: coordinate-bytes ( -- n )
    coordinate-range get { 2 1 4 } nth ;

SYMBOL: scale-factor

: read-unit ( -- n )
    coordinate-bytes read le> scale-factor get /f ;

: write-unit ( n -- )
    scale-factor get * >integer coordinate-bytes >le write ;

! Point

TUPLE: point x y ;

C: <point> point

: read-point ( -- point )
    [ read-unit ] 2 call-n <point> ;

: read-points ( n -- rectangles )
    1 + [ read-point ] replicate ;

: write-point ( point -- )
    [ x>> write-unit ] [ y>> write-unit ] bi ;

! Rectangle

TUPLE: rectangle x y width height ;

C: <rectangle> rectangle

: read-rectangle ( -- rectangle )
    [ read-unit ] 4 call-n <rectangle> ;

: read-rectangles ( n -- rectangles )
    1 + [ read-rectangle ] replicate ;

: write-rectangle ( rectangle -- )
    {
        [ x>> write-unit ]
        [ y>> write-unit ]
        [ width>> write-unit ]
        [ height>> write-unit ]
    } cleave ;

! Line

TUPLE: line start end ;

C: <line> line

: read-line ( -- line )
    [ read-point ] 2 call-n <line> ;

: read-lines ( n -- rectangles )
    1 + [ read-line ] replicate ;

: write-line ( line -- )
    [ start>> write-point ] [ end>> write-point ] bi ;

! Styles

TUPLE: flat-colored color-index ;

C: <flat-colored> flat-colored

TUPLE: gradient point0 point1 color-index0 color-index1 ;

TUPLE: linear-gradient < gradient ;

C: <linear-gradient> linear-gradient

TUPLE: radial-gradient < gradient ;

C: <radial-gradient> radial-gradient

: read-gradient ( class -- style )
    [ [ read-point ] 2 call-n [ read-color-index ] 2 call-n ] dip boa ; inline

: read-style ( style-kind -- style )
    {
        { 0 [ read-color-index <flat-colored> ] }
        { 1 [ linear-gradient read-gradient ] }
        { 2 [ radial-gradient read-gradient ] }
    } case ;

GENERIC: write-style ( style -- )

M: flat-colored write-style
    color-index>> write-varuint ;

M: gradient write-style
    {
        [ point0>> write-point ]
        [ point1>> write-point ]
        [ color-index0>> write-varuint ]
        [ color-index1>> write-varuint ]
    } cleave ;

: write-style-kind ( style n -- )
    swap {
        { [ dup flat-colored? ] [ drop 0 ] }
        { [ dup linear-gradient? ] [ drop 1 ] }
        { [ dup radial-gradient? ] [ drop 2 ] }
    } cond 6 shift bitor write1 ;

! Commands

DEFER: read-path

DEFER: write-path

TUPLE: fill fill-style ;

: read-fill ( style-kind -- style count )
    read-varuint [ read-style ] dip ;

TUPLE: fill-polygon < fill polygon ;

C: <fill-polygon> fill-polygon

: read-fill-polygon ( style-kind -- command )
    read-fill read-points <fill-polygon> ;

TUPLE: fill-rectangles < fill rectangles ;

C: <fill-rectangles> fill-rectangles

: read-fill-rectangles ( style-kind -- command )
    read-fill read-rectangles <fill-rectangles> ;

TUPLE: fill-path < fill path ;

C: <fill-path> fill-path

: read-fill-path ( style-kind -- command )
    read-fill read-path <fill-path> ;

TUPLE: draw-line line-style line-width ;

: read-draw-line ( style-kind -- line-style line-width count )
    read-varuint [ read-style read-unit ] dip ;

TUPLE: draw-lines < draw-line lines ;

C: <draw-lines> draw-lines

: read-draw-lines ( style-kind -- command )
    read-draw-line read-lines <draw-lines> ;

TUPLE: draw-line-loop < draw-line points ;

C: <draw-line-loop> draw-line-loop

: read-draw-line-loop ( style-kind -- command )
    read-draw-line read-points <draw-line-loop> ;

TUPLE: draw-line-strip < draw-line points ;

C: <draw-line-strip> draw-line-strip

: read-draw-line-strip ( style-kind -- command )
    read-draw-line read-points <draw-line-strip> ;

TUPLE: draw-line-path < draw-line path ;

C: <draw-line-path> draw-line-path

: read-draw-line-path ( style-kind -- command )
    read-draw-line read-path <draw-line-path> ;

TUPLE: outline-fill fill-style line-style line-width ;

: read-outline-fill ( style-kind -- fill-style line-style line-width count )
    read1 [ -6 shift ] [ 6 bits ] bi
    [ [ read-style ] bi@ read-unit ] dip ;

TUPLE: outline-fill-polygon < outline-fill points ;

C: <outline-fill-polygon> outline-fill-polygon

: read-outline-fill-polygon ( style-kind -- command )
    read-outline-fill read-points <outline-fill-polygon> ;

TUPLE: outline-fill-rectangles < outline-fill rectangles ;

C: <outline-fill-rectangles> outline-fill-rectangles

: read-outline-fill-rectangles ( style-kind -- command )
    read-outline-fill read-rectangles <outline-fill-rectangles> ;

TUPLE: outline-fill-path < outline-fill path ;

C: <outline-fill-path> outline-fill-path

: read-outline-fill-path ( style-kind -- command )
    read-outline-fill read-path <outline-fill-path> ;

: read-command ( -- command/f )
    read1 [ -6 shift ] [ 6 bits ] bi {
        { 0 [ 0 assert= f ] } ! end-of-document
        { 1 [ read-fill-polygon ] }
        { 2 [ read-fill-rectangles ] }
        { 3 [ read-fill-path ] }
        { 4 [ read-draw-lines ] }
        { 5 [ read-draw-line-loop ] }
        { 6 [ read-draw-line-strip ] }
        { 7 [ read-draw-line-path ] }
        { 8 [ read-outline-fill-polygon ] }
        { 9 [ read-outline-fill-rectangles ] }
        { 10 [ read-outline-fill-path ] }
    } case ;

: read-commands ( -- commands )
    [ read-command dup ] [ ] produce nip ;

GENERIC: write-command ( command -- )

:: write-fill ( command n seq -- )
    command fill-style>> n write-style-kind
    seq length write-length
    command fill-style>> write-style ; inline

M: fill-polygon write-command
    1 over polygon>> [ write-fill ] [ [ write-point ] each ] bi ;

M: fill-rectangles write-command
    2 over rectangles>> [ write-fill ] [ [ write-rectangle ] each ] bi ;

M: fill-path write-command
    3 over path>> [ write-fill ] [ write-path ] bi ;

:: write-draw-line ( command n seq -- )
    command line-style>> n write-style-kind
    seq length write-length
    command line-style>> write-style
    command line-width>> write-unit ; inline

M: draw-lines write-command
    4 over lines>> [ write-draw-line ] [ [ write-line ] each ] bi ;

M: draw-line-loop write-command
    5 over points>> [ write-draw-line ] [ [ write-point ] each ] bi ;

M: draw-line-strip write-command
    6 over points>> [ write-draw-line ] [ [ write-point ] each ] bi ;

M: draw-line-path write-command
    7 over path>> [ write-draw-line ] [ write-path ] bi ;

:: write-outline-fill ( command n seq -- )
    command fill-style>> n write-style-kind
    command line-style>> seq length 1 - write-style-kind
    command fill-style>> write-style
    command line-style>> write-style
    command line-width>> write-unit ; inline

M: outline-fill-polygon write-command
    8 over points>> [ write-outline-fill ] [ [ write-point ] each ] bi ;

M: outline-fill-rectangles write-command
    9 over rectangles>> [ write-outline-fill ] [ [ write-rectangle ] each ] bi ;

M: outline-fill-path write-command
    10 over path>> [ write-outline-fill ] [ write-path ] bi ;

: write-commands ( commands -- )
    [ write-command ] each 0 write1 ;

! Nodes

TUPLE: instruction line-width ;

TUPLE: diagonal-line < instruction position ;

C: <diagonal-line> diagonal-line

TUPLE: horizontal-line < instruction x ;

C: <horizontal-line> horizontal-line

TUPLE: vertical-line < instruction y ;

C: <vertical-line> vertical-line

TUPLE: cubic-bezier < instruction control0 control1 point1 ;

C: <cubic-bezier> cubic-bezier

TUPLE: arc < instruction large-arc? sweep? ;

TUPLE: arc-circle < arc radius target ;

C: <arc-circle> arc-circle

TUPLE: arc-ellipse < arc radius-x radius-y rotation target ;

C: <arc-ellipse> arc-ellipse

TUPLE: close-path < instruction ;

C: <close-path> close-path

TUPLE: quadratic-bezier < instruction control point1 ;

C: <quadratic-bezier> quadratic-bezier

: read-tag ( -- line-width/f tag )
    read1 [ 4 bit? [ read-unit ] [ f ] if ] [ 3 bits ] bi ;

: read-arc ( -- large-arc? sweep? )
    read1 [ 0 bit? ] [ 1 bit? ] bi ;

: read-instruction ( -- instruction )
    read-tag {
        { 0 [ read-point <diagonal-line> ] }
        { 1 [ read-unit <horizontal-line> ] }
        { 2 [ read-unit <vertical-line> ] }
        { 3 [ [ read-point ] 3 call-n <cubic-bezier> ] }
        { 4 [ read-arc read-unit read-point <arc-circle> ] }
        { 5 [ read-arc [ read-unit ] 3 call-n read-point <arc-ellipse> ] }
        { 6 [ <close-path> ] }
        { 7 [ [ read-point ] 2 call-n <quadratic-bezier> ] }
    } case ;

: read-instructions ( n -- instructions )
    1 + [ read-instruction ] replicate ;

: write-tag ( instruction n -- )
    swap line-width>>
    [ [ 4 set-bit ] when write1 ]
    [ [ write-unit ] when* ] bi ;

: write-arc ( instruction -- )
    [ large-arc?>> 0b1 0b0 ? ] [ sweep?>> [ 0b10 bitor ] when ] bi write1 ;

GENERIC: write-instruction ( instruction -- )

M: diagonal-line write-instruction
    [ 0 write-tag ] [ position>> write-point ] bi ;

M: horizontal-line write-instruction
    [ 1 write-tag ] [ x>> write-unit ] bi ;

M: vertical-line write-instruction
    [ 2 write-tag ] [ y>> write-unit ] bi ;

M: cubic-bezier write-instruction
    {
        [ 3 write-tag ]
        [ control0>> write-point ]
        [ control1>> write-point ]
        [ point1>> write-point ]
    } cleave ;

M: arc-circle write-instruction
    {
        [ 4 write-tag ]
        [ write-arc ]
        [ radius>> write-unit ]
        [ target>> write-point ]
    } cleave ;

M: arc-ellipse write-instruction
    {
        [ 5 write-tag ]
        [ write-arc ]
        [ radius-x>> write-unit ]
        [ radius-y>> write-unit ]
        [ rotation>> write-unit ]
        [ target>> write-point ]
    } cleave ;

M: close-path write-instruction
    6 write-tag ;

M: quadratic-bezier write-instruction
    [ 7 write-tag ] [ control>> write-point ] [ point1>> write-point ] tri ;

! Segment

TUPLE: segment start instructions ;

C: <segment> segment

: read-segment ( n -- segment )
    read-point swap read-instructions segment boa ;

: write-segment ( segment -- )
    [ start>> write-point ] [ instructions>> [ write-instruction ] each ] bi ;

! Path

: read-path ( segment-count -- segments )
    1 + [ read-varuint ] replicate [ read-segment ] map ;

: write-path ( segments -- )
    [ [ instructions>> length write-length ] each ]
    [ [ write-segment ] each ] bi ;

! TinyVG

CONSTANT: tinyvg-magic B{ 0x72 0x56 }

CONSTANT: tinyvg-version 1

TUPLE: tinyvg scale color-encoding coordinate-range width height color-table commands ;

C: <tinyvg> tinyvg

: read-tinyvg ( -- tinyvg )
    [
        tinyvg new
            2 read tinyvg-magic assert=
            read1 tinyvg-version assert=
            read1 {
                [ 4 bits >>scale ]
                [ -4 shift 2 bits >>color-encoding ]
                [ -6 shift [ >>coordinate-range ] keep ]
            } cleave
            { 2 1 4 } nth '[ _ read le> ] 2 call-n
            [ >>width ] [ >>height ] bi*
            dup scale>> 2^ scale-factor set
            dup color-encoding>> color-encoding set
            dup coordinate-range>> coordinate-range set
            read-varuint read-color-table >>color-table
            dup color-table>> color-table set
            read-commands >>commands
    ] with-scope ;

: path>tinyvg ( path -- tinyvg )
    binary [ read-tinyvg ] with-file-reader ;

: bytes>tinyvg ( byte-array -- tinyvg )
    binary [ read-tinyvg ] with-byte-reader ;

: write-tinyvg ( tinyvg -- )
    [
        tinyvg-magic write
        tinyvg-version write1 {
            [ scale>> ]
            [ color-encoding>> 4 shift bitor ]
            [ coordinate-range>> 6 shift bitor write1 ]
            [ width>> ]
            [ height>> ]
            [ coordinate-range>> { 2 1 4 } nth '[ _ >le write ] bi@ ]
            [ scale>> 2^ scale-factor set ]
            [ color-encoding>> color-encoding set ]
            [ coordinate-range>> coordinate-range set ]
            [ color-table>> length write-varuint ]
            [ color-table>> [ write-color ] each ]
            [ color-table>> color-table set ]
            [ commands>> write-commands ]
        } cleave
    ] with-scope ;

: tinyvg>path ( tinyvg path -- )
    binary [ write-tinyvg ] with-file-writer ;

: tinyvg>bytes ( tinyvg -- byte-array )
    binary [ write-tinyvg ] with-byte-writer ;
