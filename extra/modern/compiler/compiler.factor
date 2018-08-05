! Copyright (C) 2017 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators
combinators.short-circuit combinators.smart constructors fry
kernel lexer math math.parser modern namespaces sequences sets
splitting strings ;
IN: modern.compiler

<<
INITIALIZED-SYMBOL: left-decorators [ HS{ } clone ]
>>
<<
: make-left-decorator ( string -- )
    left-decorators get adjoin ;

>>
<<
SYNTAX: \LEFT-DECORATOR: scan-token make-left-decorator ;
>>

LEFT-DECORATOR: delimiter
LEFT-DECORATOR: deprecated
LEFT-DECORATOR: final
LEFT-DECORATOR: flushable
LEFT-DECORATOR: foldable
LEFT-DECORATOR: inline
LEFT-DECORATOR: recursive

: left-decorator? ( obj -- ? )
    left-decorators get in? ;

<<
! Initialize with : foo ( -- ) .. ; already
INITIALIZED-SYMBOL: arities [ H{ } clone 2 "" pick set-at ]
>>
<<
: make-arity ( n string -- )
    arities get set-at ;
>>
<<
SYNTAX: \ARITY:
    scan-token
    scan-token string>number swap make-arity ;
>>

ARITY: \ABOUT: 1
ARITY: \ALIAS: 2
ARITY: \ARITY: 2
ARITY: \B: 1
ARITY: \BUILTIN: 1
ARITY: \CONSTANT: 2
ARITY: \DEFER: 1
ARITY: \FORGET: 1
ARITY: \GENERIC#: 3
ARITY: \GENERIC: 2
ARITY: \LEFT-DECORATOR: 1
ARITY: \HOOK: 3
ARITY: \IN: 1
ARITY: \INSTANCE: 2
ARITY: \MAIN: 1
ARITY: \MATH: 1
ARITY: \MIXIN: 1
ARITY: \PRIMITIVE: 2
ARITY: \QUALIFIED-WITH: 2
ARITY: \QUALIFIED: 1
ARITY: \RENAME: 3
ARITY: \SINGLETON: 1
ARITY: \SLOT: 1
ARITY: \SOLUTION: 1
ARITY: \SYMBOL: 1
ARITY: \UNUSE: 1
ARITY: \USE: 1

ARITY: \MEMO: 2
ARITY: \: 2

! ARITY: \USING: 0

: get-arity ( string -- n/f )
    arities get at ;

<<
INITIALIZED-SYMBOL: variable-arities [ H{ } clone ]
>>
<<
: make-variable-arity ( n string -- )
    variable-arities get set-at ;
>>
<<
SYNTAX: \VARIABLE-ARITY: scan-token scan-token swap make-arity ;
>>

VARIABLE-ARITY: \EXCLUDE: 2
VARIABLE-ARITY: \FROM: 2
VARIABLE-ARITY: \INTERSECTION: 1
VARIABLE-ARITY: \PREDICATE: 3
VARIABLE-ARITY: \SYNTAX: 1
VARIABLE-ARITY: \TUPLE: 1
VARIABLE-ARITY: \UNION: 1
VARIABLE-ARITY: \WORD: 2

VARIABLE-ARITY: \<CLASS: 3
VARIABLE-ARITY: \<FUNCTOR: 2


TUPLE: vocabulary-root uri path ;
CONSTRUCTOR: <vocabulary-root> vocabulary-root ( uri path -- obj ) ;

TUPLE: vocabulary name words main ;
CONSTRUCTOR: <vocabulary> vocabulary ( name -- obj )
    H{ } clone >>words ;

CONSTANT: core-root T{ vocabulary-root f "git@github.com:factor/factor" "core/" }
CONSTANT: basis-root T{ vocabulary-root f "git@github.com:factor/factor" "basis/" }
CONSTANT: extra-root T{ vocabulary-root f "git@github.com:factor/factor" "extra/" }

: syntax-vocabulary ( -- vocabulary )
    "syntax" <vocabulary> ;

TUPLE: word name effect quot ;

: add-word ( word vocabulary -- )
    [ dup name>> ] [ words>> ] bi* set-at ;


: find-sections ( literals -- sections )
    [ ?first section-open? ] filter ;

