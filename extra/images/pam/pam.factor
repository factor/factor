! Copyright (C) 2009 Keith Lazuka.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators fry grouping images
images.loader io io.encodings io.encodings.ascii
io.encodings.binary io.files io.files.temp kernel math
math.parser prettyprint sequences splitting ;
IN: images.pam

SINGLETON: pam-image
"pam" pam-image register-image-class

: output-pam-header ( note num-channels width height -- )
    ascii [
        "P7" print
        "HEIGHT " write pprint nl
        "WIDTH " write pprint nl
        "MAXVAL 255" print
        "DEPTH " write pprint nl
        "TUPLTYPE " prepend print
        "ENDHDR" print
    ] with-encoded-output ; inline

: output-pam ( note num-channels width height pixels -- )
    [ output-pam-header ] dip write ;

: verify-bitmap-format ( image -- )
    [ component-type>> ubyte-components assert= ]
    [ component-order>> { RGB RGBA } memq? [
        "PAM encode: component-order must be RGB or RGBA!" throw
    ] unless ] bi ;

GENERIC: TUPLTYPE ( component-order -- str )
M: component-order TUPLTYPE name>> ;
M: RGBA TUPLTYPE drop "RGB_ALPHA" ;

M: pam-image image>stream
    drop {
        [ verify-bitmap-format ]
        [ component-order>> [ TUPLTYPE ] [ component-count ] bi ]
        [ dim>> first2 ]
        [ bitmap>> ]
    } cleave output-pam ;

! PAM Decoder

TUPLE: loading-pam width height depth maxval tupltype bitmap ;

: ?glue ( seq1 seq2 seq3 -- seq )
    pick empty? [ drop nip ] [ glue ] if ;

: append-tupltype ( pam tupltype -- pam )
    '[ _ " " ?glue ] change-tupltype ;

: read-header-lines ( pam -- pam )
    readln " " split unclip swap " " join swap {
        { "ENDHDR" [ drop ] }
        { "HEIGHT" [ string>number >>height read-header-lines ] }
        { "WIDTH" [ string>number >>width read-header-lines ] }
        { "DEPTH" [ string>number >>depth read-header-lines ] }
        { "MAXVAL" [ string>number >>maxval read-header-lines ] }
        { "TUPLTYPE" [ append-tupltype read-header-lines ] }
        [ 2drop read-header-lines ]
    } case ;

: read-header ( pam -- pam )
    ascii [
        readln "P7" assert=
        read-header-lines
    ] with-decoded-input ;

: bytes-per-pixel ( pam -- n )
    [ depth>> ] [ maxval>> 256 < 1 2 ? ] bi * ;

: bitmap-length ( pam -- num-bytes )
    [ width>> ] [ height>> ] [ bytes-per-pixel ] tri * * ;

: read-bitmap ( pam -- pam )
    dup bitmap-length read >>bitmap ;

: load-pam ( stream -- pam )
    [ loading-pam new read-header read-bitmap ] with-input-stream ;

: tupltype>component-order ( pam -- component-order )
    tupltype>> dup {
        { "RGB_ALPHA" [ drop RGBA ] }
        { "RGBA" [ drop RGBA ] }
        { "RGB" [ drop RGB ] }
        [ "Cannot determine component-order from TUPLTYPE " prepend throw ]
    } case ;

: pam>image ( pam -- image )
    [ <image> ] dip {
        [ [ width>> ] [ height>> ] bi 2array >>dim ]
        [ tupltype>component-order >>component-order ]
        [ drop ubyte-components >>component-type ]
        [ bitmap>> >>bitmap ]
    } cleave ;

M: pam-image stream>image drop load-pam pam>image ;
