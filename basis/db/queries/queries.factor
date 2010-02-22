! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel math namespaces make sequences random
strings math.parser math.intervals combinators math.bitwise
nmake db db.tuples db.types classes words shuffle arrays
destructors continuations db.tuples.private prettyprint
db.private byte-arrays ;
IN: db.queries

GENERIC: where ( specs obj -- )

SINGLETON: retryable
: make-retryable ( obj -- obj' )
    dup sequence? [
        [ make-retryable ] map
    ] [
        retryable >>type
        10 >>retries
    ] if ;

: maybe-make-retryable ( statement -- statement )
    dup in-params>> [ generator-bind? ] any?
    [ make-retryable ] when ;

: regenerate-params ( statement -- statement )
    dup 
    [ bind-params>> ] [ in-params>> ] bi
    [
        dup generator-bind? [
            generator-singleton>> eval-generator >>value
        ] [
            drop
        ] if
    ] 2map >>bind-params ;
    
M: retryable execute-statement* ( statement type -- )
    drop [ retries>> iota ] [
        [
            nip
            [ query-results dispose t ]
            [ ] 
            [ regenerate-params bind-statement* f ] cleanup
        ] curry
    ] bi attempt-all drop ;

: sql-props ( class -- columns table )
    [ db-columns ] [ db-table-name ] bi ;

: query-make ( class quot -- statements )
    #! query, input, outputs, secondary queries
    over db-table-name "table-name" set
    [ sql-props ] dip
    [ 0 sql-counter rot with-variable ] curry
    { "" { } { } { } } nmake
    [ <simple-statement> maybe-make-retryable ] dip
    [ [ 1array ] dip append ] unless-empty ; inline

: where-primary-key% ( specs -- )
    " where " 0%
    find-primary-key [
        " and " 0%
    ] [
        dup column-name>> 0% " = " 0% bind%
    ] interleave ;

M: db-connection <update-tuple-statement> ( class -- statement )
    [
        "update " 0% 0%
        " set " 0%
        dup remove-id
        [ ", " 0% ] [ dup column-name>> 0% " = " 0% bind% ] interleave
        where-primary-key%
    ] query-make ;

M: random-id-generator eval-generator ( singleton -- obj )
    drop
    system-random-generator get [
        63 [ random-bits ] keep 1 - set-bit
    ] with-random ;

: interval-comparison ( ? str -- str )
    "from" = " >" " <" ? swap [ "= " append ] when ;

: (infinite-interval?) ( interval -- ?1 ?2 )
    [ from>> ] [ to>> ] bi
    [ first fp-infinity? ] bi@ ;

: double-infinite-interval? ( obj -- ? )
    dup interval? [ (infinite-interval?) and ] [ drop f ] if ;

: infinite-interval? ( obj -- ? )
    dup interval? [ (infinite-interval?) or ] [ drop f ] if ;

: where-interval ( spec obj from/to -- )
    over first fp-infinity? [
        3drop
    ] [
        pick column-name>> 0%
        [ first2 ] dip interval-comparison 0%
        bind#
    ] if ;

: in-parens ( quot -- )
    "(" 0% call ")" 0% ; inline

M: interval where ( spec obj -- )
    [
        [ from>> "from" where-interval ] [
            nip infinite-interval? [ " and " 0% ] unless
        ] [ to>> "to" where-interval ] 2tri
    ] in-parens ;

M: sequence where ( spec obj -- )
    [
        [ " or " 0% ] [ dupd where ] interleave drop
    ] in-parens ;

M: byte-array where ( spec obj -- )
    over column-name>> 0% " = " 0% bind# ;

M: NULL where ( spec obj -- )
    drop column-name>> 0% " is NULL" 0% ;

: object-where ( spec obj -- )
    over column-name>> 0% " = " 0% bind# ;

M: object where ( spec obj -- ) object-where ;

M: integer where ( spec obj -- ) object-where ;

M: string where ( spec obj -- ) object-where ;

: filter-slots ( tuple specs -- specs' )
    [
        slot-name>> swap get-slot-named
        dup double-infinite-interval? [ drop f ] when
    ] with filter ;

: many-where ( tuple seq -- )
    " where " 0% [
        " and " 0%
    ] [
        2dup slot-name>> swap get-slot-named where
    ] interleave drop ;

: where-clause ( tuple specs -- )
    dupd filter-slots [ drop ] [ many-where ] if-empty ;

M: db-connection <delete-tuples-statement> ( tuple table -- sql )
    [
        "delete from " 0% 0%
        where-clause
    ] query-make ;

ERROR: all-slots-ignored class ;

M: db-connection <select-by-slots-statement> ( tuple class -- statement )
    [
        "select " 0%
        [ dupd filter-ignores ] dip
        over empty? [ all-slots-ignored ] when
        over
        [ ", " 0% ]
        [ dup column-name>> 0% 2, ] interleave
        " from " 0% 0%
        where-clause
    ] query-make ;

: do-group ( tuple groups -- )
    dup string? [ 1array ] when
    [ ", " join " group by " glue ] curry change-sql drop ;

: do-order ( tuple order -- )
    dup string? [ 1array ] when
    [ ", " join " order by " glue ] curry change-sql drop ;

: do-offset ( tuple n -- )
    [ number>string " offset " glue ] curry change-sql drop ;

: do-limit ( tuple n -- )
    [ number>string " limit " glue ] curry change-sql drop ;

: make-query* ( tuple query -- tuple' )
    dupd
    {
        [ group>> [ drop ] [ do-group ] if-empty ]
        [ order>> [ drop ] [ do-order ] if-empty ]
        [ limit>> [ do-limit ] [ drop ] if* ]
        [ offset>> [ do-offset ] [ drop ] if* ]
    } 2cleave ;

M: db-connection query>statement ( query -- tuple )
    [ tuple>> dup class ] keep
    [ <select-by-slots-statement> ] dip make-query* ;

! select ID, NAME, SCORE from EXAM limit 1 offset 3

M: db-connection <count-statement> ( query -- statement )
    [ tuple>> dup class ] keep
    [ [ "select count(*) from " 0% 0% where-clause ] query-make ]
    dip make-query* ;

: create-index ( index-name table-name columns -- )
    [
        [ [ "create index " % % ] dip " on " % % ] dip "(" %
        "," join % ")" %
    ] "" make sql-command ;

: drop-index ( index-name -- )
    [ "drop index " % % ] "" make sql-command ;
