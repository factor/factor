! Copyright (C) 2018 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors combinators io io.binary io.encodings.binary
io.files kernel math sequences ;

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
    [ read-record dup ] [ ] produce nip ;

: read-shp ( -- header records )
    read-header read-records ;

: file>shp ( path -- header records )
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

PRIVATE>

: load-shapes ( path -- shapes )
    ".shp" append file>shp nip [ shape>> ] map ;
