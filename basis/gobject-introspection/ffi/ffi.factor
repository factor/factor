! Copyright (C) 2010 Anton Gorenko.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.parser arrays ascii
classes.parser classes.struct combinators
combinators.short-circuit gobject-introspection.repository
gobject-introspection.types kernel make math.parser namespaces
sequences splitting.monotonic vocabs.parser words words.constant ;
IN: gobject-introspection.ffi

: def-c-type ( c-type-name base-c-type -- )
    swap (CREATE-C-TYPE) typedef ;

: defer-c-type ( c-type-name -- c-type )
    deferred-type swap (CREATE-C-TYPE) [ typedef ] keep ;
!     create-word-in dup
!     [ fake-definition ] [ undefined-def define ] bi ;

:: defer-types ( types type-info-class -- )
    types [
        [ c-type>> defer-c-type ]
        [ name>> qualified-name ] bi
        type-info-class new swap register-type
    ] each ;

: def-alias-c-type ( base-c-type c-type-name -- c-type )
    (CREATE-C-TYPE) [ typedef ] keep ;

: alias-c-type-name ( alias -- c-type-name )
    ! <workaround for aliases w/o c:type (Atk)
    [ c-type>> ] [ name>> ] bi or ;
    ! workaround>
    ! c-type>> ;

:: def-alias ( alias -- )
    alias type>> get-type-info
    [ c-type>> alias alias-c-type-name def-alias-c-type ]
    [ clone ] bi alias name>> qualified-name register-type ;

: def-aliases ( aliases -- )
    [ def-alias ] each ;

GENERIC: type>c-type ( type -- c-type )

M: atomic-type type>c-type get-type-info c-type>> ;
M: enum-type type>c-type get-type-info c-type>> ;
M: bitfield-type type>c-type get-type-info c-type>> ;
M: record-type type>c-type get-type-info c-type>> <pointer> ;
M: union-type type>c-type get-type-info c-type>> <pointer> ;
M: boxed-type type>c-type get-type-info c-type>> <pointer> ;
M: callback-type type>c-type get-type-info c-type>> ;
M: class-type type>c-type get-type-info c-type>> <pointer> ;
M: interface-type type>c-type get-type-info c-type>> <pointer> ;

M: boxed-array-type type>c-type
    name>> simple-type new swap >>name type>c-type ;

M: c-array-type type>c-type
    element-type>> type>c-type <pointer> ;

M: fixed-size-array-type type>c-type
    [ element-type>> type>c-type ] [ fixed-size>> ] bi 2array ;

! <workaround for <type/> (in some signals and properties)
PREDICATE: incorrect-type < simple-type name>> not ;
M: incorrect-type type>c-type drop void* ;
! workaround>

GENERIC: parse-const-value ( str data-type -- value )

: number-type? ( name -- ? )
    {
        [ "gint" head? ]
        [ "guint" head? ]
        [ "gchar" = ]
        [ "guchar" = ]
        [ "gdouble" = ]
        [ "gfloat" = ]
    } 1|| ;

M: atomic-type parse-const-value
    name>> {
        { [ dup number-type? ] [ drop string>number ] }
        { [ dup "gboolean" = ] [ drop "true" = ] }
    } cond ;

M: utf8-type parse-const-value drop ;

: const-value ( const -- value )
    [ value>> ] [ type>> ] bi parse-const-value ;

: def-const ( const -- )
    [ c-identifier>> create-function ] [ const-value ] bi
    define-constant ;

: def-consts ( consts -- )
    [ def-const ] each ;

: define-enum-member ( member -- )
    [ c-identifier>> create-function ] [ value>> ] bi
    define-constant ;

: def-enum-type ( enum -- )
    [ members>> [ define-enum-member ] each ]
    [ c-type>> int def-c-type ] bi ;

: def-bitfield-type ( bitfield -- )
    def-enum-type ;

GENERIC: parameter-type>c-type ( data-type -- c-type )

M: data-type parameter-type>c-type type>c-type ;
M: varargs-type parameter-type>c-type drop void* ;

