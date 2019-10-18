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
assocs help.syntax help.markup float-arrays splitting ;

! Variable holding a sequence of objects already serialized
SYMBOL: serialized

: add-object ( obj -- id )
    #! Add an object to the sequence of already serialized
    #! objects. Return the id of that object.
    serialized get [ push ] keep length 1 - ;

: object-id ( obj -- id )
    #! Return the id of an already serialized object 
    serialized get [ eq? ] curry* find [ drop f ] unless ;

USE: prettyprint 

! Serialize object
GENERIC: (serialize) ( obj -- )

: serialize-cell 8 >be write ;

: deserialize-cell 8 read be> ;

: serialize-shared ( obj quot -- )
    >r dup object-id
    [ "o" write serialize-cell drop ] r> if* ; inline

M: f (serialize) ( obj -- )
    drop "n" write ;

: bytes-needed ( number -- int )
    log2 8 + 8 /i ; inline

M: integer (serialize) ( obj -- )
    dup 0 = [
        drop "z" write
    ] [
        dup 0 < [ neg "m" ] [ "p" ] if write 
        dup bytes-needed dup serialize-cell
        >be write 
    ] if ;

M: float (serialize) ( obj -- )
    "F" write
    double>bits serialize-cell ;

M: complex (serialize) ( obj -- )
    "c" write
    dup real (serialize)
    imaginary (serialize) ;

M: ratio (serialize) ( obj -- )
    "r" write
    dup numerator (serialize)
    denominator (serialize) ;

M: string (serialize) ( obj -- )
    [
        "s" write
        dup add-object serialize-cell
        dup length serialize-cell
        write 
    ] serialize-shared ;

M: sbuf (serialize) ( obj -- )
    [
        "S" write
        dup add-object serialize-cell
        dup length serialize-cell
        >string write 
    ] serialize-shared ;

M: tuple (serialize) ( obj -- )
    [
        "T" write
        dup add-object serialize-cell
        tuple>array
        dup length serialize-cell
        [ (serialize) ] each
    ] serialize-shared ;

: serialize-seq ( seq code -- )
    [
        write
        dup add-object serialize-cell
        dup length serialize-cell
        [ (serialize) ] each
    ] curry serialize-shared ;

M: array (serialize) ( obj -- )
    "a" serialize-seq ;

M: vector (serialize) ( obj -- )
    "v" serialize-seq ;

M: byte-array (serialize) ( obj -- )
    "A" serialize-seq ;

M: bit-array (serialize) ( obj -- )
    "b" serialize-seq ;

M: quotation (serialize) ( obj -- )
    "q" serialize-seq ;

M: curry (serialize) ( obj -- )
    [
        "C" write
        dup add-object serialize-cell
        dup curry-obj (serialize) curry-quot (serialize)
    ] serialize-shared ;

M: float-array (serialize) ( obj -- )
    [
        "f" write
        dup add-object serialize-cell
        dup length serialize-cell
        [ double>bits 8 >be write ] each
    ] serialize-shared ;

M: hashtable (serialize) ( obj -- )
    [
        "h" write
        dup add-object serialize-cell
        >alist (serialize)
    ] serialize-shared ;

M: word (serialize) ( obj -- )
    "w" write
    dup word-name (serialize)
    word-vocabulary (serialize) ;

M: wrapper (serialize) ( obj -- )
    "W" write
    wrapped (serialize) ;

DEFER: (deserialize) ( -- obj )

: intern-object ( id obj -- obj )
    dup rot serialized get set-nth ;

: deserialize-false ( -- f )
    f ;

: deserialize-positive-integer ( -- number )
    deserialize-cell read be> ;

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

: deserialize-string ( -- string )
    deserialize-cell deserialize-cell read intern-object ;

: deserialize-sbuf ( -- sbuf )
    deserialize-cell deserialize-cell read >sbuf intern-object ;

: deserialize-word ( -- word )
    (deserialize) dup (deserialize) lookup
    [ ] [ "Unknown word" throw ] ?if ;

: deserialize-wrapper ( -- wrapper )
    (deserialize) <wrapper> ;

: deserialize-seq ( seq -- array )
    deserialize-cell deserialize-cell
    [ drop (deserialize) ] roll map-as
    intern-object ;

: deserialize-array ( -- array )
    { } deserialize-seq ;

: deserialize-vector ( -- array )
    V{ } deserialize-seq ;

: deserialize-quotation ( -- array )
    [ ] deserialize-seq ;

: deserialize-byte-array ( -- byte-array )
    B{ } deserialize-seq ;

: deserialize-bit-array ( -- bit-array )
    ?{ } deserialize-seq ;

: deserialize-float-array ( -- float-array )
    deserialize-cell deserialize-cell
    8 * read 8 <groups> [ be> bits>double ] F{ } map-as
    intern-object ;

: deserialize-hashtable ( -- hashtable )
    deserialize-cell (deserialize) >hashtable intern-object ;

: deserialize-tuple ( -- array )
    deserialize-cell
    deserialize-cell [ drop (deserialize) ] map >tuple
    intern-object ;

: deserialize-curry ( -- curry )
    deserialize-cell
    (deserialize) (deserialize) curry
    intern-object ;

: deserialize-unknown ( -- object )
    deserialize-cell serialized get nth ;

: deserialize* ( -- object ? )
    read1 [
        H{
            { CHAR: A deserialize-byte-array }
            { CHAR: C deserialize-curry }
            { CHAR: F deserialize-float }
            { CHAR: S deserialize-sbuf }
            { CHAR: T deserialize-tuple }
            { CHAR: W deserialize-wrapper }
            { CHAR: a deserialize-array }
            { CHAR: b deserialize-bit-array }
            { CHAR: c deserialize-complex }
            { CHAR: f deserialize-float-array }
            { CHAR: h deserialize-hashtable }
            { CHAR: m deserialize-negative-integer }
            { CHAR: n deserialize-false }
            { CHAR: o deserialize-unknown }
            { CHAR: p deserialize-positive-integer }
            { CHAR: q deserialize-quotation }
            { CHAR: r deserialize-ratio }
            { CHAR: s deserialize-string }
            { CHAR: v deserialize-vector }
            { CHAR: w deserialize-word }
            { CHAR: z deserialize-zero }
        } at dup [ "Unknown typecode" throw ] unless execute t
    ] [
        f f
    ] if* ;

: (deserialize) ( -- obj )
    deserialize* [ "End of stream" throw ] unless ;

: with-serialized ( quot -- )
    V{ } clone serialized rot with-variable ; inline

: deserialize-sequence ( -- seq )
    [ [ deserialize* ] [ ] [ drop ] unfold ] with-serialized ;

: deserialize ( -- obj )
    [ (deserialize) ] with-serialized ;

: serialize ( obj -- )
    [ (serialize) ] with-serialized ;