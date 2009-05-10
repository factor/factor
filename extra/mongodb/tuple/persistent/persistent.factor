USING: accessors assocs bson.constants combinators.short-circuit
constructors continuations fry kernel mirrors mongodb.tuple.collection
mongodb.tuple.state namespaces sequences words bson.writer combinators
hashtables linked-assocs ;

IN: mongodb.tuple.persistent

SYMBOLS: object-map ;

GENERIC: tuple>assoc ( tuple -- assoc )

GENERIC: tuple>selector ( tuple -- selector )

DEFER: assoc>tuple

<PRIVATE

: mdbinfo>tuple-class ( tuple-info -- class )
   [ first ] keep second lookup ; inline

: tuple-instance ( tuple-info -- instance )
    mdbinfo>tuple-class new ; inline 

: prepare-assoc>tuple ( assoc -- tuple keylist mirror assoc )
   [ tuple-info tuple-instance dup
     <mirror> [ keys ] keep ] keep swap ; inline

: make-tuple ( assoc -- tuple )
   prepare-assoc>tuple
   '[ dup _ at assoc>tuple swap _ set-at ] each ; inline recursive

: at+ ( value key assoc -- value )
    2dup key?
    [ at nip ] [ [ dup ] 2dip set-at ] if ; inline

: data-tuple? ( tuple -- ? )
    dup tuple?
    [ assoc? not ] [ drop f ] if  ; inline

: add-storable ( assoc ns toid -- )
   [ [ H{ } clone ] dip object-map get at+ ] dip
   swap set-at ; inline

: write-field? ( tuple key value -- ? )
   pick mdb-persistent? [ 
      { [ [ 2drop ] dip not ]
        [ drop transient-slot? ] } 3|| not ] [ 3drop t ] if ; inline

TUPLE: cond-value value quot ;

CONSTRUCTOR: cond-value ( value quot -- cond-value ) ;

: write-mdb-persistent ( value quot: ( tuple -- assoc ) -- value' )
   over [ call( tuple -- assoc ) ] dip 
   [ [ tuple-collection name>> ] [ >toid ] bi ] keep
   [ add-storable ] dip
   [ tuple-collection name>> ] [ id>> ] bi <objref> ; inline

: write-field ( value quot: ( tuple -- assoc ) -- value' )
   <cond-value> {
      { [ dup value>> mdb-special-value? ] [ value>> ]  }
      { [ dup value>> mdb-persistent? ]
        [ [ value>> ] [ quot>> ] bi write-mdb-persistent ] }
      { [ dup value>> data-tuple? ]
        [ [ value>> ] [ quot>> ] bi (( tuple -- assoc )) call-effect ]  }
      { [ dup value>> [ hashtable? ] [ linked-assoc? ] bi or ]
        [ [ value>> ] [ quot>> ] bi '[ _ write-field ] assoc-map ] }
      [ value>> ]
   } cond ; inline recursive

: write-tuple-fields ( mirror tuple assoc quot: ( tuple -- assoc ) -- )
   swap ! m t q q a 
   '[ _ 2over write-field?
      [ _ write-field swap _ set-at ]
      [ 2drop ] if
   ] assoc-each ; 

: prepare-assoc ( tuple -- assoc mirror tuple assoc )
   H{ } clone swap [ <mirror> ] keep pick ; inline

: ensure-mdb-info ( tuple -- tuple )    
   dup id>> [ <objid> >>id ] unless ; inline

: with-object-map ( quot: ( -- ) -- store-assoc )
   [ H{ } clone dup object-map ] dip with-variable ; inline

: (tuple>assoc) ( tuple -- assoc )
   [ prepare-assoc [ tuple>assoc ] write-tuple-fields ] keep
   over set-tuple-info ; inline

PRIVATE>

GENERIC: tuple>storable ( tuple -- storable )

M: mdb-persistent tuple>storable ( mdb-persistent -- object-map )
   '[ _ [ tuple>assoc ] write-mdb-persistent drop ] with-object-map ; inline

M: mdb-persistent tuple>assoc ( tuple -- assoc )
   ensure-mdb-info (tuple>assoc) ;

M: tuple tuple>assoc ( tuple -- assoc )
   (tuple>assoc) ;

M: tuple tuple>selector ( tuple -- assoc )
    prepare-assoc [ tuple>selector ] write-tuple-fields ;

: assoc>tuple ( assoc -- tuple )
   dup assoc?
   [ [ dup tuple-info?
       [ make-tuple ]
       [ ] if ] [ drop ] recover
   ] [ ] if ; inline recursive