: parameter-c-type ( parameter -- c-type )
    [ type>> parameter-type>c-type ] keep
    direction>> "in" = [ <pointer> ] unless ;

GENERIC: return-type>c-type ( data-type -- c-type )

M: data-type return-type>c-type type>c-type ;
M: none-type return-type>c-type drop void ;

: return-c-type ( return -- c-type )
    type>> return-type>c-type ;

: parameter-name ( parameter -- name )
    dup type>> varargs-type?
    [ drop "varargs" ] [ name>> "!incorrect-name!" or ] if ;

: error-parameter ( -- parameter )
    parameter new
        "error" >>name
        "in" >>direction
        "none" >>transfer-ownership
        simple-type new "GLib.Error" >>name >>type ;

: ?suffix-parameters-with-error ( callable -- parameters )
    [ parameters>> ] [ throws?>> ] bi
    [ error-parameter suffix ] when ;

: parameter-names&types ( callable -- names types )
    [ [ parameter-c-type ] map ] [ [ parameter-name ] map ] bi ;

: def-function ( function -- )
    {
        [ return>> return-c-type ]
        [ identifier>> ]
        [ drop current-library get ]
        [ ?suffix-parameters-with-error parameter-names&types ]
    } cleave make-function define-inline ;

: def-functions ( functions -- )
    [ def-function ] each ;

GENERIC: type>data-type ( type -- data-type )

M: type type>data-type
    [ simple-type new ] dip name>> >>name ;

: word-started? ( word letter -- ? )
    [ letter? ] [ LETTER? ] bi* and ; inline

