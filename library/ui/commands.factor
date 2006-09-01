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
    #! Specs is an array of { group name gesture quot }
    [ first4 <command> ] map ;

: define-commands ( class specs -- )
    <commands> define-commands* ;

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
SYMBOL: +tool+
SYMBOL: +quot+
SYMBOL: +gesture+

TUPLE: operation class tags gesture tool ;

: (operation) ( -- command )
    f +name+ get +gesture+ get +quot+ get <command> ;

: (tags) ( -- seq ) +button+ get +group+ get 2array ;

C: operation ( class hash -- operation )
    swap [
        (operation) over set-delegate
        (tags) over set-operation-tags
        +tool+ get over set-operation-tool
    ] bind
    [ set-operation-class ] keep ;

SYMBOL: operations

: class-operations ( class -- operations )
    operations get [ operation-class class< ] subset-with ;

: tagged-operations ( class tag -- commands )
    swap class-operations
    [ operation-tags member? ] subset-with ;

: mouse-operation ( class button# -- command )
    tagged-operations dup empty? [ drop f ] [ peek ] if ;

: mouse-operations ( class -- seq )
    3 [ 1+ mouse-operation ] map-with ;
