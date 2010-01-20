! Copyright (C) 2006 Adam Langley and Chris Double.
! Adam Langley was the original author of this work.
!
! Chris Double modified it to fix bugs and get it working
! correctly under the latest versions of Factor.
!
! See http://factorcode.org/license.txt for BSD license.
!
USING: namespaces sequences kernel math io math.functions
io.binary strings classes words sbufs classes.tuple arrays
vectors byte-arrays quotations hashtables assocs help.syntax
help.markup splitting io.streams.byte-array io.encodings.string
io.encodings.utf8 io.encodings.binary combinators accessors
locals prettyprint compiler.units sequences.private
classes.tuple.private vocabs.loader ;
IN: serialize

GENERIC: (serialize) ( obj -- )

<PRIVATE

! Variable holding a assoc of objects already serialized
SYMBOL: serialized

TUPLE: id obj ;

C: <id> id

M: id hashcode* nip obj>> identity-hashcode ;

M: id equal? over id? [ [ obj>> ] bi@ eq? ] [ 2drop f ] if ;

: add-object ( obj -- )
    #! Add an object to the sequence of already serialized
    #! objects.
    serialized get [ assoc-size swap <id> ] keep set-at ;

: object-id ( obj -- id )
    #! Return the id of an already serialized object 
    <id> serialized get at ;

! Numbers are serialized as follows:
! 0 => B{ 0 }
! 1<=x<=126 => B{ x | 0x80 }
! x>127 => B{ length(x) x[0] x[1] ... }
! x>2^1024 => B{ 0xff length(x) x[0] x[1] ... }
! The last case is needed because a very large number would
! otherwise be confused with a small number.
: serialize-cell ( n -- )
    [ 0 write1 ] [
        dup HEX: 7e <= [
            HEX: 80 bitor write1
        ] [
            dup log2 8 /i 1 + 
            dup HEX: 7f >= [
                HEX: ff write1
                dup serialize-cell
            ] [
                dup write1
            ] if
            >be write
        ] if
    ] if-zero ;

: deserialize-cell ( -- n )
    read1 {
        { [ dup HEX: ff = ] [ drop deserialize-cell read be> ] }
        { [ dup HEX: 80 >= ] [ HEX: 80 bitxor ] }
        [ read be> ]
    } cond ;

: serialize-shared ( obj quot -- )
    [
        dup object-id
        [ CHAR: o write1 serialize-cell drop ]
    ] dip if* ; inline

M: f (serialize) ( obj -- )
    drop CHAR: n write1 ;

M: integer (serialize) ( obj -- )
    [
        CHAR: z write1
    ] [
        dup 0 < [ neg CHAR: m ] [ CHAR: p ] if write1
        serialize-cell
    ] if-zero ;

M: float (serialize) ( obj -- )
    CHAR: F write1
    double>bits serialize-cell ;

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
        [ tuple>array rest (serialize) ]
        tri
    ] serialize-shared ;

M: array (serialize) ( obj -- )
    CHAR: a serialize-seq ;

M: quotation (serialize) ( obj -- )
    [
        CHAR: q write1
        [ >array (serialize) ] [ add-object ] bi
    ] serialize-shared ;

M: hashtable (serialize) ( obj -- )
    [
        CHAR: h write1
        [ add-object ] [ >alist (serialize) ] bi
    ] serialize-shared ;

M: byte-array (serialize) ( obj -- )
    [
        CHAR: A write1
        [ add-object ]
        [ length serialize-cell ]
        [ write ] tri
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
        [ def>> (serialize) ]
        [ props>> (serialize) ]
        tri
    ] serialize-shared ;

: serialize-word ( word -- )
    CHAR: w write1
    [ name>> (serialize) ]
    [ vocabulary>> (serialize) ]
    bi ;

M: word (serialize) ( obj -- )
    {
        { [ dup t eq? ] [ serialize-true ] }
        { [ dup vocabulary>> not ] [ serialize-gensym ] }
        [ serialize-word ]
    } cond ;

M: wrapper (serialize) ( obj -- )
    CHAR: W write1
    wrapped>> (serialize) ;

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

: (deserialize-string) ( -- string )
    deserialize-cell read utf8 decode ;

: deserialize-string ( -- string )
    (deserialize-string) dup intern-object ;

: deserialize-word ( -- word )
    (deserialize) (deserialize) 2dup [ require ] keep lookup
    dup [ 2nip ] [
        drop
        2array unparse "Unknown word: " prepend throw
    ] if ;

: deserialize-gensym ( -- word )
    gensym {
        [ intern-object ]
        [ (deserialize) define ]
        [ (deserialize) >>props drop ]
        [ ]
    } cleave ;

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
    [ (deserialize) update ]
    [ ] tri ;

: copy-seq-to-tuple ( seq tuple -- )
    [ set-array-nth ] curry each-index ;

: deserialize-tuple ( -- array )
    #! Ugly because we have to intern the tuple before reading
    #! slots
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
    V{ } clone deserialized
    [ (deserialize) ] with-variable ;

: serialize ( obj -- )
    H{ } clone serialized [ (serialize) ] with-variable ;

: bytes>object ( bytes -- obj )
    binary [ deserialize ] with-byte-reader ;

: object>bytes ( obj -- bytes )
    binary [ serialize ] with-byte-writer ;
