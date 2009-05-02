USING: kernel fry accessors formatting linked-assocs assocs sequences sequences.deep
mongodb.tuple.collection combinators mongodb.tuple.collection ; 

IN: mongodb.tuple

SINGLETONS: +fieldindex+ +compoundindex+ +deepindex+ ;

IN: mongodb.tuple.index

TUPLE: tuple-index name spec ;

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
    '[ _ tuple-index new ! element slot exemplar 
       2over swap index-name >>name  ! element slot clone
       [ build-index ] dip swap >>spec _ push
    ] each ;

: is-index-declaration? ( entry -- ? )
    first
    { { +fieldindex+ [ t ] }
      { +compoundindex+ [ t ] }
      { +deepindex+ [ t ] }
      [ drop f ] } case ;

PRIVATE>

: tuple-index-list ( mdb-collection/class -- seq )
    mdb-slot-map V{ } clone tuck
    '[ [ is-index-declaration? ] filter
       build-index-seq _ push 
    ] assoc-each flatten ;

