USING: io io.encodings.utf8 io.encodings.binary math match kernel sequences
       splitting accessors io.streams.byte-array namespaces prettyprint
       mongodb.bson.constants assocs alien.c-types alien.strings fry ;

IN: mongodb.bson.reader

ERROR: size-mismatch actual declared ;

<PRIVATE

TUPLE: state { size initial: -1 } { read initial: 0 } result scope ;

: <state> ( -- state )
    state new H{ } clone [ >>result ] [ >>scope ] bi ;

PREDICATE: bson-eoo < integer T_EOO = ;
PREDICATE: bson-not-eoo < integer T_EOO > ;
PREDICATE: bson-double < integer T_Double = ;
PREDICATE: bson-integer < integer T_Integer = ;
PREDICATE: bson-string < integer T_String = ;
PREDICATE: bson-object < integer T_Object = ;
PREDICATE: bson-array  < integer T_Array = ;
PREDICATE: bson-binary < integer T_Binary = ;
PREDICATE: bson-oid < integer    T_OID = ;
PREDICATE: bson-boolean < integer T_Boolean = ;
PREDICATE: bson-date < integer T_Date = ;
PREDICATE: bson-null < integer T_NULL = ;
PREDICATE: bson-ref < integer T_DBRef = ;

GENERIC: element-read ( type -- cont? )

GENERIC: element-data-read ( type -- object )

: get-state ( -- state )
    state get ;

: count-bytes ( count -- )
    [ get-state ] dip '[ _ + ] change-read drop ;

: read-int32 ( -- int32 )
    4 [ read *int ] [ count-bytes ] bi  ;

: read-byte-raw ( -- byte-raw )
    1 [ read ] [ count-bytes ] bi ;

: read-byte ( -- byte )
    read-byte-raw *char ;

: (read-cstring) ( acc -- acc )
    read-byte-raw dup
    B{ 0 } =
    [ append ]
    [ append (read-cstring) ] if ;

: read-cstring ( -- string )
    B{ } clone
    (read-cstring) utf8 alien>string ;


: object-size ( -- size )
    read-int32 ;


: read-element-type ( -- type )
    read-byte ;

: element-name ( -- name )
    read-cstring  ; 

: read-elements ( -- )
    read-element-type
    element-read 
    [ read-elements ] when ;


M: bson-eoo element-read ( type -- cont? )
    drop
    f ;

M: bson-not-eoo element-read ( type -- cont? )
    [ element-name ] dip 
    element-data-read
    swap
    get-state scope>>
    set-at
    t ;


M: bson-string element-data-read ( type -- object )
    drop
    read-int32 drop 
    read-cstring ;

M: bson-integer element-data-read ( type -- object )
    drop
    read-int32 ;

PRIVATE>
    
: bson> ( arr -- ht )
    binary
    [ <state> dup state
        [ object-size >>size read-elements ] with-variable
    ] with-byte-reader ;
