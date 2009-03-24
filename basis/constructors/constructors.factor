! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: slots kernel sequences fry accessors parser lexer words
effects.parser macros ;
IN: constructors

! An experiment

MACRO: set-slots ( slots -- quot )
    <reversed> [ setter-word '[ swap _ execute ] ] map [ ] join ;

: construct ( ... class slots -- instance )
    [ new ] dip set-slots ; inline

: define-constructor ( name class effect body -- )
    [ [ in>> '[ _ _ construct ] ] dip compose ] [ drop ] 2bi
    define-declared ;

SYNTAX: CONSTRUCTOR:
    scan-word [ name>> "<" ">" surround create-in ] keep
    complete-effect
    parse-definition
    define-constructor ;