! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel math namespaces sequences random
math.bitfields.lib namespaces.lib db db.tuples db.types ;
IN: db.queries

: maybe-make-retryable ( statement -- statement )
    dup in-params>> [ generator-bind? ] contains? [
        make-retryable
    ] when ;

: query-make ( class quot -- )
    >r sql-props r>
    [ 0 sql-counter rot with-variable ] { "" { } { } } nmake
    <simple-statement> maybe-make-retryable ;

M: db begin-transaction ( -- ) "BEGIN" sql-command ;
M: db commit-transaction ( -- ) "COMMIT" sql-command ;
M: db rollback-transaction ( -- ) "ROLLBACK" sql-command ;

: where-primary-key% ( specs -- )
    " where " 0%
    find-primary-key dup column-name>> 0% " = " 0% bind% ;

M: db <update-tuple-statement> ( class -- statement )
    [
        "update " 0% 0%
        " set " 0%
        dup remove-id
        [ ", " 0% ] [ dup column-name>> 0% " = " 0% bind% ] interleave
        where-primary-key%
    ] query-make ;

M: db <delete-tuple-statement> ( specs table -- sql )
    [
        "delete from " 0% 0%
        " where " 0%
        find-primary-key
        dup column-name>> 0% " = " 0% bind%
    ] query-make ;

M: db random-id-quot ( -- quot )
    [ 63 [ 2^ random ] keep 1 - set-bit ] ;

