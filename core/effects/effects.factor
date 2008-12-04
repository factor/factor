! Copyright (C) 2006, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math math.parser namespaces make sequences strings
words assocs combinators accessors arrays ;
IN: effects

TUPLE: effect in out terminated? ;

: <effect> ( in out -- effect )
    dup { "*" } sequence= [ drop { } t ] [ f ] if
    effect boa ;

: effect-height ( effect -- n )
    [ out>> length ] [ in>> length ] bi - ;

: effect<= ( eff1 eff2 -- ? )
    {
        { [ over terminated?>> ] [ t ] }
        { [ dup terminated?>> ] [ f ] }
        { [ 2dup [ in>> length ] bi@ > ] [ f ] }
        { [ 2dup [ effect-height ] bi@ = not ] [ f ] }
        [ t ]
    } cond 2nip ;

GENERIC: effect>string ( obj -- str )
M: string effect>string ;
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

GENERIC: stack-effect ( word -- effect/f )

M: symbol stack-effect drop (( -- symbol )) ;

M: word stack-effect
    { "declared-effect" "inferred-effect" }
    swap props>> [ at ] curry map [ ] find nip ;

M: effect clone
    [ in>> clone ] [ out>> clone ] bi <effect> ;

: stack-height ( word -- n )
    stack-effect effect-height ;

: split-shuffle ( stack shuffle -- stack1 stack2 )
    in>> length cut* ;

: load-shuffle ( stack shuffle -- )
    in>> [ set ] 2each ;

: shuffled-values ( shuffle -- values )
    out>> [ get ] map ;

: shuffle ( stack shuffle -- newstack )
    [ [ load-shuffle ] keep shuffled-values ] with-scope ;
