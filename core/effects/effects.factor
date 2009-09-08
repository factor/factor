! Copyright (C) 2006, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math math.parser math.order namespaces make sequences strings
words assocs combinators accessors arrays quotations ;
IN: effects

TUPLE: effect { in read-only } { out read-only } { terminated? read-only } ;

GENERIC: effect-length ( obj -- n )
M: sequence effect-length length ;
M: integer effect-length ;

: <effect> ( in out -- effect )
    dup { "*" } sequence= [ drop { } t ] [ f ] if
    effect boa ;

: effect-height ( effect -- n )
    [ out>> effect-length ] [ in>> effect-length ] bi - ; inline

: effect<= ( effect1 effect2 -- ? )
    {
        { [ over terminated?>> ] [ t ] }
        { [ dup terminated?>> ] [ f ] }
        { [ 2dup [ in>> effect-length ] bi@ > ] [ f ] }
        { [ 2dup [ effect-height ] bi@ = not ] [ f ] }
        [ t ]
    } cond 2nip ; inline

: effect= ( effect1 effect2 -- ? )
    [ [ in>> effect-length ] bi@ = ]
    [ [ out>> effect-length ] bi@ = ]
    [ [ terminated?>> ] bi@ = ]
    2tri and and ;

GENERIC: effect>string ( obj -- str )
M: string effect>string ;
M: object effect>string drop "object" ;
M: word effect>string name>> ;
M: integer effect>string number>string ;
M: pair effect>string first2 [ effect>string ] bi@ ": " glue ;

: stack-picture ( seq -- string )
    dup integer? [ "object" <repetition> ] when
    [ [ effect>string % CHAR: \s , ] each ] "" make ;

M: effect effect>string ( effect -- string )
    [
        "( " %
        [ in>> stack-picture % "-- " % ]
        [ out>> stack-picture % ]
        [ terminated?>> [ "* " % ] when ]
        tri
        ")" %
    ] "" make ;

GENERIC: effect>type ( obj -- type )
M: object effect>type drop object ;
M: word effect>type ;
! attempting to specialize on callable breaks compiling
! M: effect effect>type drop callable ;
M: pair effect>type second effect>type ;

GENERIC: stack-effect ( word -- effect/f )

M: word stack-effect "declared-effect" word-prop ;

M: deferred stack-effect call-next-method (( -- * )) or ;

M: effect clone
    [ in>> clone ] [ out>> clone ] bi <effect> ;

: stack-height ( word -- n )
    stack-effect effect-height ;

: split-shuffle ( stack shuffle -- stack1 stack2 )
    in>> effect-length cut* ;

: shuffle-mapping ( effect -- mapping )
    [ out>> ] [ in>> ] bi [ index ] curry map ;

: shuffle ( stack shuffle -- newstack )
    shuffle-mapping swap nths ;

: add-effect-input ( effect -- effect' )
    [ in>> "obj" suffix ] [ out>> ] [ terminated?>> ] tri effect boa ;

: compose-effects ( effect1 effect2 -- effect' )
    over terminated?>> [
        drop
    ] [
        [ [ [ in>> effect-length ] [ out>> effect-length ] bi ] [ in>> effect-length ] bi* swap [-] + ]
        [ [ out>> effect-length ] [ [ in>> effect-length ] [ out>> effect-length ] bi ] bi* [ [-] ] dip + ]
        [ nip terminated?>> ] 2tri
        [ [ [ "obj" ] replicate ] bi@ ] dip
        effect boa
    ] if ; inline

: effect-in-types ( effect -- input-types )
    in>> [ effect>type ] map ;
: effect-out-types ( effect -- input-types )
    out>> [ effect>type ] map ;
