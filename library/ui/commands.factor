! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets
USING: kernel gadgets sequences strings math words generic
namespaces hashtables ;

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

: invoke-command ( gadget command -- )
    dup command-class rot [ class over eq? ] find-parent nip
    swap command-quot call ;

: define-commands ( class specs -- )
    [ dupd first4 <command> ] map
    2dup "commands" set-word-prop
    [ command-gesture ] subset
    [ dup command-gesture swap command-quot ] map>hash
    "gestures" set-word-prop ;

: commands ( gadget -- seq )
    [
        parents [
            delegates [ class "commands" word-prop % ] each
        ] each
    ] V{ } make ;

world {
    { f "Cut" T{ key-down f { C+ } "x" } [ T{ cut-action } send-action ] }
    { f "Copy" T{ key-down f { C+ } "c" } [ T{ copy-action } send-action ] }
    { f "Paste" T{ key-down f { C+ } "v" } [ T{ paste-action } send-action ] }
    { f "Select all" T{ key-down f { C+ } "a" } [ T{ select-all-action } send-action ] }
} define-commands
