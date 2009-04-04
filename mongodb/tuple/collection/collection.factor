
USING: accessors arrays assocs bson.constants classes classes.tuple
continuations fry kernel mongodb.driver sequences
vectors words ;

IN: mongodb.tuple.collection

MIXIN: mdb-persistent

SLOT: _id
SLOT: _mfd

TUPLE: mdb-tuple-collection < mdb-collection { classes } ;

GENERIC: tuple-collection ( object -- mdb-collection )

GENERIC: mdb-slot-list  ( tuple -- string )

<PRIVATE

CONSTANT: MDB_COLLECTION     "_mdb_col"
CONSTANT: MDB_SLOTDEF_LIST   "_mdb_slot_list"
CONSTANT: MDB_COLLECTION_MAP "_mdb_col_map"

: (mdb-collection) ( class -- mdb-collection )     
    dup MDB_COLLECTION word-prop
    [ nip ]
    [ superclass [ (mdb-collection) ] [ f ] if* ] if* ; inline recursive

: (mdb-slot-list) ( class -- slot-defs )
    superclasses [ MDB_SLOTDEF_LIST word-prop ] map assoc-combine  ; inline 

: split-optl ( seq -- key options )
    [ first ] [ rest ] bi ; inline

: opt>assoc ( seq -- assoc )
    [ dup assoc?
      [ 1array { "" } append ] unless ] map ;

: optl>map ( seq -- map )
    H{ } clone tuck
    '[ split-optl opt>assoc swap _ set-at ] each ; inline

PRIVATE>

: MDB_ADDON_SLOTS ( -- slots )
    { } [ MDB_OID_FIELD MDB_META_FIELD ] with-datastack ; inline

: link-class ( collection class -- )
    over classes>>
    [ 2dup member? [ 2drop ] [ push ] if ]
    [ 1vector >>classes ] if* drop ; inline

: link-collection ( class collection -- )
    [ swap link-class ]
    [ MDB_COLLECTION set-word-prop ] 2bi ; inline

: mdb-check-slots ( superclass slots -- superclass slots )
    over all-slots [ name>> ] map [ MDB_OID_FIELD ] dip member?
    [  ] [ MDB_ADDON_SLOTS prepend ] if ; inline

: set-slot-options ( class options -- )
    '[ MDB_SLOTDEF_LIST _ optl>map set-word-prop ] keep
    dup tuple-collection link-collection ; inline
  
M: tuple-class tuple-collection ( tuple -- mdb-collection )
    (mdb-collection) ;
 
M: mdb-persistent tuple-collection ( tuple -- mdb-collection )
    class (mdb-collection) ;
 
M: mdb-persistent mdb-slot-list ( tuple -- string )
    class (mdb-slot-list) ;

M: tuple-class mdb-slot-list ( class -- assoc )
    (mdb-slot-list) ;

M: mdb-collection mdb-slot-list ( collection -- assoc )
    classes>> [ mdb-slot-list ] map assoc-combine ;

: collection-map ( -- assoc )
    MDB_COLLECTION_MAP mdb-persistent word-prop
    [ mdb-persistent MDB_COLLECTION_MAP H{ } clone
      [ set-word-prop ] keep ] unless* ; inline
  
: <mdb-tuple-collection> ( name -- mdb-tuple-collection )
    collection-map [ ] [ key? ] 2bi 
    [ at ] [ [ mdb-tuple-collection new dup ] 2dip 
             [ [ >>name ] keep ] dip set-at ] if ; inline

