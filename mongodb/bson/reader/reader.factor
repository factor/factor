USING: mirrors io io.encodings.utf8 io.encodings.binary math match kernel sequences
       splitting accessors io.streams.byte-array namespaces prettyprint
       mongodb.bson.constants assocs alien.c-types alien.strings fry words
       tools.walker serialize mongodb.persistent ;

IN: mongodb.bson.reader

ERROR: size-mismatch actual declared ;

<PRIVATE

TUPLE: element { type integer } name ;
TUPLE: state { size initial: -1 } { read initial: 0 } result scope element ;

: <state> ( -- state )
    state new H{ } clone
    [ >>result ] [ V{ } clone [ push ] keep >>scope ] bi
    V{ } clone [ T_Object "" element boa swap push ] keep >>element ;

PREDICATE: bson-eoo     < integer T_EOO = ;
PREDICATE: bson-not-eoo < integer T_EOO > ;

PREDICATE: bson-double  < integer T_Double = ;
PREDICATE: bson-integer < integer T_Integer = ;
PREDICATE: bson-string  < integer T_String = ;
PREDICATE: bson-object  < integer T_Object = ;
PREDICATE: bson-array   < integer T_Array = ;
PREDICATE: bson-binary  < integer T_Binary = ;
PREDICATE: bson-binary-bytes < integer T_Binary_Bytes = ;
PREDICATE: bson-binary-function < integer T_Binary_Function = ;
PREDICATE: bson-oid     < integer T_OID = ;
PREDICATE: bson-boolean < integer T_Boolean = ;
PREDICATE: bson-date    < integer T_Date = ;
PREDICATE: bson-null    < integer T_NULL = ;
PREDICATE: bson-ref     < integer T_DBRef = ;

GENERIC: element-read ( type -- cont? )
GENERIC: element-data-read ( type -- object )
GENERIC: element-binary-read ( length type -- object )

: get-state ( -- state )
    state get ; inline

: count-bytes ( count -- )
    [ get-state ] dip '[ _ + ] change-read drop ; inline

: read-int32 ( -- int32 )
    4 [ read *int ] [ count-bytes ] bi  ; inline

: read-longlong ( -- longlong )
    8 [ read *longlong ] [ count-bytes ] bi ; inline

: read-double ( -- double )
    8 [ read *double ] [ count-bytes ] bi ; inline

: read-byte-raw ( -- byte-raw )
    1 [ read ] [ count-bytes ] bi ; inline

: read-byte ( -- byte )
    read-byte-raw *char ; inline

: (read-cstring) ( acc -- acc )
    read-byte-raw dup
    B{ 0 } =
    [ append ]
    [ append (read-cstring) ] if ; 

: read-cstring ( -- string )
    B{ } clone
    (read-cstring) utf8 alien>string ;

: read-sized-string ( length -- string )
    [ read ] [ count-bytes ] bi
    utf8 alien>string ;

: read-element-type ( -- type )
    read-byte ;

: push-element ( type name -- element )
    element boa
    [ get-state element>> push ] keep ; 

: pop-element ( -- element )
    get-state element>> pop ;

: peek-scope ( -- ht )
    get-state scope>> peek ; 

: read-elements ( -- )
    read-element-type
    element-read 
    [ read-elements ] when ;

: make-tuple ( assoc -- tuple )
    [ P_INFO swap at persistent-tuple-class new ] keep     ! instance assoc
    [ dup <mirror> [ keys ] keep ] dip                 ! instance array mirror assoc
    '[ dup _ [ _ at ] dip [ swap ] dip set-at ] each ;   

GENERIC: fix-result ( assoc type -- result )

M: bson-object fix-result ( assoc type -- result )
    drop
    [ ] [ P_INFO swap key? ] bi
    [ make-tuple ] [ ] if ;

M: bson-array fix-result ( assoc type -- result )
    drop
    values ;

M: bson-eoo element-read ( type -- cont? )
    drop
    get-state scope>> [ pop ] keep swap                ! vec assoc
    pop-element [ type>> ] keep                        ! vec assoc type element
    [ fix-result ] dip                                 ! vec result element 
    rot length 0 >                                     ! result element 
    [ name>> peek-scope set-at t ]
    [ drop [ get-state ] dip >>result drop f ] if ;

M: bson-not-eoo element-read ( type -- cont? )
    [ peek-scope ] dip                                 ! scope type 
    '[  _ 
        read-cstring push-element [ name>> ] [ type>> ] bi 
        element-data-read 
        swap
    ] dip    
    set-at
    t ;

M: bson-oid element-data-read ( type -- object )
    drop
    read-longlong
    read-int32
    oid boa
    pop-element drop ;

M: bson-object element-data-read ( type -- object )
    drop
    read-int32 drop
    get-state 
    [ [ [ H{ } clone ] dip push ] keep ] change-scope
    scope>> peek ;

M: bson-array element-data-read ( type -- object )
    drop
    read-int32 drop
    get-state
    [ [ [ H{ } clone ] dip push ] keep ] change-scope
    scope>> peek ;
    
M: bson-string element-data-read ( type -- object )
    drop
    read-int32 read-sized-string
    pop-element drop ;

M: bson-integer element-data-read ( type -- object )
    drop
    read-int32
    pop-element drop ;

M: bson-double element-data-read ( type -- double )
    drop
    read-double
    pop-element drop ;

M: bson-boolean element-data-read ( type -- boolean )
    drop
    read-byte t =
    pop-element drop ;

M: bson-binary element-data-read ( type -- binary )
    drop
    read-int32 read-byte element-binary-read
    pop-element drop ;

M: bson-binary-bytes element-binary-read ( size type -- bytes )
    drop read ;

M: bson-binary-function element-binary-read ( size type -- quot )
    drop read bytes>object ;

PRIVATE>
    
: bson> ( arr -- ht )
    binary
    [ <state> dup state
        [ read-int32 >>size read-elements ] with-variable 
        result>>
    ] with-byte-reader ;
