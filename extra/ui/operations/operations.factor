! Copyright (C) 2006, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays definitions kernel ui.commands ui.gestures
sequences strings math words generic namespaces hashtables
help.markup quotations assocs ;
IN: ui.operations

SYMBOL: +keyboard+
SYMBOL: +primary+
SYMBOL: +secondary+

TUPLE: operation predicate command translator hook listener? ;

: <operation> ( predicate command -- operation )
    [ ] [ ] {
        set-operation-predicate
        set-operation-command
        set-operation-translator
        set-operation-hook
    } operation construct ;

PREDICATE: operation listener-operation
    dup operation-command listener-command?
    swap operation-listener? or ;

M: operation command-name
    operation-command command-name ;

M: operation command-description
    operation-command command-description ;

M: operation command-word operation-command command-word ;

: operation-gesture ( operation -- gesture )
    operation-command +keyboard+ word-prop ;

SYMBOL: operations

: object-operations ( obj -- operations )
    operations get [ operation-predicate call ] curry* subset ;

: find-operation ( obj quot -- command )
    >r object-operations r> find-last nip ; inline

: primary-operation ( obj -- operation )
    [ operation-command +primary+ word-prop ] find-operation ;

: secondary-operation ( obj -- operation )
    dup
    [ operation-command +secondary+ word-prop ] find-operation
    [ ] [ primary-operation ] ?if ;

: default-flags ( -- assoc )
    H{ { +keyboard+ f } { +primary+ f } { +secondary+ f } } ;

: define-operation ( pred command flags -- )
    default-flags swap union
    dupd define-command <operation>
    operations get push ;

: modify-operation ( hook translator operation -- operation )
    clone
    tuck set-operation-translator
    tuck set-operation-hook
    t over set-operation-listener? ;

: modify-operations ( operations hook translator -- operations )
    rot [ >r 2dup r> modify-operation ] map 2nip ;

: operations>commands ( object hook translator -- pairs )
    >r >r object-operations r> r> modify-operations
    [ [ operation-gesture ] keep ] { } map>assoc ;

: define-operation-map ( class group blurb object hook translator -- )
    operations>commands define-command-map ;

: operation-quot ( target command -- quot )
    [
        swap literalize ,
        dup operation-translator %
        operation-command ,
    ] [ ] make ;

M: operation invoke-command ( target command -- )
    [ operation-hook call ] keep operation-quot call ;