: camel-case>underscore-separated ( str -- str' )
    [ word-started? not ] monotonic-split "_" join >lower ;

: type>parameter-name ( type -- name )
    name>> camel-case>underscore-separated ;

: type>parameter ( type -- parameter )
    [ parameter new ] dip {
        [ type>parameter-name >>name ]
        [ type>data-type >>type ]
        [ drop "in" >>direction "none" >>transfer-ownership ]
    } cleave ;

:: def-method ( method type -- )
    method {
        [ return>> return-c-type ]
        [ identifier>> ]
        [ drop current-library get ]
        [
            ?suffix-parameters-with-error
            type type>parameter prefix
            parameter-names&types
        ]
    } cleave make-function define-inline ;

: def-methods ( methods type -- )
    [ def-method ] curry each ;

: def-callback-type ( callback -- )
    {
        [ return>> return-c-type ]
        [ c-type>> ]
        [ drop current-library get ]
        [ ?suffix-parameters-with-error parameter-names&types ]
    } cleave make-callback-type define-inline ;

GENERIC: field-type>c-type ( data-type -- c-type )

M: simple-type field-type>c-type type>c-type ;
M: inner-callback-type field-type>c-type drop void* ;
M: array-type field-type>c-type type>c-type ;

: field>struct-slot ( field -- slot )
    [ name>> ]
    [ dup bits>> [ drop uint ] [ type>> field-type>c-type ] if ]
    [
        [
            [ drop ] ! [ writable?>> [ read-only , ] unless ]
            [ bits>> [ bits: , , ] when* ] bi
        ] V{ } make
    ] tri <struct-slot-spec> ;

: def-record-type ( record -- )
    dup fields>>
    [
        [ c-type>> create-class-in ]
        [ fields>> [ field>struct-slot ] map ] bi
        define-struct-class
    ] [ c-type>> void def-c-type ] if ;

: def-record ( record -- )
    {
        [ def-record-type ]
        [ constructors>> def-functions ]
        [ functions>> def-functions ]
        [ [ methods>> ] keep def-methods ]
    } cleave ;

: def-union-type ( union -- )
    c-type>> void def-c-type ;

: private-record? ( record -- ? )
    {
        [ struct-for>> ]
        [ name>> "Class" tail? ]
        [ name>> "Private" tail? ]
        [ name>> "Iface" tail? ]
    } 1|| ;

: def-union ( union -- )
    {
        [ def-union-type ]
        [ constructors>> def-functions ]
        [ functions>> def-functions ]
        [ [ methods>> ] keep def-methods ]
    } cleave ;

: find-existing-boxed-type ( boxed -- type/f )
    c-type>> search [
        dup [ c-type? ] [ "c-type" word-prop ] bi or and*
    ] [ f ] if* ;

: def-boxed-type ( boxed -- )
    c-type>> void def-c-type ;

: signal-name ( signal type -- name )
    swap [ c-type>> ] [ name>> ] bi* ":" glue ;

: user-data-parameter ( -- parameter )
    parameter new
        "user_data" >>name
        "in" >>direction
        "none" >>transfer-ownership
        simple-type new "gpointer" >>name >>type ;

:: def-signal ( signal type -- )
    signal {
        [ return>> return-c-type ]
        [ type signal-name ]
        [ drop current-library get ]
        [
            parameters>> type type>parameter prefix
            user-data-parameter suffix parameter-names&types
        ]
    } cleave make-callback-type define-inline ;

: def-signals ( signals type -- )
    [ def-signal ] curry each ;

: def-class-type ( class -- )
    c-type>> void def-c-type ;

: def-class ( class -- )
    {
        [ def-class-type ]
        [ constructors>> def-functions ]
        [ functions>> def-functions ]
        [ [ methods>> ] keep def-methods ]
        [ [ signals>> ] keep def-signals ]
    } cleave ;

: def-interface-type ( interface -- )
    c-type>> void def-c-type ;

: def-interface ( class -- )
    {
        [ def-interface-type ]
        [ functions>> def-functions ]
        [ [ methods>> ] keep def-methods ]
        [ [ signals>> ] keep def-signals ]
    } cleave ;

: defer-enums ( enums -- ) enum-info defer-types ;
: defer-bitfields ( bitfields -- ) bitfield-info defer-types ;
: defer-unions ( unions -- ) union-info defer-types ;
: defer-callbacks ( callbacks -- ) callback-info defer-types ;
: defer-interfaces ( interfaces -- ) interface-info defer-types ;
: defer-classes ( class -- ) class-info defer-types ;

: defer-boxeds ( boxeds -- )
    [
        [
            [ find-existing-boxed-type ]
            [ c-type>> defer-c-type ] ?unless
        ]
        [ name>> qualified-name ] bi
        boxed-info new swap register-type
    ] each ;

: defer-records ( records -- )
    [ private-record? ] partition
    [ begin-private record-info defer-types end-private ]
    [ record-info defer-types ] bi* ;

: def-enums ( enums -- ) [ def-enum-type ] each ;
: def-bitfields ( bitfields -- ) [ def-bitfield-type ] each ;
: def-unions ( unions -- ) [ def-union ] each ;
: def-callbacks ( callbacks -- ) [ def-callback-type ] each ;
: def-interfaces ( interfaces -- ) [ def-interface ] each ;
: def-classes ( classes -- ) [ def-class ] each ;

: def-boxeds ( boxeds -- )
    [ find-existing-boxed-type ] reject
    [ def-boxed-type ] each ;

: def-records ( records -- )
    [ private-record? ] partition
    [ begin-private [ def-record ] each end-private ]
    [ [ def-record ] each ] bi* ;

: def-namespace ( namespace -- )
    {
        [ consts>> def-consts ]

        [ enums>> defer-enums ]
        [ bitfields>> defer-bitfields ]
        [ records>> defer-records ]
        [ unions>> defer-unions ]
        [ boxeds>> defer-boxeds ]
        [ callbacks>> defer-callbacks ]
        [ interfaces>> defer-interfaces ]
        [ classes>> defer-classes ]

        [ aliases>> def-aliases ]

        [ enums>> def-enums ]
        [ bitfields>> def-bitfields ]
        [ records>> def-records ]
        [ unions>> def-unions ]
        [ boxeds>> def-boxeds ]
        [ callbacks>> def-callbacks ]
        [ interfaces>> def-interfaces ]
        [ classes>> def-classes ]

        [ functions>> def-functions ]
    } cleave ;

: def-ffi-repository ( repository -- )
    namespace>> def-namespace ;
