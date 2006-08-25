! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets
USING: arrays kernel gadgets sequences strings math words
generic namespaces hashtables jedit help ;

TUPLE: command class group name gesture quot ;

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

: command-string ( command -- string )
    dup command-name swap command-gesture [
        gesture>string [
            [ swap % " (" % % ")" % ] "" make
        ] when*
    ] when* ;

: command-target ( target command -- target )
    command-class [
        swap [ class over eq? ] find-parent nip
    ] when* ;

: invoke-command ( target command -- )
    [ command-target ] keep command-quot call ;

: define-commands ( class specs -- )
    [ dupd first4 <command> ] map
    2dup "commands" set-word-prop
    [ command-gesture ] subset
    [ dup command-gesture swap command-quot ] map>hash
    "gestures" set-word-prop ;

: commands ( gadget -- seq )
    delegates [ class "commands" word-prop ] map concat ;

world {
    { f "Cut" T{ key-down f { C+ } "x" } [ T{ cut-action } send-action ] }
    { f "Copy" T{ key-down f { C+ } "c" } [ T{ copy-action } send-action ] }
    { f "Paste" T{ key-down f { C+ } "v" } [ T{ paste-action } send-action ] }
    { f "Select all" T{ key-down f { C+ } "a" } [ T{ select-all-action } send-action ] }
} define-commands

SYMBOL: operations
global [
    operations get [ V{ } clone operations set ] unless*
] bind

: define-operation ( pred button# name quot -- )
    >r >r f f r> f r> <command> 3array operations get push-new ;

: object-operation ( obj button# -- command )
    swap operations get
    [ first call ] subset-with
    [ second = ] subset-with
    dup empty? [ drop f ] [ peek third ] if ;

[ word? ] 2 "jEdit" [ jedit ] define-operation
[ link? ] 2 "jEdit" [ jedit ] define-operation
