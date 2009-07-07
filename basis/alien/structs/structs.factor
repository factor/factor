! Copyright (C) 2004, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.marshall
alien.structs.fields arrays assocs byte-arrays classes.tuple
combinators cpu.architecture destructors fry generalizations
generic hashtables kernel kernel.private libc locals math
math.order namespaces parser quotations sequences slots strings
words ;
IN: alien.structs

TUPLE: struct-type
size
align
fields
{ boxer-quot callable }
{ unboxer-quot callable }
{ getter callable }
{ setter callable }
return-in-registers? ;

M: struct-type c-type ;

M: struct-type heap-size size>> ;

M: struct-type c-type-class drop byte-array ;

M: struct-type c-type-align align>> ;

M: struct-type c-type-stack-align? drop f ;

M: struct-type c-type-boxer-quot boxer-quot>> ;

M: struct-type c-type-unboxer-quot unboxer-quot>> ;

: if-value-struct ( ctype true false -- )
    [ dup value-struct? ] 2dip '[ drop "void*" @ ] if ; inline

M: struct-type unbox-parameter
    [ %unbox-large-struct ] [ unbox-parameter ] if-value-struct ;

M: struct-type box-parameter
    [ %box-large-struct ] [ box-parameter ] if-value-struct ;

: if-small-struct ( c-type true false -- ? )
    [ dup return-struct-in-registers? ] 2dip '[ f swap @ ] if ; inline

M: struct-type unbox-return
    [ %unbox-small-struct ] [ %unbox-large-struct ] if-small-struct ;

M: struct-type box-return
    [ %box-small-struct ] [ %box-large-struct ] if-small-struct ;

M: struct-type stack-size
    [ heap-size ] [ stack-size ] if-value-struct ;

: c-struct? ( type -- ? ) (c-type) struct-type? ;

: (define-struct) ( name size align fields -- )
    [ [ align ] keep ] dip
    struct-type new
        swap >>fields
        swap >>align
        swap >>size
        swap typedef ;

: make-fields ( name vocab fields -- fields )
    [ first2 <field-spec> ] with with map ;

: compute-struct-align ( types -- n )
    [ c-type-align ] [ max ] map-reduce ;

: define-struct ( name vocab fields -- )
    [ 2drop ] [ make-fields ] 3bi
    [ struct-offsets ] keep
    [ [ type>> ] map compute-struct-align ] keep
    [ (define-struct) ] keep
    [ define-field ] each ;

: define-union ( name members -- )
    [ expand-constants ] map
    [ [ heap-size ] [ max ] map-reduce ] keep
    compute-struct-align f (define-struct) ;

: offset-of ( field struct -- offset )
    c-types get at fields>> 
    [ name>> = ] with find nip offset>> ;

TUPLE: struct-wrapper < alien-wrapper disposed ;

M: struct-wrapper dispose* underlying>> free ;

: define-struct-accessor ( class name quot -- )
    [ "accessors" create create-method dup make-inline ] dip define ;

: define-struct-getter ( class name word type -- )
    [ ">>" append \ underlying>> ] 2dip 
    unmarshaller \ call 4array >quotation
    define-struct-accessor ;

: define-struct-setter ( class name word type -- )
    [ "(>>" prepend ")" append ] 2dip
    marshaller [ underlying>> ] \ bi* roll 4array >quotation
    define-struct-accessor ;

: define-struct-accessors ( class name type reader writer -- )
    [ dup define-protocol-slot ] 3dip
    [ drop swap define-struct-getter ]
    [ nip swap define-struct-setter ] 5 nbi ;

:: define-struct-tuple ( name -- )
    name create-in :> class
    class struct-wrapper { } define-tuple-class
    name c-type fields>> [
        class swap
        {
            [ name>> { { CHAR: space CHAR: - } } substitute ]
            [ type>> ] [ reader>> ] [ writer>> ]
        } cleave define-struct-accessors
    ] each ;
