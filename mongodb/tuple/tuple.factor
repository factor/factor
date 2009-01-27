USING: accessors assocs classes classes.mixin classes.tuple vectors math
classes.tuple.parser formatting generalizations kernel sequences fry
prettyprint strings compiler.units slots tools.walker words arrays
mongodb.collection mongodb.persistent ;

IN: mongodb.tuple

<PRIVATE

CONSTANT: MDB_SLOTOPT_PROP "mdb_slot_options"
CONSTANT: MDB_P_SLOTS { "_id" } 
CONSTANT: MDB_OID "_id"

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

: link-class ( class collection -- )
    tuck classes>> ! col class v{}
    [ 2dup member? [ 2drop ] [ push ] if ]
    [ 1vector >>classes ] if* drop ;

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

