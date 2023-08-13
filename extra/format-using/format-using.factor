! Copyright (C) 2023 Alexander Ilin.
! See https://factorcode.org/license.txt for BSD license.
USING:
    arrays kernel make math namespaces prettyprint.config sequences
    sorting splitting.monotonic strings
;
IN: format-using

: indent-length ( -- str ) tab-size get ;
: indent ( -- str ) indent-length CHAR: space <string> ; inline
: width-limit ( -- n ) margin get ; inline
: too-long? ( n -- ? ) width-limit > ; inline

: subsystem ( str -- str' )
    dup [ CHAR: . = ] find [ head ] [ drop ] if ;

: subsystem-clusters ( seq -- seq' )
    [ [ subsystem ] same? ] monotonic-split ;

: joined-length ( seq -- n )
    [ length ] keep [ length ] map-sum + ;

: costs ( vocabs -- length-on-new-line length-when-added-to-prev-line )
    joined-length [ indent-length + 1 - ] keep ;

: sum-too-long? ( cost1 cost2 -- ? )
    [ first ] [ second ] bi* + too-long? ;

: cost+ ( cost1 cost2 -- total-cost )
    [ first3 ] bi@ roll prepend [ 2nip + dup 3 - ] dip 3array ;

: cluster? ( cost -- ? )
    last length 1 > ; inline

: split-subsystem% ( vocabs -- )
    [ indent-length 1 - f ] dip [
        pick over length + 1 + dup too-long? [
            drop [ dupd 3array , ] dip [ length indent-length + ] keep 1array
        ] [ -rot suffix nipd ] if
    ] each dupd 3array , ;

: split-long-subsystems ( costs -- costs' )
    [
        [ dup first too-long? [ last split-subsystem% ] [ , ] if ] each
    ] { } make ;

: group-subsystems ( seq -- seq' )
    subsystem-clusters [ [ costs ] keep 3array ] map [
        { 0 0 f } [
            dup cluster? [ [ , ] bi@ { 0 0 f } ] [
                2dup sum-too-long? [ swap , ] [ cost+ ] if
            ] if
        ] reduce ,
    ] { } make [ first zero? ] reject
    split-long-subsystems [ last " " join indent prepend ] map ;

: oneliner-length ( vocabs -- n )
    joined-length "USING: ;" length + ;

: format-using ( vocabs -- str )
    dup length 1 = [ first "USE: " prepend ] [
        sort dup oneliner-length too-long? [ group-subsystems "\n" ] [ " " ] if
        [ { "USING:" } { ";" } surround ] dip join
    ] if ;
