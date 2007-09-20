! Copyright (C) 2006, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math namespaces sequences strings words assocs
combinators ;
IN: effects

TUPLE: effect in out terminated? ;

: <effect> ( in out -- effect )
    dup { "*" } sequence= [ drop { } t ] [ f ] if
    effect construct-boa ;

: effect-height ( effect -- n )
    dup effect-out length swap effect-in length - ;

: effect<= ( eff1 eff2 -- ? )
    {
        { [ dup not ] [ t ] }
        { [ over effect-terminated? ] [ t ] }
        { [ dup effect-terminated? ] [ f ] }
        { [ 2dup [ effect-in length ] 2apply > ] [ f ] }
        { [ 2dup [ effect-height ] 2apply = not ] [ f ] }
        { [ t ] [ t ] }
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
        dup effect-in stack-picture %
        "-- " %
        dup effect-out stack-picture %
        effect-terminated? [ "* " % ] when
        ")" %
    ] "" make ;

: stack-effect ( word -- effect/f )
    dup symbol? [
        drop 0 1 <effect>
    ] [
        { "declared-effect" "inferred-effect" }
        swap word-props [ at ] curry map [ ] find nip
    ] if ;

M: effect clone
    [ effect-in clone ] keep effect-out clone <effect> ;
