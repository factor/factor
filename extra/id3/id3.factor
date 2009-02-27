! Copyright (C) 2009 Tim Wawrzynczak, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: sequences io io.encodings.binary io.files io.pathnames
strings kernel math io.mmap io.mmap.uchar accessors syntax
combinators math.ranges unicode.categories byte-arrays
io.encodings.string io.encodings.utf8 assocs math.parser
combinators.short-circuit fry namespaces multiline
combinators.smart splitting ;
IN: id3

<PRIVATE

CONSTANT: genres
    {
        "Blues" 
        "Classic Rock" 
        "Country" 
        "Dance" 
        "Disco" 
        "Funk" 
        "Grunge" 
        "Hip-Hop" 
        "Jazz" 
        "Metal" 
        "New Age" 
        "Oldies" 
        "Other" 
        "Pop" 
        "R&B" 
        "Rap" 
        "Reggae" 
        "Rock" 
        "Techno" 
        "Industrial" 
        "Alternative" 
        "Ska" 
        "Death Metal" 
        "Pranks" 
        "Soundtrack" 
        "Euro-Techno" 
        "Ambient" 
        "Trip-Hop" 
        "Vocal" 
        "Jazz+Funk" 
        "Fusion" 
        "Trance" 
        "Classical" 
        "Instrumental" 
        "Acid" 
        "House" 
        "Game" 
        "Sound Clip" 
        "Gospel" 
        "Noise" 
        "AlternRock" 
        "Bass" 
        "Soul" 
        "Punk" 
        "Space" 
        "Meditative" 
        "Instrumental Pop" 
        "Instrumental Rock" 
        "Ethnic" 
        "Gothic" 
        "Darkwave" 
        "Techno-Industrial" 
        "Electronic" 
        "Pop-Folk" 
        "Eurodance" 
        "Dream" 
        "Southern Rock" 
        "Comedy" 
        "Cult" 
        "Gangsta" 
        "Top 40" 
        "Christian Rap" 
        "Pop/Funk" 
        "Jungle" 
        "Native American" 
        "Cabaret" 
        "New Wave" 
        "Psychedelic" 
        "Rave" 
        "Showtunes" 
        "Trailer" 
        "Lo-Fi" 
        "Tribal" 
        "Acid Punk" 
        "Acid Jazz" 
        "Polka" 
        "Retro" 
        "Musical" 
        "Rock & Roll" 
        "Hard Rock" 
        "Folk" 
        "Folk-Rock" 
        "National Folk" 
        "Swing" 
        "Fast Fusion" 
        "Bebop" 
        "Latin" 
        "Revival" 
        "Celtic" 
        "Bluegrass" 
        "Avantgarde" 
        "Gothic Rock" 
        "Progressive Rock" 
        "Psychedelic Rock" 
        "Symphonic Rock" 
        "Slow Rock" 
        "Big Band" 
        "Chorus" 
        "Easy Listening" 
        "Acoustic" 
        "Humour" 
        "Speech" 
        "Chanson" 
        "Opera" 
        "Chamber Music" 
        "Sonata" 
        "Symphony" 
        "Booty Bass" 
        "Primus" 
        "Porn Groove" 
        "Satire" 
        "Slow Jam" 
        "Club" 
        "Tango" 
        "Samba" 
        "Folklore" 
        "Ballad" 
        "Power Ballad" 
        "Rhythmic Soul" 
        "Freestyle" 
        "Duet" 
        "Punk Rock" 
        "Drum Solo" 
        "A capella" 
        "Euro-House"
        "Dance Hall"
    }

TUPLE: header version flags size ;

TUPLE: frame frame-id flags size data ;

TUPLE: id3v2-info header frames ;

TUPLE: id3-info title artist album year comment genre ;

: <id3-info> ( -- object ) id3-info new ;

: <id3v2-info> ( header frames -- object )
    [ [ frame-id>> ] keep ] H{ } map>assoc
    id3v2-info boa ;

: <header> ( -- object ) header new ;

: <frame> ( -- object ) frame new ;

: id3v2? ( mmap -- ? ) "ID3" head? ; inline

: id3v1? ( mmap -- ? )
    { [ length 128 >= ] [ 128 tail-slice* "TAG" head? ] } 1&& ; inline

: id3v1-frame ( string key -- frame )
    <frame>
        swap >>frame-id
        swap >>data ;

: id3v1>id3v2 ( id3v1 -- id3v2 )
    [
        {
            [ title>> "TIT2" id3v1-frame ]
            [ artist>> "TPE1" id3v1-frame ]
            [ album>> "TALB" id3v1-frame ]
            [ year>> "TYER" id3v1-frame ]
            [ comment>> "COMM" id3v1-frame ]
            [ genre>> "TCON" id3v1-frame ]
        } cleave
    ] output>array f swap <id3v2-info> ;

