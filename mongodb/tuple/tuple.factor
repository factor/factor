USING: accessors assocs classes classes.mixin classes.tuple vectors math
classes.tuple.parser formatting generalizations kernel sequences fry combinators
linked-assocs sequences.deep mongodb.driver continuations memoize bson.constants
prettyprint strings compiler.units slots tools.walker words arrays ;

IN: mongodb.tuple

USING: mongodb.tuple.state mongodb.tuple.persistent mongodb.tuple.collection
mongodb.tuple.index mongodb.msg ; 

SYNTAX: MDBTUPLE:
    parse-tuple-definition
    mdb-check-slots
    define-tuple-class ; 

: define-persistent ( class collection options -- )
    [ [ dup ] dip link-collection ] dip ! cl options
    [ dup '[ _ mdb-persistent add-mixin-instance ] with-compilation-unit ] dip 
    set-slot-options ;

: ensure-table ( class -- )
    tuple-collection
    [ create-collection ]
    [ [ tuple-index-list ] keep
      '[ _ swap [ name>> ] [ spec>> ] bi ensure-index ] each
    ] bi ;

: ensure-tables ( classes -- )
    [ ensure-table ] each ; 

: drop-table ( class -- )
      tuple-collection
      [ [ tuple-index-list ] keep
        '[ _ swap name>> drop-index ] each ]
      [ name>> drop-collection ] bi ;

: recreate-table ( class -- )
    [ drop-table ] 
    [ ensure-table ] bi ;

<PRIVATE

GENERIC: id-selector ( object -- selector )
M: objid id-selector ( objid -- selector )
   "_id" H{ } clone [ set-at ] keep ; inline
M: mdb-persistent id-selector ( mdb-persistent -- selector )
   id>> id-selector ;

: (save-tuples) ( collection assoc -- )
   swap '[ [ _ ] 2dip
           [ id-selector ] dip
           <update> update ] assoc-each ; inline
PRIVATE>
 
: save-tuple ( tuple -- )
   tuple>assoc [ (save-tuples) ] assoc-each ;
 
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
   dup mdb-query-msg? [ ] [ tuple>query ] if
   find-one [ assoc>tuple ] [ f ] if* ;

: select-tuples ( tuple/query -- cursor tuples/f )
   dup mdb-query-msg? [ ] [ tuple>query ] if
   find [ assoc>tuple ] map ;

: count-tuples ( tuple/query -- n )
   dup mdb-query-msg? [ tuple>query ] unless
   [ collection>> ] [ query>> ] bi count ;
