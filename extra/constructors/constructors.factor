! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: slots kernel sequences fry accessors parser lexer words
effects.parser ;
IN: constructors

! An experiment

: constructor-quot ( class slot-names body -- quot )
    [ <reversed> [ setter-word '[ swap _ execute ] ] map [ ] join ] dip
    '[ _ new @ @ ] ;

: define-constructor ( name class effect body -- )
    [ [ in>> ] dip constructor-quot ] [ drop ] 2bi
    define-declared ;

: CONSTRUCTOR:
    scan-word [ name>> "<" ">" surround create-in ] keep
    "(" expect ")" parse-effect
    parse-definition
    define-constructor ; parsing