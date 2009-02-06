USING: accessors alien alien.c-types alien.structs alien.syntax
arrays ascii assocs combinators fry kernel lexer macros math.parser
namespaces parser sequences splitting vectors vocabs.parser ;
IN: alien.fortran

! XXX this currently only supports the gfortran/f2c abi.
! XXX we should also support ifort at some point for commercial BLASes

C-STRUCT: (fortran-complex)
    { "float" "r" }
    { "float" "i" } ;
C-STRUCT: (fortran-double-complex)
    { "double" "r" }
    { "double" "i" } ;

: fortran-c-abi ( -- abi ) "cdecl" ;

: fortran-name>symbol-name ( fortran-name -- c-name )
    >lower CHAR: _ over member? 
    [ "__" append ] [ "_" append ] if ;

ERROR: invalid-fortran-type type ;

<PRIVATE

TUPLE: fortran-type dims size ;

TUPLE: number-type < fortran-type ;
TUPLE: integer-type < number-type ;
TUPLE: logical-type < integer-type ;
TUPLE: real-type < number-type ;
TUPLE: double-precision-type < number-type ;

TUPLE: character-type < fortran-type ;
TUPLE: misc-type < fortran-type name ;

TUPLE: complex-type < number-type ;
TUPLE: real-complex-type < complex-type ;
TUPLE: double-complex-type < complex-type ;

CONSTANT: fortran>c-types H{
    { "character"        character-type        }
    { "integer"          integer-type          }
    { "logical"          logical-type          }
    { "real"             real-type             }
    { "double precision" double-precision-type }
    { "complex"          real-complex-type     }
    { "double complex"   double-complex-type   }
}

: append-dimensions ( base-c-type type -- c-type )
    dims>>
    [ product number>string "[" "]" surround append ] when* ;

MACRO: size-case-type ( cases -- )
    [ invalid-fortran-type ] suffix
    '[ [ size>> _ case ] [ append-dimensions ] bi ] ;

: simple-type ( type base-c-type -- c-type )
    swap
    [ dup size>> [ invalid-fortran-type ] [ drop ] if ]
    [ append-dimensions ] bi ;

: new-fortran-type ( dims size class -- type )
    new [ (>>size) ] [ (>>dims) ] [ ] tri ;

GENERIC: (fortran-type>c-type) ( type -- c-type )

M: f (fortran-type>c-type) ;

M: integer-type (fortran-type>c-type)
    {
        { f [ "int"      ] }
        { 1 [ "char"     ] }
        { 2 [ "short"    ] }
        { 4 [ "int"      ] }
        { 8 [ "longlong" ] }
    } size-case-type ;
M: real-type (fortran-type>c-type)
    {
        { f [ "float"  ] }
        { 4 [ "float"  ] }
        { 8 [ "double" ] }
    } size-case-type ;
M: complex-type (fortran-type>c-type)
    {
        {  f [ "(fortran-complex)"        ] }
        {  8 [ "(fortran-complex)"        ] }
        { 16 [ "(fortran-double-complex)" ] }
    } size-case-type ;

M: double-precision-type (fortran-type>c-type)
    "double" simple-type ;
M: double-complex-type (fortran-type>c-type)
    "(fortran-double-complex)" simple-type ;
M: misc-type (fortran-type>c-type)
    dup name>> simple-type ;

: fix-character-type ( character-type -- character-type' )
    clone dup size>>
    [ dup dims>> [ invalid-fortran-type ] [ dup size>> 1array >>dims f >>size ] if ]
    [ dup dims>> [ ] [ { 1 } >>dims ] if ] if ;

M: character-type (fortran-type>c-type)
    fix-character-type "char" simple-type ;

: dimension>number ( string -- number )
    dup "*" = [ drop 0 ] [ string>number ] if ;

: parse-dims ( string -- string' dim )
    "(" split1 dup
    [ ")" ?tail drop "," split [ [ blank? ] trim dimension>number ] map ] when ;

: parse-size ( string -- string' size )
    "*" split1 dup [ string>number ] when ;

: parse-fortran-type ( fortran-type-string -- type )
    parse-dims swap parse-size swap
    dup >lower fortran>c-types at*
    [ nip new-fortran-type ] [ drop misc-type boa ] if ;

: c-type>pointer ( c-type -- c-type* )
    "[" split1 drop "*" append ;

GENERIC: added-c-args ( type -- args )

M: fortran-type added-c-args drop { } ;
M: character-type added-c-args drop { "long" } ;

GENERIC: added-c-arg-values ( type -- arg-values )

M: fortran-type added-c-arg-values drop { } ;
M: character-type added-c-arg-values
    fix-character-type dims>> first 1array ;

GENERIC: returns-by-value? ( type -- ? )

M: fortran-type returns-by-value? drop f ;
M: number-type returns-by-value? dims>> not ;
M: complex-type returns-by-value? drop f ;

GENERIC: (fortran-ret-type>c-type) ( type -- c-type )

M: fortran-type (fortran-ret-type>c-type) (fortran-type>c-type) ;
M: real-type (fortran-ret-type>c-type) drop "double" ;

: suffix! ( seq   elt   -- seq   ) over push     ; inline
: append! ( seq-a seq-b -- seq-a ) over push-all ; inline

PRIVATE>

: fortran-type>c-type ( fortran-type -- c-type )
    parse-fortran-type (fortran-type>c-type) ;

: fortran-arg-type>c-type ( fortran-type -- c-type added-args )
    parse-fortran-type
    [ (fortran-type>c-type) c-type>pointer ]
    [ added-c-args ] bi ;
: fortran-ret-type>c-type ( fortran-type -- c-type added-args )
    parse-fortran-type dup returns-by-value?
    [ (fortran-ret-type>c-type) { } ] [
        "void" swap 
        [ added-c-args ] [ (fortran-ret-type>c-type) c-type>pointer ] bi prefix
    ] if ;

: fortran-arg-types>c-types ( fortran-types -- c-types )
    [ length <vector> 1 <vector> ] keep
    [ fortran-arg-type>c-type swapd [ suffix! ] [ append! ] 2bi* ] each
    append >array ;

: fortran-sig>c-sig ( fortran-return fortran-args -- c-return c-args )
    [ fortran-ret-type>c-type ] [ fortran-arg-types>c-types ] bi* append ;

: fortran-record>c-struct ( record -- struct )
    [ first2 [ fortran-type>c-type ] [ >lower ] bi* 2array ] map ;

: define-record ( name vocab fields -- )
    [ >lower ] [ ] [ fortran-record>c-struct ] tri* define-struct ;

: F-RECORD: scan in get parse-definition define-record ; parsing
! : F-SUBROUTINE: ... ; parsing
! : F-FUNCTION: ... ; parsing

