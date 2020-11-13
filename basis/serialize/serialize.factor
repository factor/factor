! Copyright (C) 2006 Adam Langley and Chris Double.
! Adam Langley was the original author of this work.
!
! Chris Double modified it to fix bugs and get it working
! correctly under the latest versions of Factor.
!
! See http://factorcode.org/license.txt for BSD license.
!
USING: accessors arrays assocs byte-arrays classes classes.tuple
combinators hashtables hashtables.identity io io.binary
io.encodings.binary io.encodings.string io.encodings.utf8
io.streams.byte-array kernel locals math namespaces prettyprint
quotations sequences sequences.private strings vocabs words ;
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
        [ char: o write1 serialize-cell drop ]
    ] dip if* ; inline

M: f (serialize) ( obj -- )
    drop char: n write1 ;

M: integer (serialize)
    [
        char: z write1
    ] [
        dup 0 < [ neg char: m ] [ char: p ] if write1
        serialize-cell
    ] if-zero ;

M: float (serialize) ( obj -- )
    char: F write1
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
        char: T write1
        [ class-of (serialize) ]
        [ add-object ]
        [ tuple-slots (serialize) ]
        tri
    ] serialize-shared ;

M: array (serialize) ( obj -- )
    char: a serialize-seq ;

M: quotation (serialize)
    [
        char: q write1
        [ >array (serialize) ] [ add-object ] bi
    ] serialize-shared ;

M: hashtable (serialize)
    [
        char: h write1
        [ add-object ] [ >alist (serialize) ] bi
    ] serialize-shared ;

M: byte-array (serialize)
    [
        char: A write1
        [ add-object ]
        [ length serialize-cell ]
        [ write ] tri
    ] serialize-shared ;

M: string (serialize)
    [
        char: s write1
        [ add-object ]
        [
            utf8 encode
            [ length serialize-cell ]
            [ write ] bi
        ] bi
    ] serialize-shared ;

: serialize-true ( word -- )
    drop char: t write1 ;

: serialize-gensym ( word -- )
    [
        char: G write1
        [ add-object ]
        [ def>> (serialize) ]
        [ props>> (serialize) ]
        tri
    ] serialize-shared ;

: serialize-word ( word -- )
    char: w write1
    [ name>> (serialize) ]
    [ vocabulary>> (serialize) ]
    bi ;

M: word (serialize)
    {
        { [ dup t eq? ] [ serialize-true ] }
        { [ dup vocabulary>> not ] [ serialize-gensym ] }
        [ serialize-word ]
    } cond ;

M: wrapper (serialize) ( obj -- )
    char: W write1
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
            { char: A [ deserialize-byte-array ] }
            { char: F [ deserialize-float ] }
            { char: T [ deserialize-tuple ] }
            { char: W [ deserialize-wrapper ] }
            { char: a [ deserialize-array ] }
            { char: h [ deserialize-hashtable ] }
            { char: m [ deserialize-negative-integer ] }
            { char: n [ deserialize-false ] }
            { char: t [ deserialize-true ] }
            { char: o [ deserialize-unknown ] }
            { char: p [ deserialize-positive-integer ] }
            { char: q [ deserialize-quotation ] }
            { char: s [ deserialize-string ] }
            { char: w [ deserialize-word ] }
            { char: G [ deserialize-word ] }
            { char: z [ deserialize-zero ] }
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
