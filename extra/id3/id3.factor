! Copyright (C) 2009 Tim Wawrzynczak, Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs byte-arrays
combinators combinators.short-circuit combinators.smart
continuations io.directories io.encodings.ascii
io.encodings.string io.encodings.utf16 io.mmap kernel math
math.functions math.parser sequences splitting unicode ;
FROM: alien.c-types => uchar ;
IN: id3

<PRIVATE

CONSTANT: genres
    {
        "Blues" "Classic Rock" "Country" "Dance" "Disco" "Funk"
        "Grunge" "Hip-Hop" "Jazz" "Metal" "New Age" "Oldies" "Other"
        "Pop" "R&B" "Rap" "Reggae" "Rock" "Techno" "Industrial"
        "Alternative" "Ska" "Death Metal" "Pranks" "Soundtrack"
        "Euro-Techno" "Ambient" "Trip-Hop" "Vocal" "Jazz+Funk"
        "Fusion" "Trance" "Classical" "Instrumental" "Acid" "House"
        "Game" "Sound Clip" "Gospel" "Noise" "AlternRock" "Bass"
        "Soul" "Punk" "Space" "Meditative" "Instrumental Pop"
        "Instrumental Rock" "Ethnic" "Gothic" "Darkwave"
        "Techno-Industrial" "Electronic" "Pop-Folk" "Eurodance"
        "Dream" "Southern Rock" "Comedy" "Cult" "Gangsta" "Top 40"
        "Christian Rap" "Pop/Funk" "Jungle" "Native American"
        "Cabaret" "New Wave" "Psychedelic" "Rave" "Showtunes"
        "Trailer" "Lo-Fi" "Tribal" "Acid Punk" "Acid Jazz" "Polka"
        "Retro" "Musical" "Rock & Roll" "Hard Rock" "Folk"
        "Folk-Rock" "National Folk" "Swing" "Fast Fusion" "Bebop"
        "Latin" "Revival" "Celtic" "Bluegrass" "Avantgarde"
        "Gothic Rock" "Progressive Rock" "Psychedelic Rock"
        "Symphonic Rock" "Slow Rock" "Big Band" "Chorus"
        "Easy Listening" "Acoustic" "Humour" "Speech" "Chanson"
        "Opera" "Chamber Music" "Sonata" "Symphony" "Booty Bass"
        "Primus" "Porn Groove" "Satire" "Slow Jam" "Club" "Tango"
        "Samba" "Folklore" "Ballad" "Power Ballad" "Rhythmic Soul"
        "Freestyle" "Duet" "Punk Rock" "Drum Solo" "A capella"
        "Euro-House" "Dance Hall" "Goa" "Drum & Bass" "Club-House"
        "Hardcore" "Terror" "Indie" "BritPop" "Negerpunk"
        "Polsk Punk" "Beat" "Christian Gangsta Rap" "Heavy Metal"
        "Black Metal" "Crossover" "Contemporary Christian"
        "Christian Rock"
    }

TUPLE: header version flags size ;

TUPLE: frame tag flags size data ;

TUPLE: id3 header frames
title artist album year comment genre
speed genre-name start-time end-time ;

: <id3> ( -- id3 )
    id3 new
    H{ } clone >>frames ; inline

: <header> ( -- object ) header new ; inline

: <frame> ( -- object ) frame new ; inline

: id3v2? ( seq -- ? ) "ID3" head? ; inline

CONSTANT: id3v1-length 128
CONSTANT: id3v1-offset 128
CONSTANT: id3v1+-length 227
: id3v1+-offset ( -- n ) id3v1-length id3v1+-length + ; inline

: id3v1? ( seq -- ? )
    {
        [ length id3v1-offset >= ]
        [ id3v1-length tail-slice* "TAG" head? ]
    } 1&& ;

: id3v1+? ( seq -- ? )
    {
        [ length id3v1+-offset >= ]
        [ id3v1+-length tail-slice* "TAG+" head? ]
    } 1&& ;

: pair>frame ( string key -- frame/f )
    over [
        <frame>
            swap >>tag
            swap >>data
    ] [
        2drop f
    ] if ;

: id3v1>frames ( id3v1 -- seq )
    [
        {
            [ title>> "TIT2" pair>frame ]
            [ artist>> "TPE1" pair>frame ]
            [ album>> "TALB" pair>frame ]
            [ year>> "TYER" pair>frame ]
            [ comment>> "COMM" pair>frame ]
            [ genre>> "TCON" pair>frame ]
        } cleave
    ] output>array sift ;

: sequence>synchsafe ( seq -- n )
    0 [ [ 7 shift ] dip bitor ] reduce ;

: synchsafe>sequence ( n -- seq )
    dup 1 + log2 1 + 7 / ceiling
    [ [ -7 shift ] keep 0x7f bitand  ] replicate nip reverse ;

: filter-text-data ( data -- filtered )
    [ printable? ] filter ;

: valid-tag? ( id -- ? )
    [ { [ digit? ] [ LETTER? ] } 1|| ] all? ;

