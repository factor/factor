! Copyright (C) 2017 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators
combinators.short-circuit combinators.smart constructors fry
kernel lexer math math.parser modern.slices namespaces sequences
sequences.private sets splitting strings ;
IN: modern.compiler

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

TUPLE: lexed tokens ;

INSTANCE: lexed sequence
M: lexed nth tokens>> nth ;
M: lexed nth-unsafe tokens>> nth-unsafe ;
M: lexed length tokens>> length ;


TUPLE: comment < lexed payload ;
CONSTRUCTOR: <comment> comment ( tokens -- obj ) ;

TUPLE: escaped-identifier < lexed name ;
CONSTRUCTOR: <escaped-identifier> escaped-identifier ( tokens -- obj ) ;

TUPLE: escaped-object < lexed name payload ;
CONSTRUCTOR: <escaped-object> escaped-object ( tokens -- obj ) ;

TUPLE: section < lexed tag payload ;
CONSTRUCTOR: <section> section ( tokens -- obj )
    dup second >>payload ;

TUPLE: named-section < lexed tag name payload ;
CONSTRUCTOR: <named-section> named-section ( tokens -- obj ) ;


TUPLE: upper-colon < lexed tag payload decorators ;
CONSTRUCTOR: <upper-colon> upper-colon ( tokens -- obj )
    ! put this in the fixup-arity/decorators instead
    dup tokens>> first but-last-slice >>tag ;
    ! dup tokens>> [ first but-last-slice >>tag ] [ second >>payload ] bi ;

: add-upper-colon-decorator ( upper-colon obj -- upper-colon )
    [ '[ _ suffix ] change-decorators ]
    [ '[ _ suffix ] change-tokens ] bi ;

TUPLE: lower-colon < lexed tag payload ;
CONSTRUCTOR: <lower-colon> lower-colon ( tokens -- obj ) ;

TUPLE: matched < lexed tag payload ;

TUPLE: single-bracket < matched ;
CONSTRUCTOR: <single-bracket> single-bracket ( tokens -- obj )
    dup tokens>>
        [ first >string >>tag ]
        [ second >strings >>payload ] bi ;

TUPLE: double-bracket < matched ;
CONSTRUCTOR: <double-bracket> double-bracket ( tokens -- obj )
    dup tokens>>
        [ first >string >>tag ]
        [ third >string >>payload ] bi ;


TUPLE: single-brace < matched ;
CONSTRUCTOR: <single-brace> single-brace ( tokens -- obj )
    dup tokens>>
        [ first >string >>tag ]
        [ second >strings >>payload ] bi ;

TUPLE: double-brace < matched ;
CONSTRUCTOR: <double-brace> double-brace ( tokens -- obj )
    dup tokens>>
        [ first >string >>tag ]
        [ third >string >>payload ] bi ;


TUPLE: single-paren < matched ;
CONSTRUCTOR: <single-paren> single-paren ( tokens -- obj )
    dup tokens>>
        [ first >string but-last >>tag ]
        [ second >strings >>payload ] bi ;

TUPLE: double-paren < matched ;
CONSTRUCTOR: <double-paren> double-paren ( tokens -- obj )
    dup tokens>>
        [ first >string >>tag ]
        [ third >string >>payload ] bi ;

: <matched> ( tokens ch -- obj )
    {
        { char: \[ [ <single-bracket> ] }
        { char: \{ [ <single-brace> ] }
        { char: \( [ <single-paren> ] }
    } case ;


TUPLE: double-quote < matched ;
CONSTRUCTOR: <double-quote> double-quote ( tokens -- obj ) ;

TUPLE: decorator < lexed name ;

TUPLE: identifier < lexed name ;
CONSTRUCTOR: <identifier> identifier ( tokens -- obj ) ;



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

