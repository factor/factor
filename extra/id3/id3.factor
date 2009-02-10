! Copyright (C) 2009 Tim Wawrzynczak
! See http://factorcode.org/license.txt for BSD license.
USING: sequences io io.encodings.binary io.files io.pathnames strings kernel math io.mmap io.mmap.uchar accessors syntax combinators math.ranges unicode.categories byte-arrays prettyprint io.encodings.string io.encodings.ascii ;
IN: id3

! tuples

TUPLE: header version flags size ;

TUPLE: frame frame-id flags size data ;

TUPLE: mp3v2-file header frames ;

TUPLE: mp3v1-file title artist album year comment genre ;

: <mp3v1-file> ( -- object ) mp3v1-file new ;

: <mp3v2-file> ( header frames -- object ) mp3v2-file boa ;

: <header> ( -- object ) header new ;

: <frame> ( -- object ) frame new ;

<PRIVATE

! utility words

: id3v2? ( mmap -- ? )
    "ID3" head? ;

: id3v1? ( mmap -- ? )
    128 tail-slice* "TAG" head? ;

: >28bitword ( seq -- int )
    0 [ swap 7 shift bitor ] reduce ;

: filter-text-data ( data -- filtered )
    [ printable? ] filter ;

! frame details stuff

: valid-frame-id? ( id -- ? )
    [ [ digit? ] [ LETTER? ] bi or ] all? ;

: read-frame-id ( mmap -- id )
    4 head-slice ;

: read-frame-size ( mmap -- size )
    [ 4 8 ] dip subseq ;

: read-frame-flags ( mmap -- flags )
    [ 8 10 ] dip subseq ;

: read-frame-data ( frame mmap -- frame data )
    [ 10 over size>> 10 + ] dip <slice> filter-text-data ;

! read whole frames

: (read-frame) ( mmap -- frame )
    [ <frame> ] dip
    {
        [ read-frame-id    ascii decode >>frame-id ]
        [ read-frame-flags >byte-array  >>flags ]
        [ read-frame-size  >28bitword   >>size ]
        [ read-frame-data  ascii decode >>data ]
    } cleave ;

: read-frame ( mmap -- frame/f )
    dup read-frame-id valid-frame-id? [ (read-frame) ] [ drop f ] if ;

: remove-frame ( mmap frame -- mmap )
    size>> 10 + tail-slice ;

: read-frames ( mmap -- frames )
    [ dup read-frame dup ]
    [ [ remove-frame ] keep ]
    [ drop ] produce nip ;
    
! header stuff

: read-header-supported-version? ( mmap -- ? )
    3 tail-slice [ { 4 } head? ] [ { 3 } head? ] bi or ;

: read-header-flags ( mmap -- flags )
    5 swap nth ;

: read-header-size ( mmap -- size )
    [ 6 10 ] dip <slice> >28bitword ;

: read-v2-header ( mmap -- id3header )
    [ <header> ] dip
    {
        [ read-header-supported-version?  >>version ]
        [ read-header-flags >>flags ]
        [ read-header-size >>size ]
    } cleave ;

: drop-header ( mmap -- seq1 seq2 )
    dup 10 tail-slice swap ;

: read-v2-tag-data ( seq -- mp3v2-file )
    drop-header read-v2-header swap read-frames <mp3v2-file> ;

! v1 information

: skip-to-v1-data ( seq -- seq )
    125 tail-slice* ;

: read-title ( seq -- title )
    30 head-slice ;

: read-artist ( seq -- title )
    [ 30 60 ] dip subseq ;

: read-album ( seq -- album )
    [ 60 90 ] dip subseq ;

: read-year ( seq -- year )
    [ 90 94 ] dip subseq ;

: read-comment ( seq -- comment )
    [ 94 124 ] dip subseq ;

: read-genre ( seq -- genre )
    [ 124 ] dip nth ;

: (read-v1-tag-data) ( seq -- mp3-file )
    [ <mp3v1-file> ] dip
    {
        [ read-title   ascii decode  >>title ]
        [ read-artist  ascii decode  >>artist ]
        [ read-album   ascii decode  >>album ]
        [ read-year    ascii decode  >>year ]
        [ read-comment ascii decode  >>comment ]
        [ read-genre   >fixnum       >>genre ]
    } cleave ;

: read-v1-tag-data ( seq -- mp3-file )
    skip-to-v1-data (read-v1-tag-data) ;

PRIVATE>

! main stuff

: id3-parse-mp3-file ( path -- object )
    [
        {
            { [ dup id3v2? ] [ read-v2-tag-data ] } ! ( ? -- mp3v2-file )
            { [ dup id3v1? ] [ read-v1-tag-data ] } ! ( ? -- mp3v1-file )
            [ drop f ] ! ( mmap -- f )
        } cond
    ] with-mapped-uchar-file ;

! end
