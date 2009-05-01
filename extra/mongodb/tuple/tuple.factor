USING: accessors assocs classes.mixin classes.tuple
classes.tuple.parser compiler.units fry kernel sequences mongodb.driver
mongodb.msg mongodb.tuple.collection mongodb.tuple.index
mongodb.tuple.persistent mongodb.tuple.state strings ;

IN: mongodb.tuple

SYNTAX: MDBTUPLE:
    parse-tuple-definition
    mdb-check-slots
    define-tuple-class ; 

: define-persistent ( class collection options -- )
    [ [ <mdb-tuple-collection> dupd link-collection ] when* ] dip 
    [ dup '[ _ mdb-persistent add-mixin-instance ] with-compilation-unit ] dip
    ! [ dup annotate-writers ] dip 
    set-slot-map ;

: ensure-table ( class -- )
    tuple-collection
    [ create-collection ]
    [ [ tuple-index-list ] keep
      '[ _ name>> swap [ name>> ] [ spec>> ] bi <index-spec> ensure-index ] each
    ] bi ;

: ensure-tables ( classes -- )
    [ ensure-table ] each ; 

: drop-table ( class -- )
      tuple-collection
      [ [ tuple-index-list ] keep
        '[ _ name>> swap name>> drop-index ] each ]
      [ name>> drop-collection ] bi ;

: recreate-table ( class -- )
    [ drop-table ] 
    [ ensure-table ] bi ;

<PRIVATE

GENERIC: id-selector ( object -- selector )

M: string id-selector ( objid -- selector )
   "_id" H{ } clone [ set-at ] keep ; inline

M: mdb-persistent id-selector ( mdb-persistent -- selector )
   _id>> id-selector ;

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
   dup persistent?
   [ [ tuple-collection name>> ] keep
     id-selector delete ] [ drop ] if ;

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
