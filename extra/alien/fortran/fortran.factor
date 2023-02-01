! (c) 2009 Joe Groff, see BSD license
USING: accessors alien alien.c-types alien.complex alien.data
alien.libraries alien.parser alien.strings arrays ascii assocs
byte-arrays combinators combinators.short-circuit effects
generalizations grouping io.encodings.ascii io.encodings.string
kernel lexer math math.parser namespaces ranges sequences
sequences.generalizations shuffle sorting splitting strings
vectors words ;
QUALIFIED-WITH: alien.c-types c
IN: alien.fortran

SINGLETONS: f2c-abi g95-abi gfortran-abi intel-unix-abi intel-windows-abi ;

TUPLE: bad-fortran-abi detail ;
C: <bad-fortran-abi> bad-fortran-abi

: alien>nstring ( alien len encoding -- string )
    [ memory>byte-array ] dip decode ;

ERROR: invalid-fortran-type type ;

DEFER: fortran-sig>c-sig
DEFER: fortran-ret-type>c-type
DEFER: fortran-arg-type>c-type
DEFER: fortran-name>symbol-name

SYMBOL: library-fortran-abis
SYMBOL: fortran-abi
library-fortran-abis [ H{ } clone ] initialize

<PRIVATE

: lowercase-name-with-underscore ( name -- name' )
    >lower "_" append ;
: lowercase-name-with-extra-underscore ( name -- name' )
    >lower CHAR: _ over member?
    [ "__" append ] [ "_" append ] if ;

HOOK: fortran-c-abi fortran-abi ( -- abi )
M: bad-fortran-abi fortran-c-abi cdecl ;
M: f2c-abi fortran-c-abi cdecl ;
M: g95-abi fortran-c-abi cdecl ;
M: gfortran-abi fortran-c-abi cdecl ;
M: intel-unix-abi fortran-c-abi cdecl ;
M: intel-windows-abi fortran-c-abi cdecl ;

HOOK: real-functions-return-double? fortran-abi ( -- ? )
M: f2c-abi real-functions-return-double? t ;
M: g95-abi real-functions-return-double? f ;
M: gfortran-abi real-functions-return-double? f ;
M: intel-unix-abi real-functions-return-double? f ;
M: intel-windows-abi real-functions-return-double? f ;

HOOK: complex-functions-return-by-value? fortran-abi ( -- ? )
M: f2c-abi complex-functions-return-by-value? f ;
M: g95-abi complex-functions-return-by-value? f ;
M: gfortran-abi complex-functions-return-by-value? t ;
M: intel-unix-abi complex-functions-return-by-value? f ;
M: intel-windows-abi complex-functions-return-by-value? f ;

HOOK: character(1)-maps-to-char? fortran-abi ( -- ? )
M: f2c-abi character(1)-maps-to-char? f ;
M: g95-abi character(1)-maps-to-char? f ;
M: gfortran-abi character(1)-maps-to-char? f ;
M: intel-unix-abi character(1)-maps-to-char? t ;
M: intel-windows-abi character(1)-maps-to-char? t ;

HOOK: mangle-name fortran-abi ( name -- name' )
M: f2c-abi mangle-name lowercase-name-with-extra-underscore ;
M: g95-abi mangle-name lowercase-name-with-extra-underscore ;
M: gfortran-abi mangle-name lowercase-name-with-underscore ;
M: intel-unix-abi mangle-name lowercase-name-with-underscore ;
M: intel-windows-abi mangle-name >upper ;

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
    dims>> [ product 2array ] when* ;

MACRO: size-case-type ( cases -- quot )
    [ invalid-fortran-type ] suffix
    '[ [ size>> _ case ] [ append-dimensions ] bi ] ;

: simple-type ( type base-c-type -- c-type )
    swap
    [ dup size>> [ invalid-fortran-type ] [ drop ] if ]
    [ append-dimensions ] bi ;

: new-fortran-type ( out? dims size class -- type )
    new [ [ size<< ] [ dims<< ] [ out?<< ] tri ] keep ;

GENERIC: (fortran-type>c-type) ( type -- c-type )

M: f (fortran-type>c-type) drop c:void ;

M: integer-type (fortran-type>c-type)
    {
        { f [ c:int      ] }
        { 1 [ c:char     ] }
        { 2 [ c:short    ] }
        { 4 [ c:int      ] }
        { 8 [ c:longlong ] }
    } size-case-type ;
M: real-type (fortran-type>c-type)
    {
        { f [ c:float  ] }
        { 4 [ c:float  ] }
        { 8 [ c:double ] }
    } size-case-type ;
M: real-complex-type (fortran-type>c-type)
    {
        {  f [ complex-float  ] }
        {  8 [ complex-float  ] }
        { 16 [ complex-double ] }
    } size-case-type ;

M: double-precision-type (fortran-type>c-type)
    c:double simple-type ;
M: double-complex-type (fortran-type>c-type)
    complex-double simple-type ;
M: misc-type (fortran-type>c-type)
    dup name>> parse-c-type simple-type ;

: single-char? ( character-type -- ? )
    { [ drop character(1)-maps-to-char? ] [ dims>> product 1 = ] } 1&& ;

: fix-character-type ( character-type -- character-type' )
    clone dup size>>
    [ dup dims>> [ invalid-fortran-type ] [ dup size>> 1array >>dims f >>size ] if ]
    [ dup dims>> [ ] [ f >>dims ] if ] if
    dup single-char? [ f >>dims ] when ;

M: character-type (fortran-type>c-type)
    fix-character-type c:char simple-type ;

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
    >lower fortran>c-types ?at
    [ new-fortran-type ] [ misc-type boa ] if ;

: parse-fortran-type ( fortran-type-string/f -- type/f )
    dup [ (parse-fortran-type) ] when ;

GENERIC: added-c-args ( type -- args )

M: fortran-type added-c-args drop { } ;
M: character-type added-c-args fix-character-type single-char? [ { } ] [ { c:long } ] if ;

GENERIC: returns-by-value? ( type -- ? )

M: f returns-by-value? drop t ;
M: fortran-type returns-by-value? drop f ;
M: number-type returns-by-value? dims>> not ;
M: character-type returns-by-value? fix-character-type single-char? ;
M: complex-type returns-by-value?
    { [ drop complex-functions-return-by-value? ] [ dims>> not ] } 1&& ;

GENERIC: (fortran-ret-type>c-type) ( type -- c-type )

M: f (fortran-ret-type>c-type) drop c:void ;
M: fortran-type (fortran-ret-type>c-type) (fortran-type>c-type) ;
M: real-type (fortran-ret-type>c-type)
    drop real-functions-return-double? [ c:double ] [ c:float ] if ;

GENERIC: (fortran-arg>c-args) ( type -- main-quot added-quot )

: args?dims ( type quot -- main-quot added-quot )
    [ dup dims>> [ drop [ ] [ drop ] ] ] dip if ; inline

M: integer-type (fortran-arg>c-args)
    [
        size>> {
            { f [ [ c:int <ref>     ] [ drop ] ] }
            { 1 [ [ c:char <ref>    ] [ drop ] ] }
            { 2 [ [ c:short <ref>   ] [ drop ] ] }
            { 4 [ [ c:int <ref>     ] [ drop ] ] }
            { 8 [ [ c:longlong <ref> ] [ drop ] ] }
            [ invalid-fortran-type ]
        } case
    ] args?dims ;

M: logical-type (fortran-arg>c-args)
    [ call-next-method [ [ 1 0 ? ] prepend ] dip ] args?dims ;

M: real-type (fortran-arg>c-args)
    [
        size>> {
            { f [ [ c:float <ref> ] [ drop ] ] }
            { 4 [ [ c:float <ref> ] [ drop ] ] }
            { 8 [ [ c:double <ref> ] [ drop ] ] }
            [ invalid-fortran-type ]
        } case
    ] args?dims ;

M: real-complex-type (fortran-arg>c-args)
    [
        size>> {
            {  f [ [ <complex-float>  ] [ drop ] ] }
            {  8 [ [ <complex-float>  ] [ drop ] ] }
            { 16 [ [ <complex-double> ] [ drop ] ] }
            [ invalid-fortran-type ]
        } case
    ] args?dims ;

M: double-precision-type (fortran-arg>c-args)
    [ drop [ c:double <ref> ] [ drop ] ] args?dims ;

M: double-complex-type (fortran-arg>c-args)
    [ drop [ <complex-double> ] [ drop ] ] args?dims ;

M: character-type (fortran-arg>c-args)
    fix-character-type single-char?
    [ [ first c:char <ref> ] [ drop ] ]
    [ [ ascii string>alien ] [ length ] ] if ;

M: misc-type (fortran-arg>c-args)
    drop [ ] [ drop ] ;

GENERIC: (fortran-result>) ( type -- quots )

: result?dims ( type quot -- quot )
    [ dup dims>> [ drop { [ ] } ] ] dip if ; inline

M: integer-type (fortran-result>)
    [
        size>> {
            { f [ { [ c:int deref      ] } ] }
            { 1 [ { [ c:char deref     ] } ] }
            { 2 [ { [ c:short deref    ] } ] }
            { 4 [ { [ c:int deref      ] } ] }
            { 8 [ { [ c:longlong deref ] } ] }
            [ invalid-fortran-type ]
        } case
    ] result?dims ;

M: logical-type (fortran-result>)
    [ call-next-method first [ zero? not ] append 1array ] result?dims ;

M: real-type (fortran-result>)
    [ size>> {
        { f [ { [ c:float deref ] } ] }
        { 4 [ { [ c:float deref ] } ] }
        { 8 [ { [ c:double deref ] } ] }
        [ invalid-fortran-type ]
    } case ] result?dims ;

M: real-complex-type (fortran-result>)
    [ size>> {
        {  f [ { [ *complex-float  ] } ] }
        {  8 [ { [ *complex-float  ] } ] }
        { 16 [ { [ *complex-double ] } ] }
        [ invalid-fortran-type ]
    } case ] result?dims ;

M: double-precision-type (fortran-result>)
    [ drop { [ c:double deref ] } ] result?dims ;

M: double-complex-type (fortran-result>)
    [ drop { [ *complex-double ] } ] result?dims ;

M: character-type (fortran-result>)
    fix-character-type single-char?
    [ { [ c:char deref 1string ] } ]
    [ { [ ] [ ascii alien>nstring ] } ] if ;

M: misc-type (fortran-result>)
    drop { [ ] } ;

GENERIC: (<fortran-result>) ( type -- quot )

M: fortran-type (<fortran-result>)
    (fortran-type>c-type) \ heap-size \ <byte-array> [ ] 3sequence ;

M: character-type (<fortran-result>)
    fix-character-type dims>> product dup
    [ \ <byte-array> ] dip [ ] 3sequence ;

: [<fortran-result>] ( return parameters -- quot )
    [ parse-fortran-type ] dip
    over returns-by-value?
    [ 2drop [ ] ]
    [ [ (<fortran-result>) ] [ length \ ndip [ ] 3sequence ] bi* ] if ;

: [fortran-args>c-args] ( parameters -- quot )
    [ [ ] ] [
        [ parse-fortran-type (fortran-arg>c-args) 2array ] map flip first2
        [ [ \ spread [ ] 2sequence ] bi@ 2array ] [ length ] bi
        \ ncleave [ ] 3sequence
    ] if-empty ;

:: [fortran-invoke] ( [args>args] return library function parameters -- [args>args] quot )
    return parameters fortran-sig>c-sig :> ( c-return c-parameters )
    function fortran-name>symbol-name :> c-function
    [args>args]
    c-return library c-function c-parameters f \ alien-invoke
    6 [ ] nsequence
    c-parameters length \ nkeep
    [ ] 3sequence ;

: [fortran-out-param>] ( parameter -- quot )
    parse-fortran-type
    [ (fortran-result>) ] [ out?>> ] bi
    [ ] [ [ drop [ drop ] ] map ] if ;

: [fortran-return>] ( return -- quot )
    parse-fortran-type {
        { [ dup not ] [ drop { } ] }
        { [ dup returns-by-value? ] [ drop { [ ] } ] }
        [ (fortran-result>) ]
    } cond ;

: letters ( -- seq ) CHAR: a CHAR: z [a..b] ;

: (shuffle-map) ( return parameters -- ret par )
    [
        fortran-ret-type>c-type length swap void? [ 1 + ] unless
        letters swap head [ "ret" swap suffix ] map
    ] [
        [ fortran-arg-type>c-type nip length 1 + ] map letters swap zip
        [ first2 letters swap head [ "" 2sequence ] with map ] map concat
    ] bi* ;

: (fortran-in-shuffle) ( ret par -- seq )
    [ second ] sort-by append ;

: (fortran-out-shuffle) ( ret par -- seq )
    append ;

: [fortran-result-shuffle] ( return parameters -- quot )
    (shuffle-map) [ (fortran-in-shuffle) ] [ (fortran-out-shuffle) ] 2bi <effect>
    \ shuffle-effect [ ] 2sequence ;

: [fortran-results>] ( return parameters -- quot )
    [ [fortran-result-shuffle] ]
    [ drop [fortran-return>] ]
    [ nip [ [fortran-out-param>] ] map concat ] 2tri
    append
    \ spread [ ] 2sequence append ;

: (add-fortran-library) ( fortran-abi name -- )
    library-fortran-abis get-global set-at ;

PRIVATE>

: add-fortran-library ( name soname fortran-abi -- )
    [ fortran-abi [ fortran-c-abi ] with-variable add-library ]
    [ nip swap (add-fortran-library) ] 3bi ;

: fortran-name>symbol-name ( fortran-name -- c-name )
    mangle-name ;

: fortran-type>c-type ( fortran-type -- c-type )
    parse-fortran-type (fortran-type>c-type) ;

: fortran-arg-type>c-type ( fortran-type -- c-type added-args )
    parse-fortran-type
    [ (fortran-type>c-type) <pointer> ]
    [ added-c-args ] bi ;
: fortran-ret-type>c-type ( fortran-type -- c-type added-args )
    parse-fortran-type dup returns-by-value?
    [ (fortran-ret-type>c-type) { } ] [
        c:void swap
        [ added-c-args ] [ (fortran-type>c-type) <pointer> ] bi prefix
    ] if ;

: fortran-arg-types>c-types ( fortran-types -- c-types )
    [ length <vector> 1 <vector> ] keep
    [ fortran-arg-type>c-type swapd [ suffix! ] [ append! ] 2bi* ] each
    append >array ;

: fortran-sig>c-sig ( fortran-return fortran-args -- c-return c-args )
    [ fortran-ret-type>c-type ] [ fortran-arg-types>c-types ] bi* append ;

: set-fortran-abi ( library -- )
    library-fortran-abis get-global at fortran-abi set ;

: ((fortran-invoke)) ( return library function parameters -- quot )
    {
        [ 2nip [<fortran-result>] ]
        [ 3nip [fortran-args>c-args] ]
        [ [fortran-invoke] ]
        [ 2nip [fortran-results>] ]
    } 4 ncleave 4 nappend ;

:: (fortran-invoke) ( return library function parameters -- quot )
    library library-fortran-abis get-global at dup bad-fortran-abi?
    [ '[ _ throw ] ]
    [ drop return library function parameters ((fortran-invoke)) ] if ;

MACRO: fortran-invoke ( return library function parameters -- quot )
    { [ 2drop nip set-fortran-abi ] [ (fortran-invoke) ] } 4 ncleave ;

: parse-arglist ( parameters return -- types effect )
    [
        2 group
        [ unzip [ "," ?tail drop ] map ]
        [ [ first "!" head? ] filter [ second "," ?tail drop "'" append ] map ] bi
    ] [ [ ] [ prefix ] if-void ]
    bi* <effect> ;

:: define-fortran-function ( return library function parameters -- )
    function create-function
    return library function parameters return [ c:void ] unless* parse-arglist
    [ \ fortran-invoke 5 [ ] nsequence ] dip define-declared ;

SYNTAX: SUBROUTINE:
    f current-library get scan-token ")" parse-tokens
    [ "()" subseq? ] reject define-fortran-function ;

SYNTAX: FUNCTION:
    scan-token current-library get scan-token ")" parse-tokens
    [ "()" subseq? ] reject define-fortran-function ;

SYNTAX: LIBRARY:
    scan-token
    [ current-library set ]
    [ set-fortran-abi ] bi ;
