! Copyright (C) 2006 Adam Langley and Chris Double.
! Adam Langley was the original author of this work.
!
! Chris Double modified it to fix bugs and get it working
! correctly under the latest versions of Factor.
!
! See https://factorcode.org/license.txt for BSD license.
!
USING: accessors arrays assocs byte-arrays classes classes.tuple
combinators endian hashtables io io.encodings.binary
io.encodings.string io.encodings.utf8 io.streams.byte-array
kernel math namespaces prettyprint quotations sequences
sequences.private strings vocabs words ;
IN: serialize

GENERIC: (serialize) ( obj -- )

<PRIVATE

! Variable holding a assoc of objects already serialized
SYMBOL: serialized

: add-object ( obj -- )
    ! Add an object to the sequence of already serialized
    ! objects.
    serialized get [ assoc-size swap ] keep set-at ;

: object-id ( obj -- id )
    ! Return the id of an already serialized object
    serialized get at ;

! Positive numbers are serialized as follows:
! 0 => B{ 0 }
! 1<=x<127 => B{ x | 0x80 }
! 127<=x<2^1024 => B{ length(x) x[0] x[1] ... }; 1<length(x)<129 fits in 1 byte
! 2^1024<=x => B{ 0xff } + serialize(length(x)) + B{ x[0] x[1] ... }
! The last case is needed because a very large number would
! otherwise be confused with a small number.
: serialize-cell ( n -- )
    [ 0 write1 ] [
        dup 0x7f < [
            0x80 bitor write1
        ] [
            dup log2 8 /i 1 +
            dup 0x80 > [
                0xff write1
                dup serialize-cell
            ] [
                dup write1
            ] if
            >be write
        ] if
    ] if-zero ;

: deserialize-cell ( -- n )
    read1 {
        { [ dup 0xff = ] [ drop deserialize-cell read be> ] }
        { [ dup 0x80 > ] [ 0x80 bitxor ] }
        [ read be> ]
    } cond ;

: serialize-shared ( obj quot -- )
    [
        dup object-id
        [ CHAR: o write1 serialize-cell drop ]
    ] dip if* ; inline

M: f (serialize)
    drop CHAR: n write1 ;

M: integer (serialize)
    [
        CHAR: z write1
    ] [
        dup 0 < [ neg CHAR: m ] [ CHAR: p ] if write1
        serialize-cell
    ] if-zero ;

M: float (serialize)
    CHAR: F write1
    double>bits serialize-cell ;

: serialize-seq ( obj code -- )
    [
        write1
        [ add-object ]
        [ length serialize-cell ]
        [ [ (serialize) ] each ] tri
    ] curry serialize-shared ;

M: tuple (serialize)
    [
        CHAR: T write1
        [ class-of (serialize) ]
        [ add-object ]
        [ tuple-slots (serialize) ]
        tri
    ] serialize-shared ;

M: array (serialize)
    CHAR: a serialize-seq ;

M: quotation (serialize)
    [
        CHAR: q write1
        [ >array (serialize) ] [ add-object ] bi
    ] serialize-shared ;

M: hashtable (serialize)
    [
        CHAR: h write1
        [ add-object ] [ >alist (serialize) ] bi
    ] serialize-shared ;

M: byte-array (serialize)
    [
        CHAR: A write1
        [ add-object ]
        [ length serialize-cell ]
        [ write ] tri
    ] serialize-shared ;

M: string (serialize)
    [
        CHAR: s write1
        [ add-object ]
        [
            utf8 encode
            [ length serialize-cell ]
            [ write ] bi
        ] bi
    ] serialize-shared ;

: serialize-true ( word -- )
    drop CHAR: t write1 ;

: serialize-gensym ( word -- )
    [
        CHAR: G write1
        [ add-object ]
        [ def>> (serialize) ]
        [ props>> (serialize) ]
        tri
    ] serialize-shared ;

: serialize-word ( word -- )
    CHAR: w write1
    [ name>> (serialize) ]
    [ vocabulary>> (serialize) ]
    bi ;

