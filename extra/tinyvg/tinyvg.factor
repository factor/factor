! Copyright (C) 2021 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors colors combinators generalizations io io.binary
io.encodings.binary io.files io.streams.byte-array kernel math
math.bitwise namespaces sequences ;

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

! Header

CONSTANT: tinyvg-magic B{ 0x72 0x56 }

CONSTANT: tinyvg-version 1

TUPLE: tinyvg-header scale color-encoding coordinate-range width height color-count ;

: read-tinyvg-header ( -- header )
    2 read tinyvg-magic assert=
    read1 tinyvg-version assert=
    read1 [ 4 bits ] [ -4 shift 2 bits ] [ -6 shift ] tri
    dup { 2 1 4 } nth '[ _ read le> ] 2 call-n
    read-varuint tinyvg-header boa ;

: write-tinyvg-header ( header -- )
    tinyvg-magic write
    tinyvg-version write1 {
        [ scale>> ]
        [ color-encoding>> 4 shift bitor ]
        [ coordinate-range>> 6 shift bitor write1 ]
        [ width>> ]
        [ height>> ]
        [ coordinate-range>> { 2 1 4 } nth '[ _ >le write ] bi@ ]
        [ color-count>> write-varuint ]
    } cleave ;

! Colors

: read-rgba-8888 ( -- rgba )
    [ read1 255 /f ] 4 call-n <rgba> ;

: write-rgba-8888 ( rgba -- )
    >rgba-components [ 255 * >integer write1 ] 4 napply ;

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

: read-flat-colored ( -- style )
    read-color-index <flat-colored> ;

TUPLE: gradient point0 point1 color-index0 color-index1 ;

TUPLE: linear-gradient < gradient ;

TUPLE: radial-gradient < gradient ;

: read-gradient ( class -- style )
    [ [ read-point ] 2 call-n [ read-color-index ] 2 call-n ] dip boa ; inline

: read-style ( style-kind -- style )
    {
        { 0 [ read-flat-colored ] }
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

M: fill-polygon write-command
    {
        [ fill-style>> 1 write-style-kind ]
        [ polygon>> length write-length ]
        [ fill-style>> write-style ]
        [ polygon>> [ write-point ] each ]
    } cleave ;

M: fill-rectangles write-command
    {
        [ fill-style>> 2 write-style-kind ]
        [ rectangles>> length write-length ]
        [ fill-style>> write-style ]
        [ rectangles>> [ write-rectangle ] each ]
    } cleave ;

M: fill-path write-command
    {
        [ fill-style>> 3 write-style-kind ]
        [ path>> segments>> length write-length ]
        [ fill-style>> write-style ]
        [ path>> write-path ]
    } cleave ;

M: draw-lines write-command
    {
        [ line-style>> 4 write-style-kind ]
        [ lines>> length write-length ]
        [ line-style>> write-style ]
        [ line-width>> write-unit ]
        [ lines>> [ write-line ] each ]
    } cleave ;

M: draw-line-loop write-command
    {
        [ line-style>> 5 write-style-kind ]
        [ points>> length write-length ]
        [ line-style>> write-style ]
        [ line-width>> write-unit ]
        [ points>> [ write-point ] each ]
    } cleave ;

M: draw-line-strip write-command
    {
        [ line-style>> 6 write-style-kind ]
        [ points>> length write-length ]
        [ line-style>> write-style ]
        [ line-width>> write-unit ]
        [ points>> [ write-point ] each ]
    } cleave ;

M: draw-line-path write-command
    {
        [ line-style>> 7 write-style-kind ]
        [ path>> segments>> length write-length ]
        [ line-style>> write-style ]
        [ line-width>> write-unit ]
        [ path>> write-path ]
    } cleave ;

M: outline-fill-polygon write-command
    {
        [ fill-style>> 8 write-style-kind ]
        [ [ line-style>> ] [ points>> length 1 - ] bi write-style-kind ]
        [ fill-style>> write-style ]
        [ line-style>> write-style ]
        [ line-width>> write-unit ]
        [ points>> [ write-point ] each ]
    } cleave ;

M: outline-fill-rectangles write-command
    {
        [ fill-style>> 9 write-style-kind ]
        [ [ line-style>> ] [ rectangles>> length 1 - ] bi write-style-kind ]
        [ fill-style>> write-style ]
        [ line-style>> write-style ]
        [ line-width>> write-unit ]
        [ rectangles>> [ write-rectangle ] each ]
    } cleave ;

M: outline-fill-path write-command
    {
        [ fill-style>> 10 write-style-kind ]
        [ [ line-style>> ] [ path>> segments>> length 1 - ] bi write-style-kind ]
        [ fill-style>> write-style ]
        [ line-style>> write-style ]
        [ line-width>> write-unit ]
        [ path>> write-path ]
    } cleave ;

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
    read1 [ 4 bit? ] [ 3 bits ] bi [ [ read-unit ] [ f ] if ] dip ;

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

: read-segments ( n -- segments )
    1 + [ read-varuint ] replicate [ read-segment ] map ;

: write-segment ( segment -- )
    [ start>> write-point ] [ instructions>> [ write-instruction ] each ] bi ;

: write-segments ( segments -- )
    [ [ instructions>> length write-length ] each ]
    [ [ write-segment ] each ] bi ;

! Path

TUPLE: path segments ;

C: <path> path

: read-path ( segment-count -- path )
    read-segments path boa ;

: write-path ( path -- )
    segments>> write-segments ;

! TinyVG

TUPLE: tinyvg header color-table commands ;

C: <tinyvg> tinyvg

: read-tinyvg ( -- tinyvg )
    [
        read-tinyvg-header
        dup scale>> 2^ scale-factor set
        dup color-encoding>> color-encoding set
        dup coordinate-range>> coordinate-range set
        dup color-count>> read-color-table dup color-table set
        read-commands
        <tinyvg>
    ] with-scope ;

: path>tinyvg ( path -- tinyvg )
    binary [ read-tinyvg ] with-file-reader ;

: bytes>tinyvg ( byte-array -- tinyvg )
    binary [ read-tinyvg ] with-byte-reader ;

: write-tinyvg ( tinyvg -- )
    [
        {
            [ header>> write-tinyvg-header ]
            [ header>> scale>> 2^ scale-factor set ]
            [ header>> color-encoding>> color-encoding set ]
            [ header>> coordinate-range>> coordinate-range set ]
            [ color-table>> color-table set ]
            [ color-table>> [ write-color ] each ]
            [ commands>> write-commands ]
        } cleave
    ] with-scope ;

: tinyvg>path ( tinyvg path -- )
    binary [ write-tinyvg ] with-file-writer ;

: tinyvg>bytes ( tinyvg -- byte-array )
    binary [ write-tinyvg ] with-byte-writer ;