: read-frame-data ( frame seq -- frame data )
    [ 10 over size>> 10 + ] dip <slice> filter-text-data ;

: decode-text ( string -- string' )
    dup 2 index-or-length head
    { { 0xff 0xfe } { 0xfe 0xff } } member?
    utf16 ascii ? decode ;

: (read-frame) ( seq -- frame )
    [ <frame> ] dip
    {
        [ 4 head-slice decode-text >>tag ]
        [ [ 4 8 ] dip subseq sequence>synchsafe >>size ]
        [ [ 8 10 ] dip subseq >byte-array >>flags ]
        [ read-frame-data decode-text >>data ]
    } cleave ;

: read-frame ( seq -- frame/f )
    dup 4 head-slice valid-tag?
    [ (read-frame) ] [ drop f ] if ;

: remove-frame ( seq frame -- seq )
    size>> 10 + tail-slice ;

: frames>assoc ( seq -- assoc )
    [ [ tag>> ] keep ] H{ } map>assoc ;

: read-frames ( seq -- assoc )
    [ dup read-frame dup ] [ [ remove-frame ] keep ] produce 2nip ;

: read-v2-header ( seq -- header )
    [ <header> ] dip
    {
        [ [ 3 5 ] dip <slice> >array >>version ]
        [ [ 5 ] dip nth >>flags ]
        [ [ 6 10 ] dip <slice> sequence>synchsafe >>size ]
    } cleave ;

: merge-frames ( id3 assoc -- id3 )
    [ dup frames>> ] dip assoc-union! drop ;

: merge-id3v1 ( id3 -- id3 )
    dup id3v1>frames frames>assoc merge-frames ;

: read-v2-tags ( id3 seq -- id3 )
    10 cut-slice
    [ read-v2-header >>header ]
    [ read-frames frames>assoc merge-frames ] bi* ;

: extract-v1-tags ( id3 seq -- id3 )
    {
        [ 30 head-slice decode-text filter-text-data >>title ]
        [ [ 30 60 ] dip subseq decode-text filter-text-data >>artist ]
        [ [ 60 90 ] dip subseq decode-text filter-text-data >>album ]
        [ [ 90 94 ] dip subseq decode-text filter-text-data >>year ]
        [ [ 94 124 ] dip subseq decode-text filter-text-data >>comment ]
        [ [ 124 ] dip nth number>string >>genre ]
    } cleave ;

: read-v1-tags ( id3 seq -- id3 )
    id3v1-offset tail-slice* 3 tail-slice
    extract-v1-tags ;

: extract-v1+-tags ( id3 seq -- id3 )
    {
        [ 60 head-slice decode-text filter-text-data [ append ] change-title ]
        [
            [ 60 120 ] dip subseq decode-text filter-text-data
            [ append ] change-artist
        ]
        [
            [ 120 180 ] dip subseq decode-text filter-text-data
            [ append ] change-album
        ]
        [ [ 180 ] dip nth >>speed ]
        [ [ 181 211 ] dip subseq decode-text >>genre-name ]
        [ [ 211 217 ] dip subseq decode-text >>start-time ]
        [ [ 217 223 ] dip subseq decode-text >>end-time ]
    } cleave ;

: read-v1+-tags ( id3 seq -- id3 )
    id3v1+-offset tail-slice* 4 tail-slice
    extract-v1+-tags ;

: parse-genre ( string -- n/f )
    dup "(" ?head-slice drop ")" ?tail-slice drop
    string>number dup number? [
        genres ?nth swap or
    ] [
        drop
    ] if ;

PRIVATE>

: mp3>id3 ( path -- id3/f )
    [
        [ <id3> ] dip uchar <mapped-array>
        [ dup id3v1? [ read-v1-tags merge-id3v1 ] [ drop ] if ]
        [ dup id3v1+? [ read-v1+-tags merge-id3v1 ] [ drop ] if ]
        [ dup id3v2? [ read-v2-tags ] [ drop ] if ]
        tri
    ] with-mapped-file-reader ;

: find-id3-frame ( id3 name -- obj/f )
    swap frames>> at* [ data>> ] when ;

: title ( id3 -- string/f ) "TIT2" find-id3-frame ;

: artist ( id3 -- string/f ) "TPE1" find-id3-frame ;

: album ( id3 -- string/f ) "TALB" find-id3-frame ;

: year ( id3 -- string/f ) "TYER" find-id3-frame ;

: comment ( id3 -- string/f ) "COMM" find-id3-frame ;

: genre ( id3 -- string/f )
    "TCON" find-id3-frame parse-genre ;

: find-mp3s ( path -- seq ) ".mp3" find-files-by-extension ;

ERROR: id3-parse-error path error ;

: (mp3-paths>id3s) ( seq -- seq' )
    [ dup [ mp3>id3 ] [ \ id3-parse-error boa ] recover ] map>alist ;

: mp3-paths>id3s ( seq -- seq' )
    (mp3-paths>id3s)
    [ dup second id3-parse-error? [ f over set-second ] when ] map ;

: parse-mp3-directory ( path -- seq )
    find-mp3s mp3-paths>id3s ;
