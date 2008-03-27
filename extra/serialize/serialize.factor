! Copyright (C) 2006 Adam Langley and Chris Double.
! Adam Langley was the original author of this work.
!
! Chris Double modified it to fix bugs and get it working
! correctly under the latest versions of Factor.
!
! See http://factorcode.org/license.txt for BSD license.
!
USING: namespaces sequences kernel math io math.functions
io.binary strings classes words sbufs tuples arrays vectors
byte-arrays bit-arrays quotations hashtables assocs help.syntax
help.markup float-arrays splitting io.streams.byte-array
io.encodings.string io.encodings.utf8 io.encodings.binary
combinators combinators.cleave accessors locals
prettyprint compiler.units sequences.private tuples.private ;
IN: serialize

! Variable holding a assoc of objects already serialized
SYMBOL: serialized

TUPLE: id obj ;

C: <id> id

M: id hashcode* obj>> hashcode* ;

M: id equal? over id? [ [ obj>> ] 2apply eq? ] [ 2drop f ] if ;

: add-object ( obj -- )
    #! Add an object to the sequence of already serialized
    #! objects.
    serialized get [ assoc-size swap <id> ] keep set-at ;

: object-id ( obj -- id )
    #! Return the id of an already serialized object 
    <id> serialized get at ;

! Serialize object
GENERIC: (serialize) ( obj -- )

! Numbers are serialized as follows:
! 0 => B{ 0 }
! 1<=x<=126 => B{ x | 0x80 }
! x>127 => B{ length(x) x[0] x[1] ... }
! x>2^1024 => B{ 0xff length(x) x[0] x[1] ... }
! The last case is needed because a very large number would
! otherwise be confused with a small number.
: serialize-cell ( n -- )
    dup zero? [ drop 0 write1 ] [
        dup HEX: 7e <= [
            HEX: 80 bitor write1
        ] [
            dup log2 8 /i 1+ 
            dup HEX: 7f >= [
                HEX: ff write1
                dup serialize-cell
            ] [
                dup write1
            ] if
            >be write
        ] if
    ] if ;

: deserialize-cell ( -- n )
    read1 {
        { [ dup HEX: ff = ] [ drop deserialize-cell read be> ] }
        { [ dup HEX: 80 >= ] [ HEX: 80 bitxor ] }
        { [ t ] [ read be> ] }
    } cond ;

: serialize-shared ( obj quot -- )
    >r dup object-id
    [ CHAR: o write1 serialize-cell drop ]
    r> if* ; inline

M: f (serialize) ( obj -- )
    drop CHAR: n write1 ;

M: integer (serialize) ( obj -- )
    dup zero? [
        drop CHAR: z write1
    ] [
        dup 0 < [ neg CHAR: m ] [ CHAR: p ] if write1
        serialize-cell
    ] if ;

M: float (serialize) ( obj -- )
    CHAR: F write1
    double>bits serialize-cell ;

M: complex (serialize) ( obj -- )
    CHAR: c write1
    dup real-part (serialize)
    imaginary-part (serialize) ;

M: ratio (serialize) ( obj -- )
    CHAR: r write1
    dup numerator (serialize)
    denominator (serialize) ;

: serialize-seq ( obj code -- )
    [
        write1
        [ add-object ]
        [ length serialize-cell ]
        [ [ (serialize) ] each ] tri
    ] curry serialize-shared ;

M: tuple (serialize) ( obj -- )
    [
        CHAR: T write1
        [ class (serialize) ]
        [ add-object ]
        [ tuple>array 1 tail (serialize) ]
        tri
    ] serialize-shared ;

M: array (serialize) ( obj -- )
    CHAR: a serialize-seq ;

M: quotation (serialize) ( obj -- )
    [
        CHAR: q write1 [ >array (serialize) ] [ add-object ] bi
    ] serialize-shared ;

M: hashtable (serialize) ( obj -- )
    [
        CHAR: h write1
        [ add-object ] [ >alist (serialize) ] bi
    ] serialize-shared ;

M: bit-array (serialize) ( obj -- )
    CHAR: b serialize-seq ;

