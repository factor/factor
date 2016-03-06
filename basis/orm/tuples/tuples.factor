! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators combinators.smart db2
db2.binders db2.errors db2.query-objects db2.types db2.utils fry
kernel macros make math math.parser mirrors namespaces
orm orm.persistent orm.queries sequences sets
splitting.monotonic destructors multiline ;
IN: orm.tuples

: create-table ( tuple-class -- )
    create-table-sql sql-command ;

: drop-table ( tuple-class -- )
    drop-table-sql sql-command ;

: ensure-table ( tuple-class -- )
    ensure-persistent
    '[ [ _ create-table ] ignore-table-exists ] ignore-function-exists ;

: ensure-tables ( classes -- ) [ ensure-table ] each ;

: recreate-table ( tuple-class -- )
    ensure-persistent
    [
        '[
            [
                _ drop-table-sql sql-command
            ] ignore-table-missing
        ] ignore-function-missing
    ] [ create-table ] bi ;

: recreate-tables ( tuple-classes -- )
    [ recreate-table ] each ;

: insert-tuple ( tuple -- )
    dup db-assigned-key? [
        dup insert-db-assigned-key-sql insert-tuple-set-key
    ] [
        insert-user-assigned-key-sql sql-command
    ] if ;

: update-tuple ( tuple -- )
    update-tuple-sql sql-command ;

: select-tuples ( tuple -- seq )
    select-tuple-sql set-reconstructor sql-query ;

: select-tuple ( tuple -- elt/f )
    select-tuples ?first ;

: count-tuples ( tuple -- n )
    select-tuples length ;

: delete-tuples ( tuple -- )
    delete-tuple-sql sql-command ;



/*


: tuple>pairs ( tuple -- seq )
    [ >persistent columns>> ] [ <mirror> >alist ] bi
    [ first2 dup IGNORE = [ 3drop f ] [ nip 2array ] if ] 2map sift ;

GENERIC# pair>binder* 1 ( binder pair -- binder )

: (pair>binder) ( binder pair -- binder )
    {
        [ first persistent>> class>> >>class ]
        [
            first
            [ persistent>> table-name>> "0" ]
            [ column-name>> ] bi <table-ordinal-column> >>toc
        ]
        [ first type>> >>type ]
    } cleave ;

M: in-binder pair>binder* ( binder-class pair -- binder )
    [ (pair>binder) ] [ second >>value ] bi ;

M: out-binder pair>binder* ( binder-class pair -- binder )
    (pair>binder) ;

: pair>binder ( pair binder-class -- binder ) new swap pair>binder* ;

: tuple>binders ( tuple binder -- seq )
    [ tuple>pairs ] dip '[ _ pair>binder ] map ;

: insert-tuple ( tuple -- )
    [ <insert> ] dip
    in-binder tuple>binders >>in
    query-object>statement sql-command ;


: tuple>primary-key-binders ( tuple -- seq )
    [ find-primary-key ] keep '[
        dup slot-name>> _ get-slot-named
        2array equal-binder pair>binder
    ] map ;


: update-tuple ( tuple -- )
    [ <update> ] dip
    {
        [ equal-binder tuple>binders >>in ]
        [ tuple>primary-key-binders >>where ]
    } cleave
    query-object>statement sql-command ;


: delete-tuples ( tuple -- )
    [ <delete> ] dip
    tuple>primary-key-binders >>where
    query-object>statement sql-command ;

ERROR: no-setter ;

: out-binder>setter ( toc -- word )
    [ class>> >persistent columns>> ]
    [ toc>> column-name>> ] bi '[ column-name>> _ = ] find
    nip [ no-setter ] unless* setter>> ;

MACRO: query-object>reconstructor ( tuple -- quot )
B
    out>> [ [ class>> ] bi@ = ] monotonic-split
    [ [ first class>> ] [ [ out-binder>setter ] map ] bi ] { } map>assoc 
    [
        [
            first2
            [ , \ new , ]
            [ reverse [ \ swap , , (( obj obj -- obj )) , \ call-effect , ] each ] bi*
        ] each
    ] [ ] make '[ [ _ input<sequence ] ] ;

SYMBOL: ordinal

: next-ordinal ( -- string )
    ordinal [ dup 1 + ] change number>string ;

: (select-tuples) ( tuple -- tuple )
    0 ordinal [
        [ <select> ] dip {
            [ out-binder tuple>binders >>out ]
            [ equal-binder tuple>binders [ value>> ] filter >>in ]
            [
                tuple>pairs [ first persistent>> table-name>> ] map members
                [ next-ordinal <table-ordinal> ] map >>from
            ]
        } cleave
    ] with-variable ;

MACRO: select-tuples ( tuple -- tuples )
    (select-tuples)
    [ query-object>statement sql-query ] keep
B
    query-object>reconstructor
    '[ [ @ ] map ] ;

: reconstruct ( seq quot tuple -- seq' )
    2drop
    ;

! : select-tuple ( tuple -- tuple/f )
    ! [ (select-tuples) 1 >>limit sql-query ] [ make-reconstructor ] [ ] tri reconstruct ;

: count-tuples ( tuple -- n )
    ;
*/


/*
TUPLE: foo a b ;

PERSISTENT: foo
{ "a" INTEGER +primary-key+ }
{ "b" VARCHAR } ;
[ [ "drop table foo" sql-command ] test-sqlite ] try
[ "create table foo (a integer primary key, b varchar)" sql-command ] test-sqlite
[ 1 "lol" foo boa insert-tuple ] test-sqlite
[ "select * from foo" sql-query . ] test-sqlite
[ "update foo set a=1, b='omg' where a=1" sql-command ] test-sqlite
[ "select * from foo" sql-query . ] test-sqlite
[ 1 f foo boa (select-tuples) query-object>statement ] test-sqlite
*/


/*
ERROR: unimplemented ;

: select-relations ( tuple relations -- seq )
    unimplemented
    drop
    ;

: select-no-relations ( tuple -- seq )
    
    ;



: select-tuples2 ( tuple -- seq )
    dup tuple>relations [
        select-no-relations
    ] [
        select-relations
    ] if-empty ;

*/
