! (c) 2009 Joe Groff, see BSD license
USING: accessors alien alien.c-types alien.structs alien.syntax
arrays ascii assocs combinators fry kernel lexer macros math.parser
namespaces parser sequences splitting vectors vocabs.parser locals
io.encodings.ascii io.encodings.string ;
IN: alien.fortran

! XXX this currently only supports the gfortran/f2c abi.
! XXX we should also support ifort at some point for commercial BLASes

: alien>nstring ( alien len encoding -- string )
    [ memory>byte-array ] dip decode ;

: fortran-name>symbol-name ( fortran-name -- c-name )
    >lower CHAR: _ over member? 
    [ "__" append ] [ "_" append ] if ;

ERROR: invalid-fortran-type type ;

DEFER: fortran-sig>c-sig

<PRIVATE

TUPLE: fortran-type dims size out? ;

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
    { "double-precision" double-precision-type }
    { "complex"          real-complex-type     }
    { "double-complex"   double-complex-type   }
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

: new-fortran-type ( out? dims size class -- type )
    new [ [ (>>size) ] [ (>>dims) ] [ (>>out?) ] tri ] keep ;

GENERIC: (fortran-type>c-type) ( type -- c-type )

M: f (fortran-type>c-type) drop "void" ;

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
M: real-complex-type (fortran-type>c-type)
    {
        {  f [ "complex-float"  ] }
        {  8 [ "complex-float"  ] }
        { 16 [ "complex-double" ] }
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

: parse-out ( string -- string' out? )
    "!" ?head ;

: parse-dims ( string -- string' dim )
    "(" split1 dup
    [ ")" ?tail drop "," split [ [ blank? ] trim dimension>number ] map ] when ;

: parse-size ( string -- string' size )
    "*" split1 dup [ string>number ] when ;

: (parse-fortran-type) ( fortran-type-string -- type )
    parse-out swap parse-dims swap parse-size swap
    dup >lower fortran>c-types at*
    [ nip new-fortran-type ] [ drop f misc-type boa ] if ;

: parse-fortran-type ( fortran-type-string/f -- type/f )
    dup [ (parse-fortran-type) ] when ;

: c-type>pointer ( c-type -- c-type* )
    "[" split1 drop "*" append ;

GENERIC: added-c-args ( type -- args )

M: fortran-type added-c-args drop { } ;
M: character-type added-c-args drop { "long" } ;

GENERIC: returns-by-value? ( type -- ? )

M: f returns-by-value? drop t ;
M: fortran-type returns-by-value? drop f ;
M: number-type returns-by-value? dims>> not ;
M: complex-type returns-by-value? drop f ;

GENERIC: (fortran-ret-type>c-type) ( type -- c-type )

M: f (fortran-ret-type>c-type) drop "void" ;
M: fortran-type (fortran-ret-type>c-type) (fortran-type>c-type) ;
M: real-type (fortran-ret-type>c-type) drop "double" ;

: suffix! ( seq   elt   -- seq   ) over push     ; inline
: append! ( seq-a seq-b -- seq-a ) over push-all ; inline

GENERIC: (fortran-arg>c-args) ( type -- main-quot added-quot )

M: integer-type (fortran-arg>c-args)
    size>> {
        { f [ [ <int>      ] [ drop ] ] }
        { 1 [ [ <char>     ] [ drop ] ] }
        { 2 [ [ <short>    ] [ drop ] ] }
        { 4 [ [ <int>      ] [ drop ] ] }
        { 8 [ [ <longlong> ] [ drop ] ] }
        [ invalid-fortran-type ]
    } case ;

M: logical-type (fortran-arg>c-args)
    call-next-method [ [ 1 0 ? ] prepend ] dip ;

M: real-type (fortran-arg>c-args)
    size>> {
        { f [ [ <float>  ] [ drop ] ] }
        { 4 [ [ <float>  ] [ drop ] ] }
        { 8 [ [ <double> ] [ drop ] ] }
        [ invalid-fortran-type ]
    } case ;

M: real-complex-type (fortran-arg>c-args)
    size>> {
        {  f [ [ <complex-float>  ] [ drop ] ] }
        {  8 [ [ <complex-float>  ] [ drop ] ] }
        { 16 [ [ <complex-double> ] [ drop ] ] }
        [ invalid-fortran-type ]
    } case ;

M: double-precision-type (fortran-arg>c-args)
    drop [ <double> ] [ drop ] ;

M: double-complex-type (fortran-arg>c-args)
    drop [ <complex-double> ] [ drop ] ;

M: character-type (fortran-arg>c-args)
    drop [ ascii string>alien ] [ length ] ;

M: misc-type (fortran-arg>c-args)
    drop [ ] [ drop ] ;

GENERIC: (fortran-result>) ( type -- quot )

M: integer-type (fortran-result>)
    size>> {
        { f [ [ *int      ] ] }
        { 1 [ [ *char     ] ] }
        { 2 [ [ *short    ] ] }
        { 4 [ [ *int      ] ] }
        { 8 [ [ *longlong ] ] }
        [ invalid-fortran-type ]
    } case ;

M: logical-type (fortran-result>)
    call-next-method [ zero? not ] append ;

M: real-type (fortran-result>)
    size>> {
        { f [ [ *float  ] ] }
        { 4 [ [ *float  ] ] }
        { 8 [ [ *double ] ] }
        [ invalid-fortran-type ]
    } case ;

M: real-complex-type (fortran-result>)
    size>> {
        {  f [ [ *complex-float  ] ] }
        {  8 [ [ *complex-float  ] ] }
        { 16 [ [ *complex-double ] ] }
        [ invalid-fortran-type ]
    } case ;

M: double-precision-type (fortran-result>)
    drop [ *double ] ;

M: double-complex-type (fortran-result>)
    drop [ *complex-double ] ;

M: character-type (fortran-result>)
    drop [ ascii alien>nstring ] ;

M: misc-type (fortran-result>)
    drop [ ] ;

GENERIC: (<fortran-result>) ( type -- quot )

M: fortran-type (<fortran-result>) 
    (fortran-type>c-type) '[ _ <c-object> ] ;

: [<fortran-result>] ( return parameters -- quot )
    [ parse-fortran-type ] dip
    over returns-by-value?
    [ 2drop [ ] ]
    [ [ (<fortran-result>) ] [ '[ _ _ ndip ] ] bi* ] if ;

: [fortran-args>c-args] ( parameters -- quot )
    [ parse-fortran-type (fortran-arg>c-args) 2array ] map flip first2
    [ [ '[ _ spread ] ] bi@ 2array ] [ length ] bi 
    '[ _ _ ncleave ] ;

:: [fortran-invoke] ( return library function parameters -- quot ) 
    return parameters fortran-sig>c-sig :> c-parameters :> c-return
    function fortran-name>symbol-name :> c-function
    [ c-return library c-function c-parameters alien-invoke ] ;

: [fortran-results>] ( return parameters -- quot )
    2drop [ ] ;

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

: define-fortran-record ( name vocab fields -- )
    [ >lower ] [ ] [ fortran-record>c-struct ] tri* define-struct ;

: RECORD: scan in get parse-definition define-fortran-record ; parsing

MACRO: fortran-invoke ( return library function parameters -- )
    {
        [ 2nip [<fortran-result>] ]
        [ nip nip nip [fortran-args>c-args] ]
        [ [fortran-invoke] ]
        [ 2nip [fortran-results>] ]
    } 4 ncleave 3append ;

:: define-fortran-function ( return library function parameters -- )
    function create-in dup reset-generic 
    return library function parameters return parse-arglist
    [ '[ _ _ _ _ fortran-invoke ] ] dip define-declared ;

: SUBROUTINE: 
    f "c-library" get scan ";" parse-tokens
    [ "()" subseq? not ] filter define-fortran-function ; parsing
: FUNCTION:
    scan "c-library" get scan ";" parse-tokens
    [ "()" subseq? not ] filter define-fortran-function ; parsing

