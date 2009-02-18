! Copyright (C) 2006, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays definitions kernel ui.commands
ui.gestures sequences strings math words generic namespaces make
hashtables help.markup quotations assocs fry linked-assocs ;
IN: ui.operations

SYMBOL: +keyboard+
SYMBOL: +primary+
SYMBOL: +secondary+

TUPLE: operation predicate command translator hook listener? ;

: <operation> ( predicate command -- operation )
    operation new
        [ ] >>hook
        [ ] >>translator
        swap >>command
        swap >>predicate ;

PREDICATE: listener-operation < operation
    [ command>> listener-command? ] [ listener?>> ] bi or ;

M: operation command-name
    command>> command-name ;

M: operation command-description
    command>> command-description ;

M: operation command-word command>> command-word ;

: operation-gesture ( operation -- gesture )
    command>> +keyboard+ word-prop ;

SYMBOL: operations

operations [ <linked-hash> ] initialize

: object-operations ( obj -- operations )
    operations get values
    [ predicate>> call ] with filter ;

: find-operation ( obj quot -- command )
    [ object-operations ] dip find-last nip ; inline

: primary-operation ( obj -- operation )
    [ command>> +primary+ word-prop ] find-operation ;

: secondary-operation ( obj -- operation )
    dup
    [ command>> +secondary+ word-prop ] find-operation
    [ ] [ primary-operation ] ?if ;

: default-flags ( -- assoc )
    H{ { +keyboard+ f } { +primary+ f } { +secondary+ f } } ;

: (define-operation) ( operation -- )
    dup [ command>> ] [ predicate>> ] bi
    2array operations get set-at ;

: define-operation ( pred command flags -- )
    default-flags swap assoc-union
    dupd define-command <operation>
    (define-operation) ;

: modify-operation ( hook translator operation -- operation )
    clone
        swap >>translator
        swap >>hook
        t >>listener? ;

: modify-operations ( operations hook translator -- operations )
    '[ [ _ _ ] dip modify-operation ] map ;

: operations>commands ( object hook translator -- pairs )
    [ object-operations ] 2dip modify-operations
    [ [ operation-gesture ] keep ] { } map>assoc ;

: define-operation-map ( class group blurb object hook translator -- )
    operations>commands define-command-map ;

: operation-quot ( target command -- quot )
    [
        swap literalize ,
        dup translator>> %
        command>> ,
    ] [ ] make ;

M: operation invoke-command ( target command -- )
    [ hook>> call ] keep operation-quot call ;
