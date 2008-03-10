! Copyright (C) 2006 Adam Langley and Chris Double.
! Adam Langley was the original author of this work.
!
! Chris Double modified it to fix bugs and get it working
! correctly under the latest versions of Factor.
!
! See http://factorcode.org/license.txt for BSD license.
!
IN: serialize
USING: namespaces sequences kernel math io math.functions
io.binary strings classes words sbufs tuples arrays
vectors byte-arrays bit-arrays quotations hashtables
assocs help.syntax help.markup float-arrays splitting
io.encodings.string io.encodings.utf8 combinators ;

! Variable holding a assoc of objects already serialized
SYMBOL: serialized

TUPLE: id obj ;

C: <id> id

M: id hashcode* id-obj hashcode* ;

M: id equal? over id? [ [ id-obj ] 2apply eq? ] [ 2drop f ] if ;

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
    [ CHAR: o write1 serialize-cell drop ] r> if* ; inline

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

: serialize-string ( obj code -- )
    write1
    dup utf8 encode dup length serialize-cell write
    add-object ;

M: string (serialize) ( obj -- )
    [ CHAR: s serialize-string ] serialize-shared ;

: serialize-elements
    [ (serialize) ] each CHAR: . write1 ;

M: tuple (serialize) ( obj -- )
    [
        CHAR: T write1
        dup tuple>array serialize-elements
        add-object
    ] serialize-shared ;

: serialize-seq ( seq code -- )
    [
        write1
        dup serialize-elements
        add-object
    ] curry serialize-shared ;

M: array (serialize) ( obj -- )
    CHAR: a serialize-seq ;

M: byte-array (serialize) ( obj -- )
    [
        CHAR: A write1
        dup dup length serialize-cell write
        add-object
    ] serialize-shared ;

M: bit-array (serialize) ( obj -- )
    [
        CHAR: b write1
        dup length serialize-cell
        dup [ 1 0 ? ] B{ } map-as write
        add-object
    ] serialize-shared ;

M: quotation (serialize) ( obj -- )
    CHAR: q serialize-seq ;

M: float-array (serialize) ( obj -- )
    [
        CHAR: f write1
        dup length serialize-cell
        dup [ double>bits 8 >be write ] each
        add-object
    ] serialize-shared ;

M: hashtable (serialize) ( obj -- )
    [
        CHAR: h write1
        dup >alist (serialize)
        add-object
    ] serialize-shared ;

M: word (serialize) ( obj -- )
    [
        CHAR: w write1
        dup word-name (serialize)
        dup word-vocabulary (serialize)
        add-object
    ] serialize-shared ;

M: wrapper (serialize) ( obj -- )
    CHAR: W write1
    wrapped (serialize) ;

DEFER: (deserialize) ( -- obj )

SYMBOL: deserialized

: intern-object ( obj -- )
    deserialized get push ;

: deserialize-false ( -- f )
    f ;

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
    (deserialize) dup (deserialize) lookup
    [ dup intern-object ] [ "Unknown word" throw ] ?if ;

: deserialize-wrapper ( -- wrapper )
    (deserialize) <wrapper> ;

SYMBOL: +stop+

: (deserialize-seq) ( -- seq )
    [ (deserialize) dup +stop+ get eq? not ] [ ] [ drop ] unfold ;

: deserialize-seq ( seq -- array )
    >r (deserialize-seq) r> like dup intern-object ;

: deserialize-array ( -- array )
    { } deserialize-seq ;

: deserialize-quotation ( -- array )
    [ ] deserialize-seq ;

: (deserialize-byte-array) ( -- byte-array )
    deserialize-cell read B{ } like ;

: deserialize-byte-array ( -- byte-array )
    (deserialize-byte-array) dup intern-object ;

: deserialize-bit-array ( -- bit-array )
    (deserialize-byte-array) [ 0 > ] ?{ } map-as
    dup intern-object ;

: deserialize-float-array ( -- float-array )
    deserialize-cell
    8 * read 8 <groups> [ be> bits>double ] F{ } map-as
    dup intern-object ;

: deserialize-hashtable ( -- hashtable )
    (deserialize) >hashtable dup intern-object ;

: deserialize-tuple ( -- array )
    (deserialize-seq) >tuple dup intern-object ;

: deserialize-unknown ( -- object )
    deserialize-cell deserialized get nth ;

: deserialize-stop ( -- object )
    +stop+ get ;

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
            { CHAR: o [ deserialize-unknown ] }
            { CHAR: p [ deserialize-positive-integer ] }
            { CHAR: q [ deserialize-quotation ] }
            { CHAR: r [ deserialize-ratio ] }
            { CHAR: s [ deserialize-string ] }
            { CHAR: w [ deserialize-word ] }
            { CHAR: z [ deserialize-zero ] }
            { CHAR: . [ deserialize-stop ] }
        } case t
    ] [
        f f
    ] if* ;

: (deserialize) ( -- obj )
    deserialize* [ "End of stream" throw ] unless ;

: deserialize ( -- obj )
    [
        V{ } clone deserialized set
        gensym +stop+ set
        (deserialize)
    ] with-scope ;

: serialize ( obj -- )
    [
        H{ } clone serialized set
        (serialize)
    ] with-scope ;