! Copyright (C) 2009 Slava Pestov, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs classes classes.tuple effects.parser
fry generalizations generic.standard kernel lexer locals macros
parser sequences slots vocabs words arrays ;
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

: all-slots-assoc ( class -- slots )
    superclasses [ [ "slots" word-prop ] keep '[ _ ] { } map>assoc ] map concat ;

MACRO:: slots>constructor ( class slots -- quot )
    class all-slots-assoc slots [ '[ first name>> _ = ] find-last nip ] with map :> slot-assoc
    class all-slots-assoc [ [ ] [ first initial>> ] bi ] { } map>assoc :> default-params
    slots length
    default-params length
    '[
        _ narray slot-assoc swap zip 
        default-params swap assoc-union values _ firstn class boa
    ] ;

:: (define-constructor) ( constructor-word class effect def -- word quot )
    constructor-word
    class def define-initializer
    class effect in>> '[ _ _ slots>constructor ] ;

:: define-constructor ( constructor-word class effect def -- )
    constructor-word class effect def (define-constructor)
    class lookup-initializer
    '[ @ _ execute( obj -- obj ) ] effect define-declared ;

:: define-auto-constructor ( constructor-word class effect def reverse? -- )
    constructor-word class effect def (define-constructor)
    class superclasses [ lookup-initializer ] map sift
    reverse? [ reverse ] when
    '[ @ _ [ execute( obj -- obj ) ] each ] effect define-declared ;

: scan-constructor ( -- class word )
    scan-word [ name>> "<" ">" surround create-in ] keep ;

: parse-constructor ( -- class word effect def )
    scan-constructor complete-effect parse-definition ;

SYNTAX: CONSTRUCTOR: parse-constructor define-constructor ;
SYNTAX: FORWARD-CONSTRUCTOR: parse-constructor f define-auto-constructor ;
SYNTAX: BACKWARD-CONSTRUCTOR: parse-constructor t define-auto-constructor ;
ALIAS: AUTO-CONSTRUCTOR FORWARD-CONSTRUCTOR

"initializers" create-vocab drop
