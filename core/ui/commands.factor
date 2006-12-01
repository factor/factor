! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays definitions kernel gadgets sequences strings math
words generic namespaces hashtables help ;
IN: gadgets

TUPLE: command name gesture quot ;

M: command equal? eq? ;

GENERIC: invoke-command ( target command -- )

M: f invoke-command ( target command -- ) 2drop ;

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
        "Click Button" %
        button-up-# [ " " % # ] when*
    ] "" make ;

M: button-down gesture>string
    [
        dup button-down-mods modifiers>string %
        "Press Button" %
        button-down-# [ " " % # ] when*
    ] "" make ;

M: object gesture>string drop f ;

: commands ( class -- hash )
    dup "commands" word-prop [ ] [
        H{ } clone [ "commands" set-word-prop ] keep
    ] ?if ;

: commands>gestures ( class -- hash )
    commands hash-values concat
    [ command-gesture ] subset
    [ dup command-gesture swap [ invoke-command ] curry ]
    map>hash ;

: define-commands ( class group specs -- )
    [ dup array? [ first3 <command> ] when ] map
    swap pick commands set-hash
    dup commands>gestures "gestures" set-word-prop ;

SYMBOL: +name+
SYMBOL: +quot+
SYMBOL: +listener+
SYMBOL: +keyboard+
SYMBOL: +primary+
SYMBOL: +secondary+

TUPLE: operation predicate primary? secondary? ;

: (command) ( -- command )
    +name+ get +keyboard+ get +quot+ get <command> ;

SYMBOL: operations

: object-operations ( obj -- operations )
    operations get [ operation-predicate call ] subset-with ;

: class-operations ( class -- operations )
    "predicate" word-prop
    operations get [ operation-predicate = ] subset-with ;

: primary-operation ( obj -- command )
    object-operations [ operation-primary? ] find-last nip ;

: secondary-operation ( obj -- command )
    object-operations [ operation-secondary? ] find-last nip ;

: modify-command ( quot operation -- operation )
    clone
    [ command-quot append ] keep
    [ set-command-quot ] keep ;

: modify-commands ( operations quot -- operations )
    swap [ modify-command ] map-with ;

: command-description ( command -- element )
    dup command-name swap command-gesture gesture>string
    2array ;

: commands. ( commands -- )
    [ command-gesture key-down? ] subset
    [ command-description ] map
    { { $strong "Command" } { $strong "Shortcut" } } add*
    $table ;

: $commands ( elt -- )
    first2 swap commands hash commands. ;

: $operations ( elt -- )
    [ class-operations ] map concat commands. ;
