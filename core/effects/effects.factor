! Copyright (C) 2006, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math namespaces sequences strings words assocs
combinators accessors ;
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

GENERIC: (stack-picture) ( obj -- str )
M: string (stack-picture) ;
M: word (stack-picture) word-name ;
M: integer (stack-picture) drop "object" ;

: stack-picture ( seq -- string )
    [ [ (stack-picture) % CHAR: \s , ] each ] "" make ;

: effect>string ( effect -- string )
    [
        "( " %
        [ in>> stack-picture % "-- " % ]
        [ out>> stack-picture % ]
        [ terminated?>> [ "* " % ] when ]
        tri
        ")" %
    ] "" make ;

GENERIC: stack-effect ( word -- effect/f )

M: symbol stack-effect drop 0 1 <effect> ;

M: word stack-effect
    { "declared-effect" "inferred-effect" }
    swap word-props [ at ] curry map [ ] find nip ;

M: effect clone
    [ in>> clone ] keep effect-out clone <effect> ;

: split-shuffle ( stack shuffle -- stack1 stack2 )
    in>> length cut* ;

: load-shuffle ( stack shuffle -- )
    in>> [ set ] 2each ;

: shuffled-values ( shuffle -- values )
    out>> [ get ] map ;

: shuffle* ( stack shuffle -- newstack )
    [ [ load-shuffle ] keep shuffled-values ] with-scope ;

: shuffle ( stack shuffle -- newstack )
    [ split-shuffle ] keep shuffle* append ;
