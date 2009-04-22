
USING: accessors arrays assocs bson.constants classes classes.tuple
combinators continuations fry kernel mongodb.driver sequences strings
vectors words combinators.smart literals ;

IN: mongodb.tuple

SINGLETONS: +transient+ +load+ ;

IN: mongodb.tuple.collection

FROM: mongodb.tuple => +transient+ +load+ ;

MIXIN: mdb-persistent

SLOT: _id
SLOT: _mfd

TUPLE: mdb-tuple-collection < mdb-collection { classes } ;

GENERIC: tuple-collection ( object -- mdb-collection )

GENERIC: mdb-slot-map  ( tuple -- string )

<PRIVATE

CONSTANT: MDB_COLLECTION     "_mdb_col"
CONSTANT: MDB_SLOTDEF_LIST   "_mdb_slot_list"
CONSTANT: MDB_COLLECTION_MAP "_mdb_col_map"

: (mdb-collection) ( class -- mdb-collection )     
    dup MDB_COLLECTION word-prop
    [ nip ]
    [ superclass [ (mdb-collection) ] [ f ] if* ] if* ; inline recursive

: (mdb-slot-map) ( class -- slot-defs )
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
   { $[ MDB_OID_FIELD MDB_META_FIELD ] } ; inline

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

: set-slot-map ( class options -- )
    optl>map MDB_SLOTDEF_LIST set-word-prop ; inline
  
M: tuple-class tuple-collection ( tuple -- mdb-collection )
    (mdb-collection) ;
 
M: mdb-persistent tuple-collection ( tuple -- mdb-collection )
    class (mdb-collection) ;
 
M: mdb-persistent mdb-slot-map ( tuple -- string )
    class (mdb-slot-map) ;

M: tuple-class mdb-slot-map ( class -- assoc )
    (mdb-slot-map) ;

M: mdb-collection mdb-slot-map ( collection -- assoc )
    classes>> [ mdb-slot-map ] map assoc-combine ;

<PRIVATE

: collection-map ( -- assoc )
    mdb-persistent MDB_COLLECTION_MAP word-prop
    [ mdb-persistent MDB_COLLECTION_MAP H{ } clone
      [ set-word-prop ] keep ] unless* ; inline

: slot-option? ( tuple slot option -- ? )
    [ swap mdb-slot-map at ] dip
    '[ _ swap key? ] [ f ] if* ;
  
PRIVATE>

GENERIC: <mdb-tuple-collection> ( name -- mdb-tuple-collection )
M: string <mdb-tuple-collection> ( name -- mdb-tuple-collection )
    collection-map [ ] [ key? ] 2bi 
    [ at ] [ [ mdb-tuple-collection new dup ] 2dip 
             [ [ >>name ] keep ] dip set-at ] if ; inline
M: mdb-tuple-collection <mdb-tuple-collection> ( mdb-tuple-collection -- mdb-tuple-collection ) ;
M: mdb-collection <mdb-tuple-collection> ( mdb-collection -- mdb-tuple-collection )
    [ name>> <mdb-tuple-collection> ] keep
    {
        [ capped>> >>capped ]
        [ size>> >>size ]
        [ max>> >>max ]
    } cleave ;

: transient-slot? ( tuple slot -- ? )
    +transient+ slot-option? ;

: load-slot? ( tuple slot -- ? )
    +load+ slot-option? ;
