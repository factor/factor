! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators io kernel locals math multiline
sequences splitting ;
IN: mime.multipart

TUPLE: multipart-stream stream n leftover separator ;

: <multipart-stream> ( stream separator -- multipart-stream )
    multipart-stream new
        swap >>separator
        swap >>stream
        16 2^ >>n ;

<PRIVATE

: ?append ( seq1 seq2 -- newseq/seq2 )
    over [ append ] [ nip ] if ;

: ?cut* ( seq n -- before after )
    over length over <= [ drop f swap ] [ cut* ] if ;
    
: read-n ( stream -- bytes end-stream? )
    [ f ] change-leftover
    [ n>> ] [ stream>> ] bi stream-read [ ?append ] keep not ;

: multipart-split ( bytes separator -- before after seq=? )
    2dup sequence= [ 2drop f f t ] [ split1 f ] if ;

PRIVATE>

:: multipart-step ( stream bytes end-stream? separator quot: ( bytes -- ) -- ? end-stream? )
    #! return t to loop again
    bytes separator multipart-split [ dup >boolean ] dip [
        ! separator == input
        3drop f quot call f
    ] [
        [
            ! found
            [ quot unless-empty ]
            [
                stream (>>leftover)
                quot unless-empty
            ] if-empty f quot call f
        ] [
            ! not found
            drop
            end-stream? [
                quot unless-empty f
            ] [
                separator length 1- ?cut* stream (>>leftover)
                quot unless-empty t
            ] if
        ] if
    ] if stream leftover>> end-stream? not or ;

:: multipart-step-loop ( stream quot1: ( bytes -- ) quot2: ( -- ) -- ? )
    stream dup [ read-n ] [ separator>> ] bi quot1 multipart-step
    swap [ drop stream quot1 quot2 multipart-step-loop ] quot2 if ;

: multipart-loop-all ( stream quot1: ( bytes -- ) quot2: ( -- ) -- )
    3dup multipart-step-loop [ multipart-loop-all ] [ 3drop ] if ;
