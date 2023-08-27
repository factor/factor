! Copyright (C) 2018 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors byte-arrays classes combinators endian io
io.encodings.binary io.files io.streams.byte-array kernel
math math.order math.statistics sequences sequences.extras sets
;

IN: shapefiles

SINGLETON: null-shape
TUPLE: point x y ;
TUPLE: multipoint box points ;
TUPLE: polygon box parts points ;
TUPLE: polyline box parts points ;
TUPLE: point-z < point z m ;
TUPLE: polyline-z < polyline z-range z-array m-range m-array ;
TUPLE: polygon-z < polygon z-range z-array m-range m-array ;
TUPLE: multipoint-z < multipoint z-range z-array m-range m-array ;
TUPLE: point-m < point m ;
TUPLE: polyline-m < polyline m-range m-array ;
TUPLE: polygon-m < polygon m-range m-array ;
TUPLE: multipoint-m < multipoint m-range m-array ;
TUPLE: multipatch box parts part-types points z-range z-array m-range m-array ;

<PRIVATE

: read-int ( -- n )
    4 read le> ;

: read-ints ( n -- parts )
    [ read-int ] replicate ;

: read-double ( -- n )
    8 read le> bits>double ;

: read-doubles ( n -- array )
    [ read-double ] replicate ;

: read-box ( -- box )
    4 read-doubles ;

: read-range ( -- range )
    2 read-doubles ;

: read-point ( -- point )
    read-double read-double point boa ;

: read-points ( n -- points )
    [ read-point ] replicate ;

: (read-multipoint) ( -- box points )
    read-box read-int read-points ;

: read-multipoint ( -- multipoint )
    (read-multipoint) multipoint boa ;

: read-poly ( -- box parts points )
    read-box read-int read-int [ read-ints ] dip read-points ;

: read-point-z ( -- point-z )
    read-double read-double read-double read-double point-z boa ;

: read-poly-z ( -- box parts points z-range z-array m-range m-array )
    read-poly read-range over length
    [ read-doubles read-range ] [ read-doubles ] bi ;

: read-multipoint-z ( -- multipoint-z )
    (read-multipoint) read-range over length
    [ read-doubles read-range ] [ read-doubles ] bi
    multipoint-z boa ;

: read-point-m ( -- point-m )
    read-double read-double read-double point-m boa ;

: read-poly-m ( -- box parts points m-range m-array )
    read-poly read-range over length read-doubles ;

: read-multipoint-m ( -- multipoint-m )
    (read-multipoint) read-range over length read-doubles
    multipoint-m boa ;

: read-multipatch ( -- multipatch )
    read-box read-int read-int
    [ [ read-ints ] [ read-ints ] bi ] dip
    [ read-points read-range ]
    [ read-doubles read-range ]
    [ read-doubles ] tri multipatch boa ;

: read-shape ( -- shape )
    read-int {
        { 0 [ null-shape ] }
        { 1 [ read-point ] }
        { 3 [ read-poly polyline boa ] }
        { 5 [ read-poly polygon boa ] }
        { 8 [ read-multipoint ] }
        { 11 [ read-point-z ] }
        { 13 [ read-poly-z polyline-z boa ] }
        { 15 [ read-poly-z polygon-z boa ] }
        { 18 [ read-multipoint-z ] }
        { 21 [ read-point-m ] }
        { 23 [ read-poly-m polyline-m boa ] }
        { 25 [ read-poly-m polygon-m boa ] }
        { 28 [ read-multipoint-m ] }
        { 31 [ read-multipatch ] }
    } case ;

TUPLE: header { file-code initial: 9994 } file-length
{ version initial: 1000 } shape-type x-min y-min x-max y-max
z-min z-max m-min m-max ;

: read-header ( -- header )
    4 read be> dup 9994 assert=
    20 read drop ! unused
    4 read be>
    read-int dup 1000 assert=
    read-int
    read-double
    read-double
    read-double
    read-double
    read-double
    read-double
    read-double
    read-double
    header boa ;

TUPLE: record number content-length shape ;

: read-record ( -- record/f )
    4 read [ be> 4 read be> read-shape record boa ] [ f ] if* ;

: read-records ( -- records )
    [ read-record ] loop>array ;

