! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs sequences sorting binary-search math
math.order arrays combinators kernel ;
IN: cords

<PRIVATE

TUPLE: simple-cord
    { first read-only } { second read-only } ;

M: simple-cord length
    [ first>> length ] [ second>> length ] bi + ; inline

M: simple-cord virtual-seq first>> ; inline

M: simple-cord virtual@
    2dup first>> length <
    [ first>> ] [ [ first>> length - ] [ second>> ] bi ] if ; inline

TUPLE: multi-cord
    { count read-only } { seqs read-only } ;

M: multi-cord length count>> ; inline

M: multi-cord virtual@
    dupd
    seqs>> [ first <=> ] with search nip
    [ first - ] [ second ] bi ; inline

M: multi-cord virtual-seq
    seqs>> [ f ] [ first second ] if-empty ; inline

: <cord> ( seqs -- cord )
    dup length 2 = [
        first2 simple-cord boa
    ] [
        [ 0 [ length + ] accumulate ] keep zip multi-cord boa
    ] if ; inline

PRIVATE>

UNION: cord simple-cord multi-cord ;

INSTANCE: cord virtual-sequence

INSTANCE: multi-cord virtual-sequence

: cord-append ( seq1 seq2 -- cord )
    {
        { [ over empty? ] [ nip ] }
        { [ dup empty? ] [ drop ] }
        { [ 2dup [ cord? ] both? ] [ [ seqs>> values ] bi@ append <cord> ] }
        { [ over cord? ] [ [ seqs>> values ] dip suffix <cord> ] }
        { [ dup cord? ] [ seqs>> values swap prefix <cord> ] }
        [ 2array <cord> ]
    } cond ; inline

: cord-concat ( seqs -- cord )
    {
        { [ dup empty? ] [ drop f ] }
        { [ dup length 1 = ] [ first ] }
        [
            [
                {
                    { [ dup cord? ] [ seqs>> values ] }
                    { [ dup empty? ] [ drop { } ] }
                    [ 1array ]
                } cond
            ] map concat <cord>
        ]
    } cond ; inline
