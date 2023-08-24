! Copyright (C) 2014 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays calendar calendar.parser
io.encodings.utf8 io.files io.streams.string kernel math
math.parser sequences splitting ascii ;
IN: subrip-subtitles

! https://en.wikipedia.org/wiki/SubRip
! .srt

TUPLE: srt-chunk id begin-time end-time rect text ;

: read-srt-timestamp ( -- duration )
    instant
    read-00 >>hour ":" expect
    read-00 >>minute ":" expect
    read-00 "," expect
    read-000 1000 /f + >>second ;

: parse-srt-timestamp ( string -- duration )
    [ read-srt-timestamp ] with-string-reader ;

: parse-srt-chunk ( seq -- srt-chunk )
    [ ?first string>number ]
    [
        ?second "  " split1
        [ "-->" split1 [ [ ascii:blank? ] trim parse-srt-timestamp ] bi@ ]
        [
            [ ascii:blank? ] trim split-words sift [
                f
            ] [
                [ ":" split1 nip string>number ] map
                first4 swapd [ 2array ] 2dip 2array 2array
            ] if-empty
        ] bi*
    ]
    [ 2 tail join-lines ] tri srt-chunk boa ;

: parse-srt-lines ( seq -- seq' )
    { "" } split harvest
    [ parse-srt-chunk ] { } map-as ;

: parse-srt-string ( seq -- seq' )
    split-lines parse-srt-lines ;

: parse-srt-file ( path -- seq )
    utf8 file-lines parse-srt-lines ;
