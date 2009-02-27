! Copyright (C) 2009 Tim Wawrzynczak
! See http://factorcode.org/license.txt for BSD license.
USING: sequences io io.encodings.binary io.files io.pathnames
strings kernel math io.mmap io.mmap.uchar accessors syntax
combinators math.ranges unicode.categories byte-arrays
io.encodings.string io.encodings.utf8 assocs math.parser
combinators.short-circuit fry ;
IN: id3

<PRIVATE

CONSTANT: genres
  H{
    { 0 "Blues" }
    { 1 "Classic Rock" }
    { 2 "Country" }
    { 3 "Dance" }
    { 4 "Disco" }
    { 5 "Funk" }
    { 6 "Grunge" }
    { 7 "Hip-Hop" }
    { 8 "Jazz" }
    { 9 "Metal" }
    { 10 "New Age" }
    { 11 "Oldies" }
    { 12 "Other" }
    { 13 "Pop" }
    { 14 "R&B" }
    { 15 "Rap" }
    { 16 "Reggae" }
    { 17 "Rock" }
    { 18 "Techno" }
    { 19 "Industrial" }
    { 20 "Alternative" }
    { 21 "Ska" }
    { 22 "Death Metal" }
    { 23 "Pranks" }
    { 24 "Soundtrack" }
    { 25 "Euro-Techno" }
    { 26 "Ambient" }
    { 27 "Trip-Hop" }
    { 28 "Vocal" }
    { 29 "Jazz+Funk" }
    { 30 "Fusion" }
    { 31 "Trance" }
    { 32 "Classical" }
    { 33 "Instrumental" }
    { 34 "Acid" }
    { 35 "House" }
    { 36 "Game" }
    { 37 "Sound Clip" }
    { 38 "Gospel" }
    { 39 "Noise" }
    { 40 "AlternRock" }
    { 41 "Bass" }
    { 42 "Soul" }
    { 43 "Punk" }
    { 44 "Space" }
    { 45 "Meditative" }
    { 46 "Instrumental Pop" }
    { 47 "Instrumental Rock" }
    { 48 "Ethnic" }
    { 49 "Gothic" }
    { 50 "Darkwave" }
    { 51 "Techno-Industrial" }
    { 52 "Electronic" }
    { 53 "Pop-Folk" }
    { 54 "Eurodance" }
    { 55 "Dream" }
    { 56 "Southern Rock" }
    { 57 "Comedy" }
    { 58 "Cult" }
    { 59 "Gangsta" }
    { 60 "Top 40" }
    { 61 "Christian Rap" }
    { 62 "Pop/Funk" }
    { 63 "Jungle" }
    { 64 "Native American" }
    { 65 "Cabaret" }
    { 66 "New Wave" }
    { 67 "Psychedelic" }
    { 68 "Rave" }
    { 69 "Showtunes" }
    { 70 "Trailer" }
    { 71 "Lo-Fi" }
    { 72 "Tribal" }
    { 73 "Acid Punk" }
    { 74 "Acid Jazz" }
    { 75 "Polka" }
    { 76 "Retro" }
    { 77 "Musical" }
    { 78 "Rock & Roll" }
    { 79 "Hard Rock" }
    { 80 "Folk" }
    { 81 "Folk-Rock" }
    { 82 "National Folk" }
    { 83 "Swing" }
    { 84 "Fast Fusion" }
    { 85 "Bebop" }
    { 86 "Latin" }
    { 87 "Revival" }
    { 88 "Celtic" }
    { 89 "Bluegrass" }
    { 90 "Avantgarde" }
    { 91 "Gothic Rock" }
    { 92 "Progressive Rock" }
    { 93 "Psychedelic Rock" }
    { 94 "Symphonic Rock" }
    { 95 "Slow Rock" }
    { 96 "Big Band" }
    { 97 "Chorus" }
    { 98 "Easy Listening" }
    { 99 "Acoustic" }
    { 100 "Humour" }
    { 101 "Speech" }
    { 102 "Chanson" }
    { 103 "Opera" }
    { 104 "Chamber Music" }
    { 105 "Sonata" }
    { 106 "Symphony" }
    { 107 "Booty Bass" }
    { 108 "Primus" }
    { 109 "Porn Groove" }
    { 110 "Satire" }
    { 111 "Slow Jam" }
    { 112 "Club" }
    { 113 "Tango" }
    { 114 "Samba" }
    { 115 "Folklore" }
    { 116 "Ballad" }
    { 117 "Power Ballad" }
    { 118 "Rhythmic Soul" }
    { 119 "Freestyle" }
    { 120 "Duet" }
    { 121 "Punk Rock" }
    { 122 "Drum Solo" }
    { 123 "A capella" }
    { 124 "Euro-House" }
    { 125 "Dance Hall" }
} ! end genre hashtable

