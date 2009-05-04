USING: accessors assocs classes.mixin classes.tuple
classes.tuple.parser compiler.units fry kernel sequences mongodb.driver
mongodb.msg mongodb.tuple.collection 
mongodb.tuple.persistent mongodb.tuple.state strings ;

IN: mongodb.tuple

SINGLETONS: +fieldindex+ +compoundindex+ +deepindex+ +unique+ ;

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
    [ [ mdb-index-map values ] keep
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

<PRIVATE

GENERIC: id-selector ( object -- selector )

M: toid id-selector
   [ value>> ] [ key>> ] bi H{ } clone [ set-at ] keep ; inline

M: mdb-persistent id-selector
   >toid id-selector ;

: (save-tuples) ( collection assoc -- )
   swap '[ [ _ ] 2dip
           [ id-selector ] dip
           <update> >upsert update ] assoc-each ; inline
PRIVATE>
 
: save-tuple ( tuple -- )
   tuple>storable [ (save-tuples) ] assoc-each ;
 
: update-tuple ( tuple -- )
   save-tuple ;

: insert-tuple ( tuple -- )
   save-tuple ;

: delete-tuple ( tuple -- )
   [ tuple-collection name>> ] keep
   id-selector delete ;

: tuple>query ( tuple -- query )
   [ tuple-collection name>> ] keep
   tuple>selector <query> ;

: select-tuple ( tuple/query -- tuple/f )
   dup mdb-query-msg? [ tuple>query ] unless
   find-one [ assoc>tuple ] [ f ] if* ;

: select-tuples ( tuple/query -- cursor tuples/f )
   dup mdb-query-msg? [ tuple>query ] unless
   find [ assoc>tuple ] map ;

: count-tuples ( tuple/query -- n )
   dup mdb-query-msg? [ tuple>query ] unless count ;
