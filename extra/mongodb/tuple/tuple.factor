USING: accessors assocs classes.mixin classes.tuple
classes.tuple.parser compiler.units hashtables kernel
mongodb.driver mongodb.msg mongodb.tuple.collection
mongodb.tuple.persistent sequences ;
FROM: mongodb.driver => update delete find count ;
FROM: mongodb.tuple.persistent => assoc>tuple ;

IN: mongodb.tuple

SYNTAX: MDBTUPLE:
    parse-tuple-definition
    mdb-check-slots
    define-tuple-class ;

: define-persistent ( class collection slot-options index -- )
    [ [ <mdb-tuple-collection> dupd link-collection ] when* ] 2dip
    [ dup '[ _ mdb-persistent add-mixin-instance ] with-compilation-unit ] 2dip
    [ drop set-slot-map ]
    [ nip set-index-map ] 3bi ; inline

: ensure-table ( class -- )
    tuple-collection
    [ create-collection ]
    [
        [ mdb-index-map values ] keep
        '[ _ name>> >>ns ensure-index ] each
    ] bi ;

: ensure-tables ( classes -- )
    [ ensure-table ] each ;

: drop-table ( class -- )
    tuple-collection
    [ [ mdb-index-map values ] keep
    '[ _ name>> swap name>> drop-index ] each ]
    [ name>> drop-collection ] bi ;

: recreate-table ( class -- )
    [ drop-table ]
    [ ensure-table ] bi ;

DEFER: tuple>query

<PRIVATE

GENERIC: id-selector ( object -- selector )

M: toid id-selector
    [ value>> ] [ key>> ] bi associate ; inline

M: mdb-persistent id-selector
    >toid id-selector ;

: (save-tuples) ( collection assoc -- )
    swap '[
        [ _ ] 2dip
        [ id-selector ] dip
        <update> >upsert update
    ] assoc-each ; inline

: prepare-tuple-query ( tuple/query -- query )
    dup mdb-query-msg? [ tuple>query ] unless ;

PRIVATE>

: save-tuple-deep ( tuple -- )
    tuple>storable [ (save-tuples) ] assoc-each ;

: update-tuple ( tuple -- )
    [ tuple-collection name>> ]
    [ ensure-oid id-selector ]
    [ tuple>assoc ] tri
    <update> >upsert update ;

: save-tuple ( tuple -- )
    update-tuple ;

: insert-tuple ( tuple -- )
    [ tuple-collection name>> ]
    [ tuple>assoc ] bi
    save ;

: delete-tuple ( tuple -- )
    [ tuple-collection name>> ] keep
    id-selector <delete> delete ;

: delete-tuples ( seq -- )
    [ delete-tuple ] each ;

: tuple>query ( tuple -- query )
    [ tuple-collection name>> ] keep
    tuple>selector <query> ;

: select-tuple ( tuple/query -- tuple/f )
    prepare-tuple-query
    find-one [ assoc>tuple ] [ f ] if* ;

: select-tuples ( tuple/query -- cursor tuples/f )
    prepare-tuple-query
    find [ assoc>tuple ] map ;

: select-all-tuples ( tuple/query -- tuples )
    prepare-tuple-query
    find-all [ assoc>tuple ] map ;

: count-tuples ( tuple/query -- n )
    dup mdb-query-msg? [ tuple>query ] unless count ;