: read-shp ( -- header records )
    read-header read-records ;

: file>shp ( path -- header records )
    binary [ read-shp ] with-file-reader ;

TUPLE: index offset content-length ;

: read-index ( -- index/f )
    4 read [ be> 4 read be> index boa ] [ f ] if* ;

: read-indices ( -- indices )
    [ read-index ] loop>array ;

: read-shx ( -- header indices )
    read-header read-indices ;

: file>shx ( path -- header indices )
    binary [ read-shx ] with-file-reader ;

: num-records ( path -- n )
    ".shx" append binary [
        read-header file-length>> 2 * 100 - 8 /
    ] with-file-reader ;

: nth-index ( n path -- index )
    ".shx" append binary [
        8 * 100 + seek-absolute seek-input read-index
    ] with-file-reader ;

: nth-record ( n path -- record )
    [ nth-index offset>> ] keep ".shp" append binary [
        2 * seek-absolute seek-input read-record
    ] with-file-reader ;

: write-int ( n -- )
    4 >le write ;

: write-double ( n -- )
    double>bits 8 >le write ;

: write-point ( point -- )
    [ x>> ] [ y>> ] bi [ write-double ] bi@ ;

:: update-box ( header shape -- header )
    header shape points>> :> points
    points [ x>> ] map minmax :> ( x-min x-max )
    points [ y>> ] map minmax :> ( y-min y-max )
    [ x-min [ or ] keep min ] change-x-min
    [ x-max [ or ] keep max ] change-x-max
    [ y-min [ or ] keep min ] change-y-min
    [ y-max [ or ] keep max ] change-y-max
    { x-min y-min x-max y-max } shape box<< ;

:: update-z-range ( header shape -- header )
    header shape z-array>> minmax :> ( z-min z-max )
    [ z-min [ or ] keep min ] change-z-min
    [ z-max [ or ] keep max ] change-z-max
    { z-min z-max } shape z-range<< ;

:: update-m-range ( header shape -- header )
    header shape m-array>> minmax :> ( m-min m-max )
    [ m-min [ or ] keep min ] change-m-min
    [ m-max [ or ] keep max ] change-m-max
    { m-min m-max } shape m-range<< ;

GENERIC: update-bounds ( header shape -- header )

M: object update-bounds drop ;

M: polyline update-bounds update-box ;

M: polygon update-bounds update-box ;

M: multipoint update-bounds update-box ;

M: polyline-z update-bounds
    [ call-next-method ] [ update-z-range ] [ update-m-range ] tri ;

M: polygon-z update-bounds
    [ call-next-method ] [ update-z-range ] [ update-m-range ] tri ;

M: multipoint-z update-bounds
    [ call-next-method ] [ update-z-range ] [ update-m-range ] tri ;

M: polyline-m update-bounds
    [ call-next-method ] [ update-m-range ] bi ;

M: polygon-m update-bounds
    [ call-next-method ] [ update-m-range ] bi ;

M: multipoint-m update-bounds
    [ call-next-method ] [ update-m-range ] bi ;

M: multipatch update-bounds
    [ update-box ] [ update-z-range ] [ update-m-range ] tri ;

GENERIC: (write-shape) ( shape -- )

M: null-shape (write-shape) drop ;

M: point (write-shape) write-point ;

: write-poly ( poly -- )
    {
        [ box>> [ write-double ] each ]
        [ parts>> length write-int ]
        [ points>> length write-int ]
        [ parts>> [ write-int ] each ]
        [ points>> [ write-point ] each ]
    } cleave ; inline

M: polyline (write-shape) write-poly ;

M: polygon (write-shape) write-poly ;

M: multipoint (write-shape)
    {
        [ box>> [ write-double ] each ]
        [ points>> length write-int ]
        [ points>> [ write-point ] each ]
    } cleave ;

M: point-z (write-shape)
    [ call-next-method ] [ z>> ] [ m>> ] tri [ write-double ] bi@ ;

: write-z ( shape -- )
    [ z-range>> ] [ z-array>> ] bi [ [ write-double ] each ] bi@ ; inline

: write-m ( shape -- )
    [ m-range>> ] [ m-array>> ] bi [ [ write-double ] each ] bi@ ; inline