M: byte-array (serialize) ( obj -- )
    [
        CHAR: A write1
        [ add-object ]
        [ length serialize-cell ]
        [ write ] tri
    ] serialize-shared ;

M: float-array (serialize) ( obj -- )
    [
        CHAR: f write1
        [ add-object ]
        [ length serialize-cell ]
        [ [ double>bits 8 >be write ] each ]
        tri
    ] serialize-shared ;

M: string (serialize) ( obj -- )
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
        [ word-def (serialize) ]
        [ word-props (serialize) ]
        tri
    ] serialize-shared ;

: serialize-word ( word -- )
    CHAR: w write1
    [ word-name (serialize) ]
    [ word-vocabulary (serialize) ]
    bi ;

M: word (serialize) ( obj -- )
    {
        { [ dup t eq? ] [ serialize-true ] }
        { [ dup word-vocabulary not ] [ serialize-gensym ] }
        { [ t ] [ serialize-word ] }
    } cond ;

M: wrapper (serialize) ( obj -- )
    CHAR: W write1
    wrapped (serialize) ;

DEFER: (deserialize) ( -- obj )

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

: deserialize-ratio ( -- ratio )
    (deserialize) (deserialize) / ;

: deserialize-complex ( -- complex )
    (deserialize) (deserialize) rect> ;

: (deserialize-string) ( -- string )
    deserialize-cell read utf8 decode ;

: deserialize-string ( -- string )
    (deserialize-string) dup intern-object ;

: deserialize-word ( -- word )
    (deserialize) (deserialize) 2dup lookup
    dup [ 2nip ] [
        "Unknown word: " -rot
        2array unparse append throw
    ] if ;

: deserialize-gensym ( -- word )
    gensym
    dup intern-object
    dup (deserialize) define
    dup (deserialize) swap set-word-props ;

: deserialize-wrapper ( -- wrapper )
    (deserialize) <wrapper> ;

:: (deserialize-seq) ( exemplar quot -- seq )
    deserialize-cell exemplar new
    [ intern-object ]
    [ dup [ drop quot call ] change-each ] bi ; inline

: deserialize-array ( -- array )
    { } [ (deserialize) ] (deserialize-seq) ;

: deserialize-quotation ( -- array )
    (deserialize) >quotation dup intern-object ;

: deserialize-byte-array ( -- byte-array )
    B{ } [ read1 ] (deserialize-seq) ;

: deserialize-bit-array ( -- bit-array )
    ?{ } [ (deserialize) ] (deserialize-seq) ;

: deserialize-float-array ( -- float-array )
    F{ } [ 8 read be> bits>double ] (deserialize-seq) ;

: deserialize-hashtable ( -- hashtable )
    H{ } clone
    [ intern-object ]
    [ (deserialize) update ]
    [ ] tri ;

: copy-seq-to-tuple ( seq tuple -- )
    >r dup length r> [ set-array-nth ] curry 2each ;

: deserialize-tuple ( -- array )
    #! Ugly because we have to intern the tuple before reading
    #! slots
    (deserialize) construct-empty
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
            { CHAR: b [ deserialize-bit-array ] }
            { CHAR: c [ deserialize-complex ] }
            { CHAR: f [ deserialize-float-array ] }
            { CHAR: h [ deserialize-hashtable ] }
            { CHAR: m [ deserialize-negative-integer ] }
            { CHAR: n [ deserialize-false ] }
            { CHAR: t [ deserialize-true ] }
            { CHAR: o [ deserialize-unknown ] }
            { CHAR: p [ deserialize-positive-integer ] }
            { CHAR: q [ deserialize-quotation ] }
            { CHAR: r [ deserialize-ratio ] }
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

: deserialize ( -- obj )
    ! [
    V{ } clone deserialized
    [ (deserialize) ] with-variable ;
    ! ] with-compilation-unit ;

: serialize ( obj -- )
    H{ } clone serialized [ (serialize) ] with-variable ;

: bytes>object ( bytes -- obj )
    binary [ deserialize ] with-byte-reader ;

: object>bytes ( obj -- bytes )
    binary [ serialize ] with-byte-writer ;