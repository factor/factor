! Copyright (C) 2009 Anton Gorenko.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.parser assocs combinators
combinators.short-circuit effects fry generalizations
gir.common gir.types kernel locals math math.parser namespaces
parser prettyprint quotations sequences vocabs.parser words
words.constant ;
IN: gir.ffi

: string>c-type ( str -- c-type )
    parse-c-type ;
    
: define-each ( nodes quot -- )
    '[ dup @ >>ffi drop ] each ; inline

: ffi-invoker ( func -- quot )
    {
        [ return>> c-type>> string>c-type ]
        [ drop current-lib get ]
        [ identifier>> ]
        [ parameters>> [ c-type>> string>c-type ] map ]
        [ varargs?>> [ void* suffix ] when ]
    } cleave \ alien-invoke 5 narray >quotation ;

: ffi-effect ( func -- effect )
    [ parameters>> [ name>> ] map ]
    [ varargs?>> [ "varargs" suffix ] when ]
    [ return>> type>> none-type? { } { "result" } ? ] tri
    <effect> ;

: define-ffi-function ( func -- word )
    [ identifier>> create-in dup ]
    [ ffi-invoker ] [ ffi-effect ] tri define-declared ;

: define-ffi-functions ( functions -- )
    [ define-ffi-function ] define-each ;

: signal-param-c-type ( param -- c-type )
    [ c-type>> ] [ type>> ] bi
    {
        [ none-type? ]
        [ simple-type? ]
        [ enum-type? ]
        [ bitfield-type? ]
    } 1|| [ dup "*" tail? [ CHAR: * suffix ] unless ] unless ;

: signal-ffi-invoker ( signal -- quot )
    [ return>> signal-param-c-type string>c-type ]
    [ parameters>> [ signal-param-c-type string>c-type ] map ] bi
    "cdecl" [ [ ] 3curry dip alien-callback ] 3curry ;

: signal-ffi-effect ( signal -- effect )
    [ parameters>> [ name>> ] map ]
    [ return>> type>> none-type? { } { "result" } ? ] bi
    <effect> dup . ;

:: define-ffi-signal ( signal class -- word ) ! сделать попонятнее
    signal dup .
    [
        name>> class c-type>> swap ":" glue create-in
        [ void* swap typedef ] keep dup
    ] keep
    [ signal-ffi-effect "callback-effect" set-word-prop ]
    [ drop current-lib get "callback-library" set-word-prop ] 
    [ signal-ffi-invoker (( quot -- alien )) define-inline ] 2tri ;

: define-ffi-signals ( signals class -- )
    '[ _ define-ffi-signal ] define-each ;

: const-value ( const -- value )
    [ value>> ] [ type>> name>> ] bi {
        { "int" [ string>number ] }
        { "double" [ string>number ] }
        { "utf8" [ ] }
    } case ;

: define-ffi-enum ( enum -- word )
    [
       members>> [
           [ c-identifier>> create-in ]
           [ value>> ] bi define-constant
       ] each 
    ] [ c-type>> create-in [ int swap typedef ] keep ] bi ;

: define-ffi-enums ( enums -- )
    [ define-ffi-enum ] define-each ;
    
: define-ffi-bitfields ( bitfields -- )
    [ define-ffi-enum ] define-each ;

: define-ffi-record ( record -- word )
    [ disguised?>> void* void ? ]
    [ c-type>> create-in ] bi [ typedef ] keep ;

: define-ffi-records ( records -- )
    [ define-ffi-record ] define-each ;

: define-ffi-record-content ( record -- )
    {
        [ constructors>> define-ffi-functions ]
        [ functions>> define-ffi-functions ]
        [ methods>> define-ffi-functions ]
    } cleave ;

: define-ffi-records-content ( records -- )
    [ define-ffi-record-content ] each ;

: define-ffi-union ( union -- word )
    c-type>> create-in [ void* swap typedef ] keep ;

: define-ffi-unions ( unions -- )
    [ define-ffi-union ] define-each ;

: define-ffi-callback ( callback -- word )
    c-type>> create-in [ void* swap typedef ] keep ;

: define-ffi-callbacks ( callbacks -- )
    [ define-ffi-callback ] define-each ;

: define-ffi-interface ( interface -- word )
    c-type>> create-in [ void swap typedef ] keep ;

: define-ffi-interfaces ( interfaces -- )
    [ define-ffi-interface ] define-each ;

! Доделать
: define-ffi-interface-content ( interface -- )
    {
        [ methods>> define-ffi-functions ]
    } cleave ;

: define-ffi-interfaces-content ( interfaces -- )
    [ define-ffi-interface-content ] each ;

: get-type-invoker ( name -- quot )
    [ "GType" current-lib get ] dip
    { } \ alien-invoke 5 narray >quotation ;
    
: define-ffi-class ( class -- word )
    c-type>> create-in [ void swap typedef ] keep ;

: define-ffi-classes ( class -- )
    [ define-ffi-class ] define-each ;

: define-ffi-class-content ( class -- )
    {
        [ constructors>> define-ffi-functions ]
        [ functions>> define-ffi-functions ]
        [ methods>> define-ffi-functions ]
        [ [ signals>> ] keep define-ffi-signals ]
    } cleave ;

: define-ffi-classes-content ( class -- )
    [ define-ffi-class-content ] each ;

: define-get-type ( node -- word )
    get-type>> dup { "intern" f } member? [ drop f ]
    [
        [ create-in dup ] [ get-type-invoker ] bi
        { } { "type" } <effect> define-declared
    ] if ;

: define-get-types ( namespace -- )
    {
        [ enums>> [ define-get-type drop ] each ]
        [ bitfields>> [ define-get-type drop ] each ]
        [ records>> [ define-get-type drop ] each ]
        [ unions>> [ define-get-type drop ] each ]
        [ interfaces>> [ define-get-type drop ] each ]
        [ classes>> [ define-get-type drop ] each ]
    } cleave ;

: define-ffi-const ( const -- word )
    [ name>> create-in dup ] [ const-value ] bi define-constant ;

: define-ffi-consts ( consts -- )
    [ define-ffi-const ] define-each ;

: define-ffi-alias ( alias -- )
    drop ;

: define-ffi-aliases ( aliases -- )
    [ define-ffi-alias ] each ;

: prepare-vocab ( repository -- )
    includes>> lib-aliases get '[ _ at ] map sift
    [ ffi-vocab "." glue ] map
    { "alien.c-types" } append
    [ dup using-vocab? [ drop ] [ use-vocab ] if ] each ;

: define-ffi-namespace ( namespace -- )
    {
        [ aliases>> define-ffi-aliases ]
        [ consts>> define-ffi-consts ]
        [ enums>> define-ffi-enums ]
        [ bitfields>> define-ffi-bitfields ]
        [ records>> define-ffi-records ]
        [ unions>> define-ffi-unions ]
        [ interfaces>> define-ffi-interfaces ]
        [ classes>> define-ffi-classes ]
        [ callbacks>> define-ffi-callbacks ]
        [ records>> define-ffi-records-content ]
        [ classes>> define-ffi-classes-content ]
        [ interfaces>> define-ffi-interfaces-content ]
        [ functions>> define-ffi-functions ]
    } cleave ;

: define-ffi-repository ( repository -- )
    [ prepare-vocab ]    
    [ namespace>> define-ffi-namespace ] bi ;
     
