! Copyright (C) 2018 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: arrays combinators io io.binary.fast io.encodings.binary
io.files kernel math sequences ;

IN: shapefiles

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

PRIVATE>

TUPLE: header file-code file-length version shape-type x-min
y-min x-max y-max z-min z-max m-min m-max ;

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

SINGLETON: null-shape

TUPLE: point x y ;

: read-point ( -- point )
    read-double read-double point boa ;

: read-points ( n -- points )
    [ read-point ] replicate ;

TUPLE: multipoint box points ;

: read-multipoint ( -- multipoint )
    read-box read-int read-points multipoint boa ;

TUPLE: polyline box parts points ;

: read-polyline ( -- polyline )
    read-box read-int read-int [ read-ints ] dip
    read-points polyline boa ;

TUPLE: polygon box parts points ;

: read-polygon ( -- polygon )
    read-box read-int read-int [ read-ints ] dip
    read-points polygon boa ;

TUPLE: point-m x y m ;

: read-point-m ( -- point-m )
    read-double read-double read-double point-m boa ;

TUPLE: multipoint-m box points m-range m-array ;

: read-multipoint-m ( -- multipoint-m )
    read-box read-int
    [ read-points read-range ] [ read-doubles ] bi
    multipoint-m boa ;

TUPLE: polyline-m box parts points m-range m-array ;

: read-polyline-m ( -- polyline-m )
    read-box read-int read-int [ read-ints ] dip
    [ read-points read-range ] [ read-doubles ] bi
    polyline-m boa ;

TUPLE: polygon-m box parts points m-range m-array ;

: read-polygon-m ( -- polygon-m )
    read-box read-int read-int [ read-ints ] dip
    [ read-points read-range ] [ read-doubles ] bi
    polygon-m boa ;

TUPLE: point-z x y z m ;

: read-point-z ( -- point-z )
    read-double read-double read-double read-double point-z boa ;

TUPLE: multipoint-z box points z-range z-array m-range m-array ;

: read-multipoint-z ( -- multipoint-z )
    read-box read-int
    [ read-points read-range ]
    [ read-doubles read-range ]
    [ read-doubles ] tri multipoint-z boa ;

TUPLE: polyline-z box parts points z-range z-array m-range
m-array ;

: read-polyline-z ( -- polyline-z )
    read-box read-int read-int [ read-ints ] dip
    [ read-points read-range ]
    [ read-doubles read-range ]
    [ read-doubles ] tri polyline-z boa ;

TUPLE: polygon-z box parts points z-range z-array m-range
m-array ;

: read-polygon-z ( -- polygon-z )
    read-box read-int read-int [ read-ints ] dip
    [ read-points read-range ]
    [ read-doubles read-range ]
    [ read-doubles ] tri polygon-z boa ;

TUPLE: multipatch box parts points part-types z-range z-array
m-range m-array ;

: read-multipatch ( -- multipatch )
    read-box read-int read-int
    [ [ read-ints ] [ read-ints ] bi ] dip
    [ read-points read-range ]
    [ read-doubles read-range ]
    [ read-doubles ] tri multipatch boa ;

: read-shape ( -- shape )
    4 read le> {
        { 0 [ null-shape ] }
        { 1 [ read-point ] }
        { 3 [ read-polyline ] }
        { 5 [ read-polygon ] }
        { 8 [ read-multipoint ] }
        { 11 [ read-point-z ] }
        { 13 [ read-polyline-z ] }
        { 15 [ read-polygon-z ] }
        { 18 [ read-multipoint-z ] }
        { 21 [ read-point-m ] }
        { 23 [ read-polyline-m ] }
        { 25 [ read-polygon-m ] }
        { 28 [ read-multipoint-m ] }
        { 31 [ read-multipatch ] }
    } case ;

TUPLE: record number content-length shape ;

: read-record ( -- record/f )
    4 read [ be> 4 read be> read-shape record boa ] [ f ] if* ;

: read-records ( -- records )
    [ read-record dup ] [ ] produce nip ;

: read-shp ( -- header shapes )
    read-header read-records ;

: file>shp ( path -- header shapes )
    binary [ read-shp ] with-file-reader ;

TUPLE: index offset content-length ;

: read-index ( -- index/f )
    4 read [ be> 4 read be> index boa ] [ f ] if* ;

: read-indices ( -- indices )
    [ read-index dup ] [ ] produce nip ;

: read-shx ( -- header indices )
    read-header read-indices ;

: file>shx ( path -- header indices )
    binary [ read-shx ] with-file-reader ;
