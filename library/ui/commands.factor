! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays definitions kernel gadgets sequences strings math
words generic namespaces hashtables help ;
IN: gadgets

TUPLE: command group name gesture quot ;

M: command equal? eq? ;

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

M: button-up gesture>string
    [
        dup button-down-mods modifiers>string %
        "Mouse Up" %
        button-down-# [ " " % # ] when*
    ] "" make ;

M: object gesture>string drop f ;

: define-commands ( class specs -- )
    #! Specs is an array of { group name gesture quot }
    [ first4 <command> ] map
    2dup "commands" set-word-prop
    [ command-gesture ] subset
    [ dup command-gesture swap command-quot ] map>hash
    "gestures" set-word-prop ;

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

SYMBOL: operations

: object-operation ( obj button# -- command )
    swap operations get
    [ >r class r> first class< ] subset-with
    [ second = ] subset-with
    dup empty? [ drop f ] [ peek third ] if ;

: object-operations ( object -- seq )
    3 [ 1+ object-operation ] map-with ;

: <operation> ( name quot -- command )
    >r >r f r> f r> <command> ;
