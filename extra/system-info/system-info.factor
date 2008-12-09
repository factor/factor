! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.syntax kernel math prettyprint io math.parser
combinators vocabs.loader system-info.backend system ;
IN: system-info

: write-unit ( x n str -- )
    [ 2^ /f number>string write bl ] [ write ] bi* ;

: kb ( x -- ) 10 "kB" write-unit ;
: megs ( x -- ) 20 "MB" write-unit ;
: gigs ( x -- ) 30 "GB" write-unit ;
: ghz ( x -- ) 1000000000 /f number>string write bl "GHz" write ;

<< {
    { [ os windows? ] [ "system-info.windows" ] }
    { [ os linux? ] [ "system-info.linux" ] }
    { [ os macosx? ] [ "system-info.macosx" ] }
    [ f ]
} cond [ require ] when* >>

: system-report. ( -- )
    "CPUs: " write cpus number>string write nl
    "CPU Speed: " write cpu-mhz ghz nl
    "Physical RAM: " write physical-mem megs nl ;