: write-poly-z ( poly -- )
    [ write-poly ] [ write-z ] [ write-m ] tri ; inline

M: polyline-z (write-shape) write-poly-z ;

M: polygon-z (write-shape) write-poly-z ;

M: multipoint-z (write-shape)
    [ call-next-method ] [ write-z ] [ write-m ] tri ;

M: point-m (write-shape)
    [ call-next-method ] [ m>> write-double ] bi ;

: write-poly-m ( poly -- )
    [ write-poly ] [ write-m ] bi ; inline

M: polyline-m (write-shape) write-poly-m ;

M: polygon-m (write-shape) write-poly-m ;

M: multipoint-m (write-shape)
    [ call-next-method ] [ write-m ] bi ;

M: multipatch (write-shape)
    {
        [ box>> [ write-double ] each ]
        [ parts>> length write-int ]
        [ points>> length write-int ]
        [ parts>> [ write-int ] each ]
        [ part-types>> [ write-int ] each ]
        [ points>> [ write-point ] each ]
        [ write-z ]
        [ write-m ]
    } cleave ;

GENERIC: shape-type ( shape -- shape-type )
M: null-shape shape-type drop 0 ;
M: point shape-type drop 1 ;
M: polyline shape-type drop 3 ;
M: polygon shape-type drop 5 ;
M: multipoint shape-type drop 8 ;
M: point-z shape-type drop 11 ;
M: polyline-z shape-type drop 13 ;
M: polygon-z shape-type drop 15 ;
M: multipoint-z shape-type drop 18 ;
M: point-m shape-type drop 21 ;
M: polyline-m shape-type drop 23 ;
M: polygon-m shape-type drop 25 ;
M: multipoint-m shape-type drop 28 ;
M: multipatch shape-type drop 31 ;

: write-shape ( shape -- )
    [ shape-type write-int ] [ (write-shape) ] bi ;

: write-header ( header -- )
    {
        [ file-code>> 4 >be write ]
        [ drop 20 <byte-array> write ] ! unused
        [ file-length>> 4 >be write ]
        [ version>> write-int ]
        [ shape-type>> write-int ]
        [ x-min>> 0.0 or write-double ]
        [ y-min>> 0.0 or write-double ]
        [ x-max>> 0.0 or write-double ]
        [ y-max>> 0.0 or write-double ]
        [ z-min>> 0.0 or write-double ]
        [ z-max>> 0.0 or write-double ]
        [ m-min>> 0.0 or write-double ]
        [ m-max>> 0.0 or write-double ]
    } cleave ;

: write-record ( shape index -- )
    1 + 4 >be write
    binary [ write-shape ] with-byte-writer
    [ length 2/ 4 >be write ] [ write ] bi ;

ERROR: non-null-shapes-must-be-same-type shape-types ;

: non-null-shape-types ( shapes -- shape-types )
    [ null-shape? ] reject [ class-of ] map members ;

: check-shape-types ( shapes -- )
    non-null-shape-types dup length 1 >
    [ non-null-shapes-must-be-same-type ] [ drop ] if ;

: write-shp ( shapes -- header indices )
    [ header new ] dip {
        [ check-shape-types ]
        [ first shape-type >>shape-type ]
        [ [ update-bounds ] each ]
        [ ]
    } cleave binary [
        [
            [ tell-output 100 + 2/ ] 2dip write-record
            tell-output 100 + 8 - 2/ over - index boa
        ] map-index
    ] with-byte-writer swap [
        [ length 100 + 2/ >>file-length [ write-header ] keep ]
        [ write ] bi
    ] dip ;

: write-index ( index -- )
    [ offset>> ] [ content-length>> ] bi [ 4 >be write ] bi@ ;

: write-shx ( header indices -- )
    [ length 8 * 100 + 2/ >>file-length write-header ]
    [ [ write-index ] each ] bi ;

PRIVATE>

: load-shapes ( path -- shapes )
    ".shp" append file>shp nip [ shape>> ] map ;

: save-shapes ( shapes path -- )
    [ ".shp" append binary [ write-shp ] with-file-writer ]
    [ ".shx" append binary [ write-shx ] with-file-writer ] bi ;
