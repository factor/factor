USING: accessors assocs classes classes.mixin classes.tuple vectors math
classes.tuple.parser formatting generalizations kernel sequences fry
prettyprint strings compiler.units slots tools.walker words arrays mongodb.persistent ;

IN: mongodb.tuple

MIXIN: mdb-persistent


GENERIC: mdb-slot-definitions>> ( tuple -- string )
GENERIC: mdb-collection>> ( object -- mdb-collection )

CONSTANT: MDB_COLLECTIONS "mdb_collections"
CONSTANT: MDB_COL_PROP "mdb_collection"
CONSTANT: MDB_SLOTOPT_PROP "mdb_slot_options"

SLOT: _id
CONSTANT: MDB_P_SLOTS { "_id" } 
CONSTANT: MDB_OID "_id"

SYMBOLS: +transient+ +load+ ;

UNION: boolean t POSTPONE: f ;

TUPLE: mdb-collection
     { name string }
     { capped boolean initial: f }
     { size integer initial: -1 }
     { max integer initial: -1 }
     { classes sequence } ;

<PRIVATE

: (mdb-collection>>) ( class -- mdb-collection )     
     dup props>> [ MDB_COL_PROP ] dip at
     [ [ drop ] dip ]
     [ superclass [ (mdb-collection>>) ] [ f ] if* ] if* ; inline recursive

: (mdb-slot-definitions>>) ( class -- slot-defs )
     superclasses [ MDB_SLOTOPT_PROP word-prop ] map assoc-combine  ; inline 

: link-class ( class collection -- )
    tuck classes>> ! col class v{}
    [ 2dup member? [ 2drop ] [ push ] if ]
    [ 1vector >>classes ] if* drop ;

PRIVATE>

M: tuple-class mdb-collection>> ( tuple -- mdb-collection )
    (mdb-collection>>) ;
 
M: mdb-persistent mdb-collection>> ( tuple -- mdb-collection )
    class (mdb-collection>>) ;

M: mdb-persistent mdb-slot-definitions>> ( tuple -- string )
     class (mdb-slot-definitions>>) ;

M: tuple-class mdb-slot-definitions>> ( class -- assoc )
    (mdb-slot-definitions>>) ;

M: mdb-collection mdb-slot-definitions>> ( collection -- assoc )
    classes>> [ mdb-slot-definitions>> ] map assoc-combine ;

: link-collection ( class collection -- )
    2dup link-class
    swap [ MDB_COL_PROP ] dip props>> set-at ; inline

: declared-collections> ( -- assoc )
     MDB_COLLECTIONS mdb-persistent props>> at
     [ H{ } clone
       [ MDB_COLLECTIONS mdb-persistent props>> set-at ] keep
     ] unless* ; 

: <mdb-collection> ( name -- mdb-collection )
     declared-collections> 2dup key? 
     [ at ]
     [ [ mdb-collection new ] 2dip 
       [ [ >>name dup ] keep ] dip set-at ] if ;

<PRIVATE


: mdb-check-id-slot ( superclass slots -- superclass slots )
    over
    all-slots [ name>> ] map [ MDB_OID ] dip memq?
    [  ]
    [ MDB_P_SLOTS prepend ] if ; inline
  
PRIVATE>

: show-persistence-info ( class -- )
     H{ } clone 
     [ [ dup mdb-collection>> "collection" ] dip set-at ] keep
     [ [ mdb-slot-definitions>> "slots" ] dip set-at ] keep . ;

GENERIC: mdb-persisted? ( tuple -- ? )

M: mdb-persistent mdb-persisted? ( tuple -- ? )
    _id>> f = not ;

M: assoc mdb-persisted? ( assoc -- ? )
    [ MDB_OID ] dip key? ; inline

: MDBTUPLE:
    parse-tuple-definition
    mdb-check-id-slot
    define-tuple-class ; parsing

<PRIVATE

: split-olist ( seq -- key options )
    [ first ] [ rest ] bi ; inline


: optl>assoc ( seq -- assoc )
    [ dup assoc?
      [ 1array { "" } append ] unless
    ] map ;

PRIVATE>

: set-slot-options ( class options -- )
     H{ } clone tuck '[  _ [ split-olist optl>assoc swap ] dip set-at ] each
     over [ MDB_SLOTOPT_PROP ] dip props>> set-at
     dup mdb-collection>> link-collection ; 

: define-collection ( class collection options -- )
    [ [ dup ] dip link-collection ] dip ! cl options
    [ dup '[ _ mdb-persistent add-mixin-instance ] with-compilation-unit ] dip 
    set-slot-options ;