DEFER: map-literals
: map-literal ( obj quot: ( obj -- obj' ) -- obj )
    over { [ array? ] [ ?first section-open? ] } 1&& [
        [ first3 swap ] dip map-literals swap 3array
    ] [
        call
    ] if ; inline recursive

: map-literals ( seq quot: ( obj -- obj' ) -- seq' )
    '[ _ map-literal ] map ; inline recursive


DEFER: map-literals!
: map-literal! ( obj quot: ( obj -- obj' ) -- obj )
    over { [ array? ] [ ?first section-open? ] } 1&& [
        [ call drop ] [
            map-literals!
        ] 2bi
    ] [
        call
    ] if ; inline recursive

: map-literals! ( seq quot: ( obj -- obj' ) -- seq )
    '[ _ map-literal! ] map! ; inline recursive

TUPLE: lexed tokens ;

TUPLE: comment < lexed payload ;
CONSTRUCTOR: <comment> comment ( tokens payload -- obj ) ;

TUPLE: escaped-identifier < lexed name ;
CONSTRUCTOR: <escaped-identifier> escaped-identifier ( tokens name -- obj ) ;

TUPLE: escaped-object < lexed name payload ;
CONSTRUCTOR: <escaped-object> escaped-object ( tokens name payload -- obj ) ;

TUPLE: section < lexed tag payload ;
CONSTRUCTOR: <section> section ( tokens tag payload -- obj ) ;

TUPLE: named-section < lexed tag name payload ;
CONSTRUCTOR: <named-section> named-section ( tokens tag name payload -- obj ) ;

TUPLE: upper-colon < lexed tag payload ;
CONSTRUCTOR: <upper-colon> upper-colon ( tokens tag payload -- obj ) ;

TUPLE: lower-colon < lexed tag payload ;
CONSTRUCTOR: <lower-colon> lower-colon ( tokens tag payload -- obj ) ;

TUPLE: matched < lexed tag payload ;
CONSTRUCTOR: <matched> matched ( tokens tag payload -- obj ) ;

TUPLE: single-bracket < matched ;
CONSTRUCTOR: <single-bracket> single-bracket ( tokens tag payload -- obj ) ;

TUPLE: double-bracket < matched ;
CONSTRUCTOR: <double-bracket> double-bracket ( tokens tag payload -- obj ) ;


TUPLE: single-brace < matched ;
CONSTRUCTOR: <single-brace> single-brace ( tokens tag payload -- obj ) ;

TUPLE: double-brace < matched ;
CONSTRUCTOR: <double-brace> double-brace ( tokens tag payload -- obj ) ;


TUPLE: single-paren < matched ;
CONSTRUCTOR: <single-paren> single-paren ( tokens tag payload -- obj ) ;

TUPLE: double-paren < matched ;
CONSTRUCTOR: <double-paren> double-paren ( tokens tag payload -- obj ) ;


TUPLE: double-quote < matched ;
CONSTRUCTOR: <double-quote> double-quote ( tokens tag payload -- obj ) ;


TUPLE: identifier < lexed name ;
CONSTRUCTOR: <identifier> identifier ( tokens name -- obj ) ;

ERROR: unknown-literal tokens ;

DEFER: literal>tuple
: literal>tuple* ( obj -- tuple )
    {
        ! Comment has to be first
        { [ dup ?first "!" head? ] [
            [ ] [ ?second >string ] bi <comment>
        ] }

        ! Must be before escaped-identifier so that ``\ foo`` works
        { [ dup ?first "\\" tail? ] [
            [ ] [ ?first >string ] [ ?second ] tri <escaped-object>
        ] }

        { [ dup ?first "\\" head? ] [
            [ ] [ ?second >string ] bi <escaped-identifier>
        ] }

        { [ dup ?first section-open? ] [
            dup first ":" tail? [
                { [ ] [ first "<" ?head drop ":" ?tail drop ] [ ?second ?first >string ] [ ?second dup length 0 > [ rest dup [ [ literal>tuple ] map ] when ] when ] } cleave <named-section>
            ] [
                [ ] [ first "<" ?head drop ] [ rest but-last ?first dup [ [ literal>tuple ] map ] when ] tri <section>
            ] if
        ] }
        { [ dup { [ ?first ":" tail? ] [ ?first strict-upper? ] } 1&& ] [
            ! : .. ;  FOO: ;
            [ ] [ ?first ":" ?tail drop ] [ rest dup ?last ";" tail? [ but-last ] when ?first dup [ [ literal>tuple ] map ] when ] tri <upper-colon>
        ] }
        { [ dup ?first ":" tail? ] [
            ! foo: 123
            [ ] [ ?first >string ] [ second literal>tuple ] tri <lower-colon>
        ] }
        { [ dup ?first "\"" tail? ] [
            [ ] [ ?first >string ] [ second >string ] tri <double-quote>
        ] }
        { [ dup ?first "[" tail? ] [
            [ ] [ ?first "[" ?tail drop ] [ rest but-last ?first dup [ [ literal>tuple ] map ] when ] tri <single-bracket>
        ] }
        { [ dup ?first "{" tail? ] [
            [ ] [ ?first "{" ?tail drop ] [ rest but-last ?first dup [ [ literal>tuple ] map ] when ] tri <single-brace>
        ] }
        { [ dup ?first "(" tail? ] [
            [ ] [ ?first "(" ?tail drop ] [ rest but-last ?first dup [ [ literal>tuple ] map ] when ] tri <single-paren>
        ] }
        { [ dup ?second "[" head? ] [
            [ ] [ ?first ] [ 2 tail but-last ] tri <double-bracket>
        ] }
        { [ dup ?second "{" head? ] [
            [ ] [ ?first ] [ 2 tail but-last ] tri <double-brace>
        ] }
        { [ dup ?second "(" head? ] [
            [ ] [ ?first ] [ 2 tail but-last ] tri <double-paren>
        ] }

        { [ dup array? ] [ [ literal>tuple ] map ] }

        [ unknown-literal ]
    } cond ;

: literal>tuple ( obj -- tuple )
    dup { [ slice? ] [ string? ] } 1|| [
        [ ] [ >string ] bi <identifier>
    ] [
        literal>tuple*
    ] if ;

: literals>tuples ( seq -- seq' )
    [ literal>tuple ] map ;

: vocab>tuples ( path -- seq )
    vocab>literals literals>tuples ;

: string>tuples ( string -- seq )
    string>literals literals>tuples ;

: literals>vocabulary ( literals -- vocabulary )
    ;


![[
GENERIC: tuple>string ( obj -- string )

M: sequence tuple>string
    [ tuple>string ] map " " join ;

M: upper-colon tuple>string
    [
        {
            [ tag>> ": " ]
            [ payload>> [ tuple>string ] map " " join ]
            [ drop " ;" ]
        } cleave
    ] "" append-outputs-as ;

M: identifier tuple>string name>> ;
]]

TUPLE: compilation-unit ;

GENERIC: tuple>identifiers ( obj -- obj' )

M: comment tuple>identifiers drop f ;

M: identifier tuple>identifiers drop f ;
M: lower-colon tuple>identifiers drop f ;
M: escaped-object tuple>identifiers drop f ;
M: double-quote tuple>identifiers drop f ;
M: single-bracket tuple>identifiers drop f ;
M: single-brace tuple>identifiers drop f ;
M: single-paren tuple>identifiers drop f ;
M: double-bracket tuple>identifiers drop f ;
M: double-brace tuple>identifiers drop f ;
M: double-paren tuple>identifiers drop f ;

M: section tuple>identifiers
    payload>> [ tuple>identifiers ] map concat 1array ;

M: named-section tuple>identifiers
    payload>> [ tuple>identifiers ] map concat 1array ;

ERROR: upper-colon-identifer-expected obj ;
ERROR: unknown-upper-colon upper-colon string ;
M: upper-colon tuple>identifiers
    [ ] [ payload>> ] [ tag>> ] tri {
        ! { "" [ ?first name>> ] }
        ! { "TUPLE" [ ?first name>> ] }
        ! make the default one ?first
        { "USE" [ drop f ] }
        { "USING" [ drop f ] }
        { "IN" [ drop f ] }
        { "M" [ drop f ] }
        { "FROM" [ drop f ] }
        { "LIBRARY" [ drop f ] }
        { "INSTANCE" [ drop f ] }
        { "ARTICLE" [ drop f ] } ! TODO: Should be a word imo
        { "ABOUT" [ drop f ] } ! TODO: Should be a word imo
        { "ROMAN-OP" [ ?first name>> "roman" prepend 1array ] }
        { "TYPEDEF" [ ?second name>> 1array ] }
        { "FUNCTION" [ ?second name>> 1array ] }
        { "GL-FUNCTION" [ ?second name>> 1array ] }
        { "TUPLE" [ ?first name>> [ ] [ "?" append ] bi 2array ] }
        { "UNION" [ ?first name>> [ ] [ "?" append ] bi 2array ] }
        { "ERROR" [ ?first name>> [ ] [ "?" append ] bi 2array ] }
        { "BUILTIN" [ ?first name>> [ ] [ "?" append ] bi 2array ] }
        { "SINGLETON" [ ?first name>> [ ] [ "?" append ] bi 2array ] }
        { "SINGLETONS" [
            [ name>> [ ] [ "?" append ] bi 2array ] map concat
        ] }
        { "MIXIN" [ ?first name>> [ ] [ "?" append ] bi 2array ] }
        { "PREDICATE" [ ?first name>> [ ] [ "?" append ] bi 2array ] }
        { "C-TYPE" [ ?first name>> [ ] [ "?" append ] bi 2array ] }
        { "SLOT" [ ?first name>> ">>" append 1array ] }
        [ drop ?first name>> 1array ]
    } case nip ;

M: sequence tuple>identifiers
    [ tuple>identifiers ] map sift concat ;

: vocab>identifiers ( vocab -- hashtable )
    vocab>tuples tuple>identifiers ;

: string>identifiers ( string -- identifiers )
    string>tuples tuple>identifiers ;


![[
GENERIC: fixup-arity ( obj -- seq )

ERROR: closing-tag-required obj ;
M: uppercase-colon-literal fixup-arity
    dup tag>> janky-arities ?at [
        '[ _ swap [ any-comment? not ] cut-nth-match swap ] change-payload
        swap 2array
        dup first f >>closing-tag drop
        dup first [ ] [ underlying>> ] [ payload>> last-underlying-slice ] tri force-merge-slices >>underlying drop
        ! dup first " ;" >>closing-tag drop
    ] [
        drop
        ! dup closing-tag>> [ B closing-tag-required ] unless
        ! dup closing-tag>> [ " ;" >>closing-tag ] unless
    ] if ;

M: less-than-literal fixup-arity
    [ [ fixup-arity ] map ] change-payload ;

M: object fixup-arity ;

: postprocess-modern ( seq -- seq' )
    collapse-decorators [ fixup-arity ] map flatten ;
]]
