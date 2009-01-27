USING: accessors assocs formatting kernel math classes sequences splitting strings
 words classes.tuple vectors ;

IN: mongodb.collection

GENERIC: mdb-slot-definitions>> ( tuple -- string )
GENERIC: mdb-collection>> ( object -- mdb-collection )

CONSTANT: MDB_COLLECTIONS "mdb_collections"

SYMBOLS: +transient+ +load+ ;

UNION: boolean t POSTPONE: f ;

TUPLE: mdb-collection
     { name string }
     { capped boolean initial: f }
     { size integer initial: -1 }
     { max integer initial: -1 }
     { classes sequence } ;

USING: mongodb.persistent mongodb.msg mongodb.tuple
mongodb.connection mongodb.query mongodb.index ;

<PRIVATE

CONSTANT: MDB_COL_PROP "mdb_collection"
CONSTANT: MDB_SLOTOPT_PROP "mdb_slot_options"

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

: load-collections ( -- collections )
    namespaces-ns
    H{ } clone <mdb-query-msg> (find)
    objects>> [ [ "name" ] dip at "." split second <mdb-collection> ] map
    dup [ ensure-indices ] each
    [ mdb>> ] dip >>collections collections>> ;

: check-ok ( result -- ? )
    [ "ok" ] dip key? ; inline 

: create-collection ( mdb-collection --  )
    dup name>> "create" H{ } clone [ set-at ] keep 
    [
        mdb>> [ master>> ] keep name>> "%s.$cmd" sprintf
    ] dip <mdb-query-one-msg> (find-one)
    check-ok
    [ [ ensure-indices ] keep dup name>> mdb>> collections>> set-at ]
    [ "could not create collection" throw ] if ; 

: get-collection-fqn ( mdb-collection -- fqdn )
    mdb>> collections>>
    dup keys length 0 =
    [ drop load-collections ]
    [ ] if
    [ dup name>> ] dip
    key?
    [ ]
    [ dup create-collection ] if
    name>> [ mdb>> name>> ] dip "%s.%s" sprintf ;
