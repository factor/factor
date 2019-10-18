! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: words
USING: kernel math namespaces sequences strings generic ;

TUPLE: effect in out terminated? ;

C: effect
    [
        over { "*" } sequence=
        [ nip t swap set-effect-terminated? ]
        [ set-effect-out ] if
    ] keep
    [ set-effect-in ] keep ;

: effect-height ( effect -- n )
    dup effect-out length swap effect-in length - ;

: effect<= ( eff1 eff2 -- ? )
    2dup [ effect-terminated? ] 2apply = >r
    2dup [ effect-in length ] 2apply <= >r
    [ effect-height ] 2apply number= r> and r> and ;

: stack-picture ( seq -- string )
    [
        [
            {
                { [ dup string? ] [ ] }
                { [ dup word? ] [ word-name ] }
                { [ dup integer? ] [ drop "object" ] }
            } cond % CHAR: \s ,
        ] each
    ] "" make ;

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
    dup "declared-effect" word-prop [ ] [
        dup "inferred-effect" word-prop [ ] [ drop f ] ?if
    ] ?if ;

M: effect clone
    [ effect-in clone ] keep effect-out clone <effect> ;
