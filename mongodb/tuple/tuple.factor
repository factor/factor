USING: accessors assocs classes classes.mixin classes.tuple vectors math
classes.tuple.parser formatting generalizations kernel sequences fry combinators
linked-assocs sequences.deep mongodb.driver continuations memoize
prettyprint strings compiler.units slots tools.walker words arrays ;

IN: mongodb.tuple

MIXIN: mdb-persistent

SLOT: _id
SLOT: _mdb_

GENERIC: mdb-collection-prop ( object -- mdb-collection )
GENERIC: mdb-slot-list  ( tuple -- string )

CONSTANT: MDB_COLLECTION_MAP "_mdb_col_map"
CONSTANT: MDB_COLLECTION     "_mdb_col"
CONSTANT: MDB_SLOTDEF_LIST   "_mdb_slot_list"

SYMBOLS: +transient+ +load+ +fieldindex+ +compoundindex+ +deepindex+ ;

TUPLE: mdb-tuple-collection < mdb-collection { classes sequence } ;
TUPLE: mdb-tuple-index name key ;

USE: mongodb.persistent 

<PRIVATE

: MDB_ADDON_SLOTS ( -- slots )
    { } [ MDB_OID MDB_PROPERTIES ] with-datastack ; inline

: (mdb-collection) ( class -- mdb-collection )     
    dup MDB_COLLECTION word-prop
    [ [ drop ] dip ]
    [ superclass [ (mdb-collection) ] [ f ] if* ] if* ; inline recursive

: (mdb-slot-list) ( class -- slot-defs )
    superclasses [ MDB_SLOTDEF_LIST word-prop ] map assoc-combine  ; inline 

: link-class ( class collection -- )
    over classes>>
    [ 2dup member? [ 2drop ] [ push ] if ]
    [ 1vector >>classes ] if* drop ; inline

: link-collection ( class collection -- )
    [ swap link-class ] [ MDB_COLLECTION set-word-prop ] 2bi ; inline

PRIVATE>

M: tuple-class mdb-collection-prop ( tuple -- mdb-collection )
    (mdb-collection) ;
 
M: mdb-persistent mdb-collection-prop ( tuple -- mdb-collection )
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
             [ [ >>name ] keep ] dip set-at ] if ;
         
<PRIVATE

: mdb-check-slots ( superclass slots -- superclass slots )
    over all-slots [ name>> ] map [ MDB_OID ] dip member?
    [  ] [ MDB_ADDON_SLOTS prepend ] if ; inline
  
PRIVATE>

: show-persistence-info ( class -- )
     H{ } clone 
     [ [ mdb-collection-prop "collection" ] dip set-at ] 2keep
     [ [ mdb-slot-list "slots" ] dip set-at ] keep . ;

: MDBTUPLE:
    parse-tuple-definition
    mdb-check-slots
    define-tuple-class ; parsing

<PRIVATE

: split-optl ( seq -- key options )
    [ first ] [ rest ] bi ; inline

: opt>assoc ( seq -- assoc )
    [ dup assoc?
      [ 1array { "" } append ] unless ] map ;

: optl>map ( seq -- map )
    H{ } clone tuck
    '[ split-optl opt>assoc swap _ set-at ] each ; inline

: set-slot-options ( class options -- )
    '[ MDB_SLOTDEF_LIST _ optl>map set-word-prop ] keep
    dup mdb-collection-prop link-collection ; inline

PRIVATE>

: set-collection ( class collection options -- )
    [ [ dup ] dip link-collection ] dip ! cl options
    [ dup '[ _ mdb-persistent add-mixin-instance ] with-compilation-unit ] dip 
    set-slot-options ;

<PRIVATE

: index-type ( type -- name )
    { { +fieldindex+ [ "field" ] }
      { +deepindex+ [ "deep" ] }
      { +compoundindex+ [ "compound" ] } } case ;
  
: index-name ( slot index-spec -- name )
    [ first index-type ] keep
    rest "-" join
    "%s-%s-%s-Idx" sprintf ;

: build-index ( element slot -- assoc )
    swap [ <linked-hash> ] 2dip
    [ rest ] keep first ! assoc slot options itype
    { { +fieldindex+ [ drop [ 1 ] dip pick set-at  ] }
      { +deepindex+ [ first "%s.%s" sprintf [ 1 ] dip pick set-at ] }
      { +compoundindex+ [
          2over swap [ 1 ] 2dip set-at [ drop ] dip ! assoc options
          over '[ _ [ 1 ] 2dip set-at ] each ] }
    } case ;

: build-index-seq ( slot optlist -- index-seq )
    [ V{ } clone ] 2dip pick  ! v{} slot optl v{}      
    [ swap ] dip  ! v{} optl slot v{ }
    '[ _ mdb-tuple-index new ! element slot exemplar 
       2over swap index-name >>name  ! element slot clone
       [ build-index ] dip swap >>key _ push
    ] each ;

MEMO: is-index-declaration? ( entry -- ? )
    first
    { { +fieldindex+ [ t ] }
      { +compoundindex+ [ t ] }
      { +deepindex+ [ t ] }
      [ drop f ] } case ;

: build-tuple-index-list ( mdb-collection -- seq )
    mdb-slot-list V{ } clone tuck
    '[ [ is-index-declaration? ] filter
       build-index-seq _ push 
    ] assoc-each flatten ;

PRIVATE>

: clean-indices ( list list2 -- ) 2drop ;

: load-tuple-index-list ( mdb-collection -- indexlist )
    [ load-index-list ] dip
    '[ [ "ns" ] dip at _ name>> ensure-collection = ] filter ;

: ensure-tuple-index-list ( mdb-collection -- )
    [ build-tuple-index-list ] keep
    '[ [ _ name>> ] dip [ name>> ] [ key>> ] bi ensure-index ] each ;
