USING: accessors arrays assocs bson.constants classes
classes.tuple combinators constructors hashtables kernel
literals mongodb.driver mongodb.tuple sequences slots strings
vectors words ;

! XXX: This is weird, two IN: forms
IN: mongodb.tuple

SINGLETONS: +transient+ +load+ +user-defined-key+ ;

: <tuple-index> ( name key -- index-spec )
    index-spec new swap >>key swap >>name ;

IN: mongodb.tuple.collection

TUPLE: toid key value ;

CONSTRUCTOR: <toid> toid ( value key -- toid ) ;

FROM: mongodb.tuple => +transient+ +load+ <tuple-index> ;

MIXIN: mdb-persistent

SLOT: id
SLOT: _id
SLOT: _mfd

<PRIVATE

CONSTANT: MDB_COLLECTION     "mongodb_collection"
CONSTANT: MDB_SLOTDEF_MAP    "mongodb_slot_map"
CONSTANT: MDB_INDEX_MAP      "mongodb_index_map"
CONSTANT: MDB_USER_KEY       "mongodb_user_key"
CONSTANT: MDB_COLLECTION_MAP "mongodb_collection_map"

MEMO: id-slot ( class -- slot )
    MDB_USER_KEY word-prop
    dup [ drop "_id" ] unless ;

PRIVATE>

: >toid ( object -- toid )
    [ id>> ] [ class-of id-slot ] bi <toid> ;

M: mdb-persistent id>> ( object -- id )
    dup class-of id-slot reader-word execute( object -- id ) ;

M: mdb-persistent id<< ( object value -- )
    over class-of id-slot writer-word execute( object value -- ) ;



TUPLE: mdb-tuple-collection < mdb-collection { classes } ;

GENERIC: tuple-collection ( object -- mdb-collection )

GENERIC: mdb-slot-map  ( tuple -- assoc )

GENERIC: mdb-index-map ( tuple -- sequence )

<PRIVATE


: (mdb-collection) ( class -- mdb-collection )
    dup MDB_COLLECTION word-prop
    [ nip ]
    [ superclass-of [ (mdb-collection) ] [ f ] if* ] if* ; inline recursive

: (mdb-slot-map) ( class -- slot-map )
    superclasses-of [ MDB_SLOTDEF_MAP word-prop ] map assoc-union-all  ; inline

: (mdb-index-map) ( class -- index-map )
    superclasses-of [ MDB_INDEX_MAP word-prop ] map assoc-union-all ; inline

: split-optl ( seq -- key options )
    [ first ] [ rest ] bi ; inline

: optl>map ( seq -- map )
    [ H{ } clone ] dip over
    '[ split-optl swap _ set-at ] each ; inline

: index-list>map ( seq -- map )
    [ H{ } clone ] dip over
    '[ dup name>> _ set-at ] each ; inline

: user-defined-key ( map -- key value ? )
    [ nip [ +user-defined-key+ ] dip member? ] assoc-find ; inline

: user-defined-key-index ( class -- assoc )
    mdb-slot-map user-defined-key
    [ drop [ "user-defined-key-index" 1 ] dip
      associate <tuple-index> t >>unique?
      [ ] [ name>> ] bi associate
    ] [ 2drop H{ } clone ] if ;



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

: set-slot-map ( class option-list -- )
    optl>map [ MDB_SLOTDEF_MAP set-word-prop ] 2keep
    user-defined-key
    [ drop MDB_USER_KEY set-word-prop ] [ 3drop ] if ; inline

: set-index-map ( class index-list -- )
    [ dup user-defined-key-index ] dip index-list>map 2array
    assoc-union-all MDB_INDEX_MAP set-word-prop ; inline

M: tuple-class tuple-collection ( tuple -- mdb-collection )
    (mdb-collection) ;

M: mdb-persistent tuple-collection ( tuple -- mdb-collection )
    class-of (mdb-collection) ;

M: mdb-persistent mdb-slot-map ( tuple -- string )
    class-of (mdb-slot-map) ;

M: tuple-class mdb-slot-map ( class -- assoc )
    (mdb-slot-map) ;

M: mdb-collection mdb-slot-map ( collection -- assoc )
    classes>> [ mdb-slot-map ] map assoc-union-all ;

M: mdb-persistent mdb-index-map
    class-of (mdb-index-map) ;
M: tuple-class mdb-index-map
    (mdb-index-map) ;
M: mdb-collection mdb-index-map
    classes>> [ mdb-index-map ] map assoc-union-all ;

<PRIVATE

: collection-map ( -- assoc )
    mdb-persistent MDB_COLLECTION_MAP word-prop
    [ mdb-persistent MDB_COLLECTION_MAP H{ } clone
      [ set-word-prop ] keep ] unless* ; inline

: slot-option? ( tuple slot option -- ? )
    [ swap mdb-slot-map at ] dip
    '[ _ swap member-eq? ] [ f ] if* ;

PRIVATE>

GENERIC: <mdb-tuple-collection> ( name -- mdb-tuple-collection )
M: string <mdb-tuple-collection>
    collection-map [ ] [ key? ] 2bi
    [ at ] [ [ mdb-tuple-collection new dup ] 2dip
    [ [ >>name ] keep ] dip set-at ] if ; inline
M: mdb-tuple-collection <mdb-tuple-collection> ;
M: mdb-collection <mdb-tuple-collection>
    [ name>> <mdb-tuple-collection> ] keep
    {
        [ capped>> >>capped ]
        [ size>> >>size ]
        [ max>> >>max ]
    } cleave ;

: user-defined-key? ( tuple slot -- ? )
    +user-defined-key+ slot-option? ;

: transient-slot? ( tuple slot -- ? )
    +transient+ slot-option? ;

: load-slot? ( tuple slot -- ? )
    +load+ slot-option? ;
