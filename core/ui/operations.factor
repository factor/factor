! Copyright (C) 2006, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays definitions kernel gadgets sequences strings math
words generic namespaces hashtables help quotations assocs ;
IN: operations

SYMBOL: +keyboard+
SYMBOL: +primary+
SYMBOL: +secondary+

TUPLE: operation predicate command translator hook listener? ;

M: operation command-name
    operation-command command-name ;

M: operation command-description
    operation-command command-description ;

M: operation in-listener?
    dup operation-listener?
    swap operation-command in-listener? or ;

M: operation command-word operation-command command-word ;

: operation-gesture ( operation -- gesture )
    operation-command +keyboard+ word-prop ;

SYMBOL: operations

: object-operations ( obj -- operations )
    operations get [ operation-predicate call ] subset-with ;

: find-operation ( obj quot -- command )
    >r object-operations r> find-last nip ; inline

: primary-operation ( obj -- command )
    [ operation-command +primary+ word-prop ] find-operation ;

: secondary-operation ( obj -- command )
    [ operation-command +secondary+ word-prop ] find-operation ;

: define-operation ( pred command flags -- )
    dupd define-command f f f <operation>
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

: $operations ( element -- )
    >quotation call
    f f operations>commands
    command-map. ;

: $operation ( element -- )
    first +keyboard+ word-prop gesture>string $snippet ;
