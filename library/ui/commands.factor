! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays definitions kernel gadgets sequences strings math
words generic namespaces hashtables help ;
IN: gadgets

TUPLE: command group name gesture quot ;

M: command equal? eq? ;

GENERIC: gesture>string ( gesture -- string )

M: key-down gesture>string
    dup key-down-mods [ word-name ] map concat >string
    swap key-down-sym append ;

M: button-up gesture>string
    "Mouse Up" swap button-up-#
    [ " " swap number>string append3 ] when* ;

M: button-down gesture>string
    "Mouse Down" swap button-down-#
    [ " " swap number>string append3 ] when* ;

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

world {
    { f "Cut" T{ key-down f { C+ } "x" } [ T{ cut-action } send-action ] }
    { f "Copy" T{ key-down f { C+ } "c" } [ T{ copy-action } send-action ] }
    { f "Paste" T{ key-down f { C+ } "v" } [ T{ paste-action } send-action ] }
    { f "Select all" T{ key-down f { C+ } "a" } [ T{ select-all-action } send-action ] }
} define-commands

SYMBOL: operations

: define-operation ( pred button# name quot -- )
    >r >r f r> f r> <command> 3array operations get push-new ;

: object-operation ( obj button# -- command )
    swap operations get
    [ >r class r> first class< ] subset-with
    [ second = ] subset-with
    dup empty? [ drop f ] [ peek third ] if ;

: object-operations ( object -- seq )
    3 [ 1+ object-operation ] map-with ;

global [
    operations get [
        V{ } clone operations set
        
        \ word 2 "Edit" [ edit ] define-operation
        link 2 "Edit" [ edit ] define-operation
    ] unless
] bind
