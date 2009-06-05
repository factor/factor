! Copyright (C) 2009 Slava Pestov, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs classes.tuple effects.parser fry
generalizations generic.standard kernel lexer locals macros
parser sequences slots vocabs words ;
IN: constructors

! An experiment

: initializer-name ( class -- word )
    name>> "initialize-" prepend ;

: lookup-initializer ( class -- word/f )
    initializer-name "initializers" lookup ;

: initializer-word ( class -- word )
    initializer-name
    "initializers" create-vocab create
    [ t "initializer" set-word-prop ] [ ] bi ;

: define-initializer-generic ( name -- )
    initializer-word (( object -- object )) define-simple-generic ;

: define-initializer ( class def -- )
    [ drop define-initializer-generic ]
    [ [ dup lookup-initializer ] dip H{ } clone define-typecheck ] 2bi ;

MACRO:: slots>constructor ( class slots -- quot )
    class all-slots [ [ name>> ] [ initial>> ] bi ] { } map>assoc :> params
    slots length
    params length
    '[
        _ narray slots swap zip 
        params swap assoc-union
        values _ firstn class boa
    ] ;

:: define-constructor ( constructor-word class effect def -- )
    constructor-word
    class def define-initializer
    class effect in>> '[ _ _ slots>constructor ]
    class lookup-initializer
    '[ @ _ execute( obj -- obj ) ] effect define-declared ;

: scan-constructor ( -- class word )
    scan-word [ name>> "<" ">" surround create-in ] keep ;

SYNTAX: CONSTRUCTOR:
    scan-constructor
    complete-effect
    parse-definition
    define-constructor ;

"initializers" create-vocab drop