: >28bitword ( seq -- int )
    0 [ [ 7 shift ] dip bitor ] reduce ; inline

: filter-text-data ( data -- filtered )
    [ printable? ] filter ; inline

! frame details stuff

: valid-frame-id? ( id -- ? )
    [ { [ digit? ] [ LETTER? ] } 1|| ] all? ; inline

: read-frame-id ( mmap -- id )
    4 head-slice ; inline

: read-frame-size ( mmap -- size )
    [ 4 8 ] dip subseq ; inline

: read-frame-flags ( mmap -- flags )
    [ 8 10 ] dip subseq ; inline

: read-frame-data ( frame mmap -- frame data )
    [ 10 over size>> 10 + ] dip <slice> filter-text-data ; inline

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
    dup read-frame-id valid-frame-id?
    [ (read-frame) ] [ drop f ] if ;

: remove-frame ( mmap frame -- mmap )
    size>> 10 + tail-slice ; inline

: read-frames ( mmap -- frames )
    [ dup read-frame dup ]
    [ [ remove-frame ] keep ]
    [ drop ] produce nip ;
    
! header stuff

: read-header-supported-version? ( mmap -- ? )
    3 tail-slice first { 3 4 } member? ; inline

: read-header-flags ( mmap -- flags ) 5 swap nth ; inline

: read-header-size ( mmap -- size )
    [ 6 10 ] dip <slice> >28bitword ; inline

: read-v2-header ( mmap -- id3header )
    [ <header> ] dip
    {
        [ read-header-supported-version? >>version ]
        [ read-header-flags >>flags ]
        [ read-header-size >>size ]
    } cleave ; inline

: drop-header ( mmap -- seq1 seq2 )
    [ 10 tail-slice ] [ ] bi ; inline

: read-v2-tag-data ( seq -- id3v2-info )
    drop-header read-v2-header
    swap read-frames <id3v2-info> ; inline
    
! v1 information

: skip-to-v1-data ( seq -- seq ) 125 tail-slice* ; inline

: read-title ( seq -- title ) 30 head-slice ; inline

: read-artist ( seq -- title ) [ 30 60 ] dip subseq ; inline

: read-album ( seq -- album ) [ 60 90 ] dip subseq ; inline

: read-year ( seq -- year ) [ 90 94 ] dip subseq ; inline

: read-comment ( seq -- comment ) [ 94 124 ] dip subseq ; inline

: read-genre ( seq -- genre ) [ 124 ] dip nth ; inline

: (read-v1-tag-data) ( seq -- mp3-file )
    [ <id3-info> ] dip
    {
        [ read-title   utf8 decode  filter-text-data >>title   ]
        [ read-artist  utf8 decode  filter-text-data >>artist  ]
        [ read-album   utf8 decode  filter-text-data >>album   ]
        [ read-year    utf8 decode  filter-text-data >>year    ]
        [ read-comment utf8 decode  filter-text-data >>comment ]
        [ read-genre   number>string                 >>genre   ]
    } cleave ; inline

: read-v1-tag-data ( seq -- mp3-file )
    skip-to-v1-data (read-v1-tag-data) ; inline

: parse-genre ( string -- n/f )
    dup "(" ?head-slice drop ")" ?tail-slice drop
    string>number dup number? [
        genres ?nth swap or
    ] [
        drop
    ] if ; inline

PRIVATE>

: frame-named ( id3 name quot -- obj )
    [ swap frames>> at* ] dip
    [ data>> ] prepose [ drop f ] if ; inline

: id3-title ( id3 -- title/f ) "TIT2" [ ] frame-named ; inline

: id3-artist ( id3 -- artist/f ) "TPE1" [ ] frame-named ; inline

: id3-album ( id3 -- album/f ) "TALB" [ ] frame-named ; inline

: id3-year ( id3 -- year/f ) "TYER" [ ] frame-named ; inline

: id3-comment ( id3 -- comment/f ) "COMM" [ ] frame-named ; inline

: id3-genre ( id3 -- genre/f )
    "TCON" [ parse-genre ] frame-named ; inline

: id3-frame ( id3 key -- value/f ) [ ] frame-named ; inline

: file-id3-tags ( path -- id3v2-info/f )
    [
        {
            { [ dup id3v2? ] [ read-v2-tag-data ] }
            { [ dup id3v1? ] [ read-v1-tag-data id3v1>id3v2 ] }
            [ drop f ]
        } cond
    ] with-mapped-uchar-file ;
