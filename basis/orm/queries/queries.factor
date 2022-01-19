! Copyright (C) 2010 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators db2.binders
db2.connections db2.query-objects db2.statements db2.types
db2.utils kernel make orm.binders orm.persistent reconstructors
sequences ;
IN: orm.queries

HOOK: create-table-sql db-connection ( tuple-class -- object )
HOOK: ensure-table-sql db-connection ( tuple-class -- object )
HOOK: drop-table-sql db-connection ( tuple-class -- object )

HOOK: insert-db-assigned-key-sql db-connection ( tuple -- object )
HOOK: insert-user-assigned-key-sql db-connection ( tuple -- object )
HOOK: insert-tuple-set-key db-connection ( tuple statement -- )
HOOK: update-tuple-sql db-connection ( tuple -- object )
HOOK: upsert-tuple-sql db-connection ( tuple -- object )
HOOK: delete-tuple-sql db-connection ( tuple -- object )
HOOK: select-tuple-sql db-connection ( tuple -- object )

ERROR: can't-reconstruct query ;

: set-reconstructor ( query -- query )
    ! { { bag >>id } { bean >>id >>bag-id >>color } } rows>tuples
    dup from>> length 1 = [ can't-reconstruct ] unless
    {
        [ from>> first class>> 1array ]
        [
            out>> [ column>> setter>> first ] map append 1array
            '[ _ rows>tuples concat ]
        ]
        [ reconstructor<< ]
        [ ]
    } cleave ;

HOOK: n>bind-sequence db-connection ( n -- sequence ) 
HOOK: continue-bind-sequence db-connection ( previous n -- sequence )

: n>bind-string ( n -- string ) n>bind-sequence "," join ;
M: object n>bind-sequence "?" <repetition> ;
M: object continue-bind-sequence nip "?" <repetition> ;

M: object create-table-sql
    >persistent dup table-name>> quote-sql-name
    [
        [
            [ columns>> ] dip
            "CREATE TABLE " % %
            "(" % [ ", " % ] [
                [ column-name>> % " " % ]
                [ type>> sql-create-type>string % ]
                [ modifiers>> " " join % ] tri
            ] interleave
        ] [
            drop
            find-primary-key [
                ", " %
                "PRIMARY KEY(" %
                [ "," % ] [ column-name>> % ] interleave
                ")" %
            ] unless-empty
            ");" %
        ] 2bi
    ] "" make ;

M: object drop-table-sql
    >persistent table-name>> quote-sql-name
    "DROP TABLE " ";" surround ;

: columns>in-binders ( columns tuple -- sequence )
    '[
        [ _ swap getter>> ( obj -- slot-value ) call-effect ]
        [ type>> ] bi
        <in-binder-low>
    ] { } map-as ;

M:: object delete-tuple-sql ( $tuple -- statement )
    <statement> :> $statement
    $tuple >persistent :> $persistent

    $statement
        $persistent table-name>> "DELETE FROM " prepend add-sql
        $persistent find-primary-key :> $primary-key
        $primary-key length :> $#primary-key

        " WHERE " add-sql
        $primary-key $tuple columns>in-binders add-in

        $primary-key [ column-name>> ] map
        $#primary-key n>bind-sequence zip
        [ " = " glue ] { } assoc>map ", " join add-sql ;

: call-generators ( columns tuple -- )
    '[
        _
        2dup swap getter>> call( obj -- obj ) [
            2drop
        ] [
            over generator>> [
                dupd call( obj -- obj )
                rot setter>> call( obj obj -- obj ) drop
            ] [
                2drop
            ] if*
        ] if
    ] each ;

! XXX: include the assoc-filter?
: filter-tuple-values ( persistent tuple -- assoc )
    [ columns>> ] dip
    2dup call-generators
    '[ _ over getter>> call( obj -- slot-value ) ] { } map>assoc ;

: filter-empty-tuple-values ( persistent tuple -- assoc )
    filter-tuple-values
    [ nip ] assoc-filter ;

! : where-primary-key ( statement persistent tuple -- statement )
    ! [ find-primary-key ] dip
    ! [ columns>in-binders add-in ]
    ! [ drop [ column-name>> ] map " WHERE " prepend add-sql ] 2bi ;

M:: object update-tuple-sql ( $tuple -- statement )
    <statement> :> $statement
    $tuple >persistent :> $persistent

    $statement
        $persistent table-name>> "UPDATE " " SET " surround add-sql
        $persistent columns>> remove-primary-key :> $no-primary-key
        $persistent find-primary-key :> $primary-key
        $no-primary-key length :> $#columns
        $primary-key length :> $#primary-key

        $no-primary-key [ column-name>> ] map
        $#columns n>bind-sequence zip [ " = " glue ] { } assoc>map ", " join add-sql

        $no-primary-key $tuple columns>in-binders add-in
        " WHERE " add-sql
        $primary-key $tuple columns>in-binders add-in

        $primary-key [ column-name>> ] map
        $#columns $#primary-key continue-bind-sequence zip [ " = " glue ] { } assoc>map ", " join add-sql ;


M: object select-tuple-sql ( tuple -- object )
    [ <select> ] dip
    [ >persistent ] [ ] bi {
        [ filter-empty-tuple-values [ first2 <column-binder-in> ] map >>in ]
        [ drop columns>> [ <column-binder-out> ] map >>out ]
        [ drop 1array >>from ]
    } 2cleave ;

