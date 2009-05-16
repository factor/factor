USING: accessors assocs bson.constants byte-arrays byte-vectors fry io
io.binary io.encodings.string io.encodings.utf8 kernel math namespaces
sequences serialize arrays calendar io.encodings ;

IN: bson.reader

<PRIVATE

TUPLE: element { type integer } name ;
TUPLE: state
    { size initial: -1 } { read initial: 0 } exemplar
    result scope element ;

: <state> ( exemplar -- state )
    [ state new ] dip
    [ clone >>exemplar ] keep
    clone [ >>result ] [ V{ } clone [ push ] keep >>scope ] bi
    V{ } clone [ T_Object "" element boa swap push ] keep >>element ; 

PREDICATE: bson-eoo     < integer T_EOO = ;
PREDICATE: bson-not-eoo < integer T_EOO > ;

PREDICATE: bson-double  < integer T_Double = ;
PREDICATE: bson-integer < integer T_Integer = ;
PREDICATE: bson-string  < integer T_String = ;
PREDICATE: bson-object  < integer T_Object = ;
PREDICATE: bson-array   < integer T_Array = ;
PREDICATE: bson-binary  < integer T_Binary = ;
PREDICATE: bson-regexp  < integer T_Regexp = ;
PREDICATE: bson-binary-bytes < integer T_Binary_Bytes = ;
PREDICATE: bson-binary-function < integer T_Binary_Function = ;
PREDICATE: bson-binary-uuid < integer T_Binary_UUID = ;
PREDICATE: bson-binary-custom < integer T_Binary_Custom = ;
PREDICATE: bson-oid     < integer T_OID = ;
PREDICATE: bson-boolean < integer T_Boolean = ;
PREDICATE: bson-date    < integer T_Date = ;
PREDICATE: bson-null    < integer T_NULL = ;
PREDICATE: bson-ref     < integer T_DBRef = ;

GENERIC: element-read ( type -- cont? )
GENERIC: element-data-read ( type -- object )
GENERIC: element-binary-read ( length type -- object )

: byte-array>number ( seq -- number )
    byte-array>bignum >integer ; inline

: get-state ( -- state )
    state get ; inline

: count-bytes ( count -- )
    [ get-state ] dip '[ _ + ] change-read drop ; inline

: read-int32 ( -- int32 )
    4 [ read byte-array>number ] [ count-bytes ] bi  ; inline

: read-longlong ( -- longlong )
    8 [ read byte-array>number ] [ count-bytes ] bi ; inline

: read-double ( -- double )
    8 [ read byte-array>number bits>double ] [ count-bytes ] bi ; inline

: read-byte-raw ( -- byte-raw )
    1 [ read ] [ count-bytes ] bi ; inline

: read-byte ( -- byte )
    read-byte-raw first ; inline

: read-cstring ( -- string )
    input-stream get utf8 <decoder>
    "\0" swap stream-read-until drop ; inline

: read-sized-string ( length -- string )
    drop read-cstring ; inline

: read-element-type ( -- type )
    read-byte ; inline

: push-element ( type name -- element )
    element boa
    [ get-state element>> push ] keep ; inline

: pop-element ( -- element )
    get-state element>> pop ; inline

: peek-scope ( -- ht )
    get-state scope>> peek ; inline

: read-elements ( -- )
    read-element-type
    element-read 
    [ read-elements ] when ; inline recursive

GENERIC: fix-result ( assoc type -- result )

M: bson-object fix-result ( assoc type -- result )
    drop ;

M: bson-array fix-result ( assoc type -- result )
    drop
    values ;

GENERIC: end-element ( type -- )

M: bson-object end-element ( type -- )
    drop ;

M: bson-array end-element ( type -- )
    drop ;

M: object end-element ( type -- )
    drop
    pop-element drop ;

M: bson-eoo element-read ( type -- cont? )
    drop
    get-state scope>> [ pop ] keep swap ! vec assoc
    pop-element [ type>> ] keep       ! vec assoc element
    [ fix-result ] dip
    rot length 0 >                      ! assoc element 
    [ name>> peek-scope set-at t ]
    [ drop [ get-state ] dip >>result drop f ] if ;

M: bson-not-eoo element-read ( type -- cont? )
    [ peek-scope ] dip                                 ! scope type 
    '[ _ read-cstring push-element [ name>> ] [ type>> ] bi 
       [ element-data-read ] keep
       end-element
       swap
    ] dip set-at t ;

: [scope-changer] ( state -- state quot )
    dup exemplar>> '[ [ [ _ clone ] dip push ] keep ] ; inline

: (object-data-read) ( type -- object )
    drop
    read-int32 drop
    get-state
    [scope-changer] change-scope
    scope>> peek ; inline
    
M: bson-object element-data-read ( type -- object )
    (object-data-read) ;

M: bson-array element-data-read ( type -- object )
    (object-data-read) ;
    
M: bson-string element-data-read ( type -- object )
    drop
    read-int32 read-sized-string ;

M: bson-integer element-data-read ( type -- object )
    drop
    read-int32 ;

M: bson-double element-data-read ( type -- double )
    drop
    read-double ;

M: bson-boolean element-data-read ( type -- boolean )
   drop
   read-byte 1 = ;

M: bson-date element-data-read ( type -- timestamp )
   drop
   read-longlong millis>timestamp ;

M: bson-binary element-data-read ( type -- binary )
   drop
   read-int32 read-byte element-binary-read ;

M: bson-regexp element-data-read ( type -- mdbregexp )
   drop mdbregexp new
   read-cstring >>regexp read-cstring >>options ;
 
M: bson-null element-data-read ( type -- bf  )
    drop
    f ;

M: bson-oid element-data-read ( type -- oid )
    drop
    read-longlong
    read-int32 oid boa ;

M: bson-binary-bytes element-binary-read ( size type -- bytes )
    drop read ;

M: bson-binary-custom element-binary-read ( size type -- quot )
    drop read bytes>object ;

PRIVATE>

USE: tools.continuations

: stream>assoc ( exemplar -- assoc bytes-read )
    <state> dup state
    [ read-int32 >>size read-elements ] with-variable 
    [ result>> ] [ read>> ] bi ; 
