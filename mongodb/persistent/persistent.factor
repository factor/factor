USING: accessors assocs classes fry kernel linked-assocs math mirrors
namespaces sequences strings vectors words bson.constants 
continuations ;

IN: mongodb.persistent

MIXIN: mdb-persistent

SLOT: _id

CONSTANT: MDB_P_SLOTS { "_id" } 
CONSTANT: MDB_OID "_id"

SYMBOL: mdb-op-seq

GENERIC# tuple>assoc 1 ( tuple exemplar -- assoc )

: tuple>linked-assoc ( tuple -- linked-assoc )
    <linked-hash> tuple>assoc ; inline

GENERIC# tuple>query 1 ( tuple examplar -- query-assoc )

GENERIC: mdb-collection>> ( tuple -- string )

GENERIC: mdb-slot-definitions>> ( tuple -- string )


DEFER: assoc>tuple
DEFER: create-mdb-command

<PRIVATE

CONSTANT: MDB_INFO "_mdb_info"

: <dbref> ( tuple -- dbref )
    [ mdb-collection>> ] [ _id>> ] bi dbref boa ; inline

: mdbinfo>tuple-class ( mdbinfo -- class )
    [ first ] keep second lookup ; inline

: make-tuple ( assoc -- tuple )
    [ MDB_INFO swap at mdbinfo>tuple-class new ] keep ! instance assoc
    [ dup <mirror> [ keys ] keep ] dip ! instance array mirror assoc
    '[ dup _ [ _ at assoc>tuple ] dip [ swap ] dip set-at ] each ;  

: persistent-info ( tuple -- pinfo )
    class V{ } clone tuck  
    [ [ name>> ] dip push ]
    [ [ vocabulary>> ] dip push ] 2bi ; inline

: id-or-f? ( key value -- key value boolean )
    over "_id" = 
    [ dup f = ] dip or ; inline

: write-persistent-info ( mirror exemplar assoc -- )
    [ drop ] dip 
    2dup [ "_id" ] 2dip [ over [ at ] dip ] dip set-at
    [ object>> persistent-info MDB_INFO ] dip set-at ;    

: persistent-tuple? ( object -- object boolean )
    dup mdb-persistent? ; inline

: ensure-value-ht ( key ht -- vht )
    2dup key?
    [ at ]
    [ [ H{ } clone dup ] 2dip set-at ] if ; inline

: data-tuple? ( tuple -- ? )
    dup tuple? [ assoc? [ f ] [ t ] if ] [ drop f ] if  ;

: write-tuple-fields ( mirror exemplar assoc -- )
    [ dup ] dip ! m e e a
    '[ id-or-f?
       [ 2drop ]
       [ persistent-tuple?
         [ _ keep
           [ mdb-collection>> ] keep
           [ create-mdb-command ] dip
           <dbref> ]
         [ dup data-tuple? _ [ ] if ] if
         swap _ set-at
       ] if
    ] assoc-each ; 

: prepare-assoc ( tuple exemplar -- assoc mirror exemplar assoc )
    [ <mirror> ] dip dup clone swap [ tuck ] dip swap ; inline
    
: ensure-mdb-info ( tuple -- tuple )    
    dup _id>> [ <oid> >>_id ] unless ; inline
  
: with-op-seq ( quot -- op-seq )
    [
        [ H{ } clone mdb-op-seq set ] dip call mdb-op-seq get
    ] with-scope ; inline

PRIVATE>

: create-mdb-command ( assoc ns -- )
    mdb-op-seq get
    ensure-value-ht
    [ dup [ MDB_OID ] dip at ] dip
    set-at ; inline

: prepare-store ( mdb-persistent -- op-seq )
    '[ _ [ tuple>linked-assoc ] keep mdb-collection>> create-mdb-command ]
    with-op-seq ; inline

M: mdb-persistent tuple>assoc ( tuple exemplar -- assoc )
    [ ensure-mdb-info ] dip ! tuple exemplar
    prepare-assoc
    [ write-persistent-info ]
    [ [ '[ _ tuple>assoc ] ] dip write-tuple-fields ] 3bi ;

M: tuple tuple>assoc ( tuple exemplar -- assoc )
    [ drop persistent-info MDB_INFO ] 2keep
    prepare-assoc [ '[ _ tuple>assoc ] ] write-tuple-fields
    [ set-at ] keep ;

M: tuple tuple>query ( tuple examplar -- assoc )
    prepare-assoc [ '[ _ tuple>query ] ] dip write-tuple-fields ;

: assoc>tuple ( assoc -- tuple )
    dup assoc?
    [ [ dup MDB_INFO swap key?
        [ make-tuple ]
        [ ] if ] [ drop ] recover
    ] [ ] if ; inline


