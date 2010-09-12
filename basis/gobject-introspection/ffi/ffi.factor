! Copyright (C) 2009 Anton Gorenko.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.parser arrays assocs
classes.parser classes.struct combinators
combinators.short-circuit definitions effects fry
gobject-introspection.common gobject-introspection.types kernel
math.parser namespaces parser quotations sequences
sequences.generalizations words words.constant ;
IN: gobject-introspection.ffi

: string>c-type ( str -- c-type )
    dup CHAR: * swap index [ cut ] [ "" ] if*
    [ replaced-c-types get-global ?at drop ] dip
    append parse-c-type ;
    
: define-each ( nodes quot -- )
    '[ dup @ >>ffi drop ] each ; inline

: function-ffi-invoker ( func -- quot )
    {
        [ return>> c-type>> string>c-type ]
        [ drop current-lib get-global ]
        [ identifier>> ]
        [ parameters>> [ c-type>> string>c-type ] map ]
        [ varargs?>> [ void* suffix ] when ]
    } cleave function-quot ;

: function-ffi-effect ( func -- effect )
    [ parameters>> [ name>> ] map ]
    [ varargs?>> [ "varargs" suffix ] when ]
    [ return>> type>> none-type? { } { "result" } ? ] tri
    <effect> ;

: define-ffi-function ( func -- word )
    [ identifier>> create-in dup ]
    [ function-ffi-invoker ] [ function-ffi-effect ] tri
    define-declared ;

: define-ffi-functions ( functions -- )
    [ define-ffi-function ] define-each ;

: callback-ffi-invoker ( callback -- quot )
    [ return>> c-type>> string>c-type ]
    [ parameters>> [ c-type>> string>c-type ] map ] bi
    cdecl callback-quot ;

: callback-ffi-effect ( callback -- effect )
    [ parameters>> [ name>> ] map ]
    [ return>> type>> none-type? { } { "result" } ? ] bi
    <effect> ;

: define-ffi-callback ( callback -- word )
    [ c-type>> create-in [ void* swap typedef ] keep dup ] keep
    [ callback-ffi-effect "callback-effect" set-word-prop ]
    [ drop current-lib get-global "callback-library" set-word-prop ] 
    [ callback-ffi-invoker (( quot -- alien )) define-inline ] 2tri ;

: fix-signal-param-c-type ( param -- )
    dup [ c-type>> ] [ type>> ] bi
    {
        [ none-type? ]
        [ simple-type? ]
        [ enum-type? ]
        [ bitfield-type? ]
    } 1|| [ dup "*" tail? [ CHAR: * suffix ] unless ] unless
    >>c-type drop ;

: define-ffi-signal ( signal -- word )
    [ return>> fix-signal-param-c-type ]
    [ parameters>> [ fix-signal-param-c-type ] each ]
    [ define-ffi-callback ] tri ;
    
: define-ffi-signals ( signals -- )
    [ define-ffi-signal ] define-each ;

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
    ] [ c-type>> (CREATE-C-TYPE) [ int swap typedef ] keep ] bi ;

: define-ffi-enums ( enums -- )
    [ define-ffi-enum ] define-each ;
    
: define-ffi-bitfields ( bitfields -- )
    [ define-ffi-enum ] define-each ;

: fields>struct-slots ( fields -- slots )
    [
        [ name>> ]
        [
            [ c-type>> string>c-type ] [ array-info>> ] bi
            [ fixed-size>> [ 2array ] when* ] when*
        ]
        [ drop { } ] tri <struct-slot-spec>
    ] map ;

: define-ffi-record-defer ( record -- word )
    c-type>> create-in void* swap [ typedef ] keep ;

: define-ffi-records-defer ( records -- )
    [ define-ffi-record-defer ] define-each ;

: define-ffi-record ( record -- word )
    dup ffi>> forget
    dup {
        [ fields>> empty? not ]
        [ c-type>> implement-structs get-global member? ]
    } 1&&
    [
        [ c-type>> create-class-in dup ]
        [ fields>> fields>struct-slots ] bi define-struct-class        
    ] [
        [ disguised?>> void* void ? ]
        [ c-type>> create-in ] bi [ typedef ] keep
    ] if ;

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

: define-ffi-callbacks ( callbacks -- )
    [ define-ffi-callback ] define-each ;

: define-ffi-interface ( interface -- word )
    c-type>> create-in [ void swap typedef ] keep ;

: define-ffi-interfaces ( interfaces -- )
    [ define-ffi-interface ] define-each ;

: define-ffi-interface-content ( interface -- )
    {
        [ methods>> define-ffi-functions ]
    } cleave ;

: define-ffi-interfaces-content ( interfaces -- )
    [ define-ffi-interface-content ] each ;

: get-type-invoker ( name -- quot )
    ! hack
    [ "GType" "glib.ffi" lookup current-lib get-global ] dip
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
        [ signals>> define-ffi-signals ]
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
    [ c-identifier>> create-in dup ] [ const-value ] bi
    define-constant ;

: define-ffi-consts ( consts -- )
    [ define-ffi-const ] define-each ;

: define-ffi-alias ( alias -- )
    drop ;

: define-ffi-aliases ( aliases -- )
    [ define-ffi-alias ] each ;

: define-ffi-namespace ( namespace -- )
    {
        [ aliases>> define-ffi-aliases ]
        [ consts>> define-ffi-consts ]
        [ enums>> define-ffi-enums ]
        [ bitfields>> define-ffi-bitfields ]
        
        [ records>> define-ffi-records-defer ]

        [ unions>> define-ffi-unions ]
        [ interfaces>> define-ffi-interfaces ]
        [ classes>> define-ffi-classes ]
        [ callbacks>> define-ffi-callbacks ]
        [ records>> define-ffi-records ]
                
        [ records>> define-ffi-records-content ]
        [ classes>> define-ffi-classes-content ]
        [ interfaces>> define-ffi-interfaces-content ]
        [ functions>> define-ffi-functions ]

        [ define-get-types ]
    } cleave ;

: define-ffi-repository ( repository -- )
    namespace>> define-ffi-namespace ;
     
