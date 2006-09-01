! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays definitions kernel gadgets sequences strings math
words generic namespaces hashtables help ;
IN: gadgets

TUPLE: command group name gesture quot ;

M: command equal? eq? ;

GENERIC: invoke-command ( target command -- )

M: command invoke-command ( target command -- )
    command-quot call ;

GENERIC: gesture>string ( gesture -- string )

: modifiers>string ( modifiers -- string )
    [ word-name ] map concat >string ;

M: key-down gesture>string
    dup key-down-mods modifiers>string
    swap key-down-sym append ;

M: button-up gesture>string
    [
        dup button-up-mods modifiers>string %
        "Mouse Up" %
        button-up-# [ " " % # ] when*
    ] "" make ;

M: button-down gesture>string
    [
        dup button-down-mods modifiers>string %
        "Mouse Up" %
        button-down-# [ " " % # ] when*
    ] "" make ;

M: object gesture>string drop f ;

: command-gestures ( commands -- hash )
    [ command-gesture ] subset
    [ dup command-gesture swap [ invoke-command ] curry ]
    map>hash ;

: define-commands* ( class specs -- )
    2dup "commands" set-word-prop
    command-gestures "gestures" set-word-prop ;

: <commands> ( specs -- commands )
    #! Specs is an array of { group { name gesture quot }* }
    unclip swap [ first3 <command> ] map-with ;

: define-commands ( class specs -- )
    [ <commands> ] map concat define-commands* ;

: commands ( gadget -- seq )
    delegates [ class "commands" word-prop ] map concat ;

: all-commands ( gadget -- assoc )
    [
        parents [
            dup commands [ set ] each-with
        ] each
    ] make-hash
    hash>alist [ [ first command-name ] 2apply <=> ] sort ;

: resend-button-down ( gesture world -- )
    hand-loc get-global swap send-button-down ;

: resend-button-up  ( gesture world -- )
    hand-loc get-global swap send-button-up ;

world H{
    { T{ key-down f { C+ } "x" } [ T{ cut-action } send-action ] }
    { T{ key-down f { C+ } "c" } [ T{ copy-action } send-action ] }
    { T{ key-down f { C+ } "v" } [ T{ paste-action } send-action ] }
    { T{ key-down f { C+ } "a" } [ T{ select-all-action } send-action ] }
    { T{ button-down f { C+ } 1 } [ T{ button-down f f 3 } swap resend-button-down ] }
    { T{ button-down f { A+ } 1 } [ T{ button-down f f 2 } swap resend-button-down ] }
    { T{ button-up f { C+ } 1 } [ T{ button-up f f 3 } swap resend-button-up ] }
    { T{ button-up f { A+ } 1 } [ T{ button-up f f 2 } swap resend-button-up ] }
} set-gestures

SYMBOL: +name+
SYMBOL: +button+
SYMBOL: +group+
SYMBOL: +quot+
SYMBOL: +listener+
SYMBOL: +gesture+

TUPLE: operation predicate button gesture listener? ;

: (operation) ( -- command )
    +group+ get +name+ get +gesture+ get +quot+ get <command> ;

C: operation ( predicate hash -- operation )
    swap [
        (operation) over set-delegate
        +button+ get over set-operation-button
        +listener+ get over set-operation-listener?
    ] bind
    [ set-operation-predicate ] keep ;

SYMBOL: operations

: object-operations ( obj -- operations )
    operations get [ operation-predicate call ] subset-with ;

: class-operations ( class -- operations )
    "predicate" word-prop
    operations get [ operation-predicate = ] subset-with ;

: mouse-operation ( obj button# -- command )
    swap object-operations
    [ operation-button = ] subset-with
    dup empty? [ drop f ] [ peek ] if ;

: mouse-operations ( obj -- seq )
    3 [ 1+ mouse-operation ] map-with ;
