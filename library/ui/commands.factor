! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays definitions kernel gadgets sequences strings math
words generic namespaces hashtables help ;
IN: gadgets

TUPLE: command name gesture quot ;

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
SYMBOL: +default+

TUPLE: operation predicate listener? default? ;

: (command) ( -- command )
    +name+ get +keyboard+ get +quot+ get <command> ;

C: operation ( predicate hash -- operation )
    swap [
        (command) over set-delegate
        +default+ get over set-operation-default?
        +listener+ get over set-operation-listener?
    ] bind
    [ set-operation-predicate ] keep ;

SYMBOL: operations

: object-operations ( obj -- operations )
    operations get [ operation-predicate call ] subset-with ;

: class-operations ( class -- operations )
    "predicate" word-prop
    operations get [ operation-predicate = ] subset-with ;

: default-operation ( obj -- command )
    object-operations [ operation-default? ] find-last nip ;

: modify-operation ( quot operation -- operation )
    clone
    [ command-quot append ] keep
    [ set-command-quot ] keep ;

: modify-operations ( operations quot -- operations )
    swap [ modify-operation ] map-with ;
