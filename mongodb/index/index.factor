USING: accessors assocs combinators formatting fry kernel memoize
linked-assocs mongodb.persistent mongodb.msg 
sequences sequences.deep io.encodings.binary
io.sockets prettyprint sets ;

IN: mongodb.index

DEFER: mdb-slot-definitions>> 

TUPLE: index name ns key ;

SYMBOLS: +fieldindex+ +compoundindex+ +deepindex+ ;

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

: build-index-seq ( slot optlist ns -- index-seq )
    [ V{ } clone ] 3dip ! v{} slot optl ns 
    [ index new ] dip ! v{} slot optl index ns
    >>ns
    [ pick ] dip swap ! v{} slot optl index v{}      
    [ swap ] 2dip  ! v{} optl slot index v{ }
    '[ _ _ ! element slot exemplar 
       clone 2over swap index-name >>name ! element slot clone
       [ build-index ] dip swap >>key _ push
    ] each ;

: is-index-declaration? ( entry -- ? )
    first
    { { +fieldindex+ [ t ] }
      { +compoundindex+ [ t ] }
      { +deepindex+ [ t ] }
      [ drop f ] } case ;

: index-assoc ( seq -- assoc )
     H{ } clone tuck '[ dup name>> _ set-at ] each ;

: delete-index ( name ns -- )
     "Drop index %s - %s" sprintf . ;

: clean-indices ( existing defined -- )
     [ index-assoc ] bi@ assoc-diff values
     [ [ name>> ] [ ns>> ] bi delete-index ] each ;

PRIVATE>

USE: mongodb.query

: load-indices ( mdb-collection -- indexlist )
     [ mdb>> name>> ] dip name>> "%s.%s" sprintf
     "ns" H{ } clone [ set-at ] keep [ index-ns ] dip <mdb-query-msg>
     '[ _ write-request read-reply ]
     [ mdb>> master>> binary ] dip with-client
     objects>> [ [ index new ] dip
                 [ [ "ns" ] dip at >>ns ]
                 [ [ "name" ] dip at >>name ]
                 [ [ "key"  ] dip at >>key ] tri
     ] map ;

: build-indices ( mdb-collection mdb -- seq )
    name>>
    [ [ mdb-slot-definitions>> ] keep name>> ] dip
    swap "%s.%s" sprintf
    [ V{ } clone ] 2dip pick
    '[ _ 
       [ [ is-index-declaration? ] filter ] dip 
       build-index-seq _ push 
    ] assoc-each flatten ;

: ensure-indices ( mdb-collection -- )
     [ load-indices ] keep mdb>> build-indices
     [ clean-indices ] keep
     V{ } clone tuck 
     '[ _  [ <linked-hash> tuple>query ] dip push ] each
     <mdb-insert-msg> mdb>> name>> "%s.system.indexes" sprintf >>collection
     [ mdb>> master>> binary ] dip '[ _ write-request ] with-client ;

     
: show-indices ( mdb-collection -- )
     load-indices . ;
