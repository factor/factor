! Copyright (C) 2006, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays definitions kernel ui.commands
ui.gestures sequences strings math words generic namespaces
hashtables quotations assocs fry linked-assocs ;
IN: ui.operations

SYMBOL: +keyboard+
SYMBOL: +primary+
SYMBOL: +secondary+

TUPLE: operation predicate command translator listener? ;

: <operation> ( predicate command -- operation )
    operation new
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
    [ predicate>> call( obj -- ? ) ] with filter ;

: gesture>operation ( gesture object -- operation/f )
    object-operations [ operation-gesture = ] with find nip ;

: find-operation ( obj quot -- command )
    [ object-operations ] dip find-last nip ; inline

: primary-operation? ( operation -- ? )
    command>> +primary+ word-prop ;

: primary-operation ( obj -- operation )
    [ primary-operation? ] find-operation ;

: invoke-primary-operation ( obj -- )
    dup primary-operation invoke-command ;

: secondary-operation ( obj -- operation )
    dup
    [ command>> +secondary+ word-prop ] find-operation
    [ ] [ primary-operation ] ?if ;

: invoke-secondary-operation ( obj -- )
    dup secondary-operation invoke-command ;

: default-flags ( -- assoc )
    H{ { +keyboard+ f } { +primary+ f } { +secondary+ f } } ;

: (define-operation) ( operation -- )
    dup [ command>> ] [ predicate>> ] bi
    2array operations get set-at ;

: define-operation ( pred command flags -- )
    default-flags swap assoc-union
    dupd define-command <operation>
    (define-operation) ;

: modify-operation ( translator operation -- operation )
    clone
        swap >>translator
        t >>listener? ;

: modify-operations ( operations translator -- operations )
    '[ [ _ ] dip modify-operation ] map ;

: operations>commands ( object translator -- pairs )
    [ object-operations ] dip modify-operations
    [ [ operation-gesture ] keep ] { } map>assoc ;

: define-operation-map ( class group blurb object translator -- )
    operations>commands define-command-map ;

: operation-quot ( target command -- quot )
    [ translator>> ] [ command>> ] bi '[ _ @ _ execute ] ;

M: operation invoke-command ( target command -- )
    operation-quot call( -- ) ;