M: word (serialize)
    {
        { [ dup t eq? ] [ serialize-true ] }
        { [ dup vocabulary>> not ] [ serialize-gensym ] }
        [ serialize-word ]
    } cond ;

M: wrapper (serialize)
    CHAR: W write1
    wrapped>> (serialize) ;

DEFER: (deserialize)

SYMBOL: deserialized

: intern-object ( obj -- )
    deserialized get push ;

: deserialize-false ( -- f )
    f ;

: deserialize-true ( -- f )
    t ;

: deserialize-positive-integer ( -- number )
    deserialize-cell ;

: deserialize-negative-integer ( -- number )
    deserialize-positive-integer neg ;

: deserialize-zero ( -- number )
    0 ;

: deserialize-float ( -- float )
    deserialize-cell bits>double ;

: (deserialize-string) ( -- string )
    deserialize-cell read utf8 decode ;

: deserialize-string ( -- string )
    (deserialize-string) dup intern-object ;

: deserialize-word ( -- word )
    (deserialize) (deserialize)
    2dup [ require ] keep lookup-word [ 2nip ] [
        2array unparse "Unknown word: " prepend throw
    ] if* ;

: deserialize-gensym ( -- word )
    gensym
    [ intern-object ]
    [ (deserialize) define ]
    [ (deserialize) >>props ]
    tri ;

: deserialize-wrapper ( -- wrapper )
    (deserialize) <wrapper> ;

:: (deserialize-seq) ( exemplar quot -- seq )
    deserialize-cell exemplar new-sequence
    [ intern-object ]
    [ [ drop quot call ] map! ] bi ; inline

: deserialize-array ( -- array )
    { } [ (deserialize) ] (deserialize-seq) ;

: deserialize-quotation ( -- array )
    (deserialize) >quotation dup intern-object ;

: deserialize-byte-array ( -- byte-array )
    B{ } [ read1 ] (deserialize-seq) ;

: deserialize-hashtable ( -- hashtable )
    H{ } clone
    [ intern-object ]
    [ (deserialize) assoc-union! ]
    bi ;

: copy-seq-to-tuple ( seq tuple -- )
    [ set-array-nth ] curry each-index ;

: deserialize-tuple ( -- array )
    ! Ugly because we have to intern the tuple before reading
    ! slots
    (deserialize) new
    [ intern-object ]
    [
        [ (deserialize) ]
        [ [ copy-seq-to-tuple ] keep ] bi*
    ] bi ;

: deserialize-unknown ( -- object )
    deserialize-cell deserialized get nth ;

: deserialize* ( -- object ? )
    read1 [
        {
            { CHAR: A [ deserialize-byte-array ] }
            { CHAR: F [ deserialize-float ] }
            { CHAR: T [ deserialize-tuple ] }
            { CHAR: W [ deserialize-wrapper ] }
            { CHAR: a [ deserialize-array ] }
            { CHAR: h [ deserialize-hashtable ] }
            { CHAR: m [ deserialize-negative-integer ] }
            { CHAR: n [ deserialize-false ] }
            { CHAR: t [ deserialize-true ] }
            { CHAR: o [ deserialize-unknown ] }
            { CHAR: p [ deserialize-positive-integer ] }
            { CHAR: q [ deserialize-quotation ] }
            { CHAR: s [ deserialize-string ] }
            { CHAR: w [ deserialize-word ] }
            { CHAR: G [ deserialize-word ] }
            { CHAR: z [ deserialize-zero ] }
        } case t
    ] [
        f f
    ] if* ;

: (deserialize) ( -- obj )
    deserialize* [ "End of stream" throw ] unless ;

PRIVATE>

: deserialize ( -- obj )
    V{ } clone deserialized [ (deserialize) ] with-variable ;

: serialize ( obj -- )
    IH{ } clone serialized [ (serialize) ] with-variable ;

: bytes>object ( bytes -- obj )
    binary [ deserialize ] with-byte-reader ;

: object>bytes ( obj -- bytes )
    binary [ serialize ] with-byte-writer ;