! tuples

TUPLE: header version flags size ;

TUPLE: frame frame-id flags size data ;

TUPLE: id3v2-info header frames ;

TUPLE: id3-info title artist album year comment genre ;

: <id3-info> ( -- object ) id3-info new ;

: <id3v2-info> ( header frames -- object ) id3v2-info boa ;

: <header> ( -- object ) header new ;

: <frame> ( -- object ) frame new ;

! utility words

: id3v2? ( mmap -- ? )
    "ID3" head? ;

: id3v1? ( mmap -- ? )
    { [ length 128 >= ] [ 128 tail-slice* "TAG" head? ] } 1&& ;

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
        [ read-frame-id    utf8 decode  >>frame-id ]
        [ read-frame-flags >byte-array  >>flags ]
        [ read-frame-size  >28bitword   >>size ]
        [ read-frame-data  utf8 decode  >>data ]
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
        [ read-header-supported-version? >>version ]
        [ read-header-flags >>flags ]
        [ read-header-size >>size ]
    } cleave ;

: drop-header ( mmap -- seq1 seq2 )
    dup 10 tail-slice swap ;

: frame-tag ( frame string -- tag/f )
    '[ frame-id>> _ = ] find nip ; inline

: parse-frames ( id3v2-info -- id3-info )
    [ <id3-info> ] dip frames>>
    {
        [ "TIT2" frame-tag [ data>> >>title ] when* ]
        [ "TALB" frame-tag [ data>> >>album ] when* ]
        [ "TPE1" frame-tag [ data>> >>artist ] when* ]
        [ "TCON" frame-tag [ data>> [ [ digit? ] filter string>number ] keep swap [ genres at nip ] when*
          >>genre ] when* ]
        [ "COMM" frame-tag [ data>> >>comment ] when* ]
        [ "TYER" frame-tag [ data>> >>year ] when* ]
    } cleave ;

: read-v2-tag-data ( seq -- id3-info )
    drop-header read-v2-header swap read-frames <id3v2-info> parse-frames ;
    
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
    [ <id3-info> ] dip
    {
        [ read-title   utf8 decode  filter-text-data >>title   ]
        [ read-artist  utf8 decode  filter-text-data >>artist  ]
        [ read-album   utf8 decode  filter-text-data >>album   ]
        [ read-year    utf8 decode  filter-text-data >>year    ]
        [ read-comment utf8 decode  filter-text-data >>comment ]
        [ read-genre   >fixnum       genres at       >>genre ]
    } cleave ;

: read-v1-tag-data ( seq -- mp3-file )
    skip-to-v1-data (read-v1-tag-data) ;

PRIVATE>

! public interface

: file-id3-tags ( path -- object/f )
    [
        {
            { [ dup id3v2? ] [ read-v2-tag-data ] } ! ( ? -- id3v2 )
            { [ dup id3v1? ] [ read-v1-tag-data ] } ! ( ? -- id3-info )
            [ drop f ] ! ( mmap -- f )
        } cond
    ] with-mapped-uchar-file ;

! end
