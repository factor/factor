USING: accessors arrays assocs bson.constants combinators
combinators.smart constructors destructors formatting fry hashtables
io io.pools io.sockets kernel linked-assocs math mongodb.connection
mongodb.msg parser prettyprint prettyprint.custom prettyprint.sections
sequences sets splitting strings
tools.continuations uuid memoize locals ;

IN: mongodb.driver

TUPLE: mdb-pool < pool mdb ;

TUPLE: mdb-cursor id query ;

TUPLE: mdb-collection
{ name string }
{ capped boolean initial: f }
{ size integer initial: -1 }
{ max integer initial: -1 } ;

CONSTRUCTOR: mdb-collection ( name -- collection ) ;

TUPLE: index-spec
{ ns string } { name string } { key hashtable } { unique? boolean initial: f } ;

CONSTRUCTOR: index-spec ( ns name key -- index-spec ) ;

M: mdb-pool make-connection
    mdb>> mdb-open ;

: <mdb-pool> ( mdb -- pool ) [ mdb-pool <pool> ] dip >>mdb ; inline

CONSTANT: PARTIAL? "partial?"

ERROR: mdb-error msg ;

M: mdb-error pprint* ( obj -- )
    msg>> text ;

: >pwd-digest ( user password -- digest )
    "mongo" swap 3array ":" join md5-checksum ; 

<PRIVATE

GENERIC: <mdb-cursor> ( id mdb-query-msg/mdb-getmore-msg -- mdb-cursor )

M: mdb-query-msg <mdb-cursor>
    mdb-cursor boa ;

M: mdb-getmore-msg <mdb-cursor>
    query>> mdb-cursor boa ;

: >mdbregexp ( value -- regexp )
   first <mdbregexp> ; inline

GENERIC: update-query ( mdb-result-msg mdb-query-msg/mdb-getmore-msg -- )

M: mdb-query-msg update-query 
    swap [ start#>> ] [ returned#>> ] bi + >>skip# drop ;

M: mdb-getmore-msg update-query
    query>> update-query ; 
      
: make-cursor ( mdb-result-msg mdb-query-msg/mdb-getmore-msg -- mdb-cursor/f )
    over cursor>> 0 > 
    [ [ update-query ]
      [ [ cursor>> ] dip <mdb-cursor> ] 2bi
    ] [ 2drop f ] if ;

DEFER: send-query

GENERIC: verify-query-result ( mdb-result-msg mdb-query-msg/mdb-getmore-msg -- mdb-result-msg mdb-query-msg/mdb-getmore-msg ) 

M: mdb-query-msg verify-query-result ;

M: mdb-getmore-msg verify-query-result
    over flags>> ResultFlag_CursorNotFound =
    [ nip query>> [ send-query-plain ] keep ] when ;
    
: send-query ( mdb-query-msg/mdb-getmore-msg -- mdb-cursor/f seq )
    [ send-query-plain ] keep
    verify-query-result 
    [ collection>> >>collection drop ]
    [ return#>> >>requested# ] 
    [ make-cursor ] 2tri
    swap objects>> ;

: make-collection-assoc ( collection assoc -- )
    [ [ name>> "create" ] dip set-at ]
    [ [ [ capped>> ] keep ] dip
      '[ _ _
         [ [ drop t "capped" ] dip set-at ]
         [ [ size>> "size" ] dip set-at ]
         [ [ max>> "max" ] dip set-at ] 2tri ] when
    ] 2bi ; 

PRIVATE>

SYNTAX: r/ ( token -- mdbregexp )
    \ / [ >mdbregexp ] parse-literal ; 

: with-db ( mdb quot -- * )
    '[ _ mdb-open &dispose _ with-connection ] with-destructors ; inline
  
: >id-selector ( assoc -- selector )
    [ MDB_OID_FIELD swap at ] keep
    H{ } clone [ set-at ] keep ;

: <mdb> ( db host port -- mdb )
   <inet> t [ <mdb-node> ] keep
   H{ } clone [ set-at ] keep <mdb-db>
   [ verify-nodes ] keep ;

GENERIC: create-collection ( name/collection -- )

M: string create-collection
    <mdb-collection> create-collection ;

M: mdb-collection create-collection
    [ [ cmd-collection ] dip
      <linked-hash> [ make-collection-assoc ] keep
      <mdb-query-msg> 1 >>return# send-query-plain drop ] keep
      [ ] [ name>> ] bi mdb-instance collections>> set-at ;
  
: load-collection-list ( -- collection-list )
    namespaces-collection
    H{ } clone <mdb-query-msg> send-query-plain objects>> ;

<PRIVATE

: ensure-valid-collection-name ( collection -- )
    [ ";$." intersect length 0 > ] keep
    '[ _ "contains invalid characters ( . $ ; )" "." glue throw ] when ; inline

: build-collection-map ( -- assoc )
    H{ } clone load-collection-list      
    [ [ "name" ] dip at "." split second <mdb-collection> ] map
    over '[ [ ] [ name>> ] bi _ set-at ] each ;

: ensure-collection-map ( mdb-instance -- assoc )
    dup collections>> dup keys length 0 = 
    [ drop build-collection-map [ >>collections drop ] keep ]
    [ nip ] if ; 

: (ensure-collection) ( collection mdb-instance -- collection )
    ensure-collection-map [ dup ] dip key?
    [ ] [ [ ensure-valid-collection-name ]
          [ create-collection ]
          [ ] tri ] if ; 
      
: reserved-namespace? ( name -- ? )
    [ "$cmd" = ] [ "system" head? ] bi or ;

: check-collection ( collection -- fq-collection )
    [let
        mdb-instance :> instance
        instance name>> :> instance-name
        dup mdb-collection? [ name>> ] when
        "." split1 over instance-name =
        [ nip ] [ drop ] if
        [ ] [ reserved-namespace? ] bi
        [ instance (ensure-collection) ] unless
        [ instance-name ] dip "." glue
    ] ;

: fix-query-collection ( mdb-query -- mdb-query )
    [ check-collection ] change-collection ; inline

GENERIC: get-more ( mdb-cursor -- mdb-cursor seq )

M: mdb-cursor get-more 
    [ [ query>> dup [ collection>> ] [ return#>> ] bi ]
      [ id>> ] bi <mdb-getmore-msg> swap >>query send-query ] 
    [ f f ] if* ;

PRIVATE>

: <query> ( collection assoc -- mdb-query-msg )
    <mdb-query-msg> ; inline

GENERIC# limit 1 ( mdb-query-msg limit# -- mdb-query-msg )

M: mdb-query-msg limit 
    >>return# ; inline

GENERIC# skip 1 ( mdb-query-msg skip# -- mdb-query-msg )

M: mdb-query-msg skip 
    >>skip# ; inline

: asc ( key -- spec ) 1 2array ; inline
: desc ( key -- spec ) -1 2array ; inline

: sort ( mdb-query-msg sort-quot -- mdb-query-msg )
    output>array [ 1array >hashtable ] map >>orderby ; inline

: key-spec ( spec-quot -- spec-assoc )
    output>array >hashtable ; inline

GENERIC# hint 1 ( mdb-query-msg index-hint -- mdb-query-msg )

M: mdb-query-msg hint 
    >>hint ;

GENERIC: find ( selector -- mdb-cursor/f seq )

M: mdb-query-msg find
    fix-query-collection send-query ;

M: mdb-cursor find
    get-more ;

GENERIC: explain. ( mdb-query-msg -- )

M: mdb-query-msg explain.
    t >>explain find nip . ;

GENERIC: find-one ( mdb-query-msg -- result/f )

M: mdb-query-msg find-one
    fix-query-collection 
    1 >>return# send-query-plain objects>>
    dup empty? [ drop f ] [ first ] if ;

GENERIC: count ( mdb-query-msg -- result )

M: mdb-query-msg count    
    [ collection>> "count" H{ } clone [ set-at ] keep ] keep
    query>> [ over [ "query" ] dip set-at ] when*
    [ cmd-collection ] dip <mdb-query-msg> find-one 
    [ check-ok nip ] keep '[ "n" _ at >fixnum ] [ f ] if ;

: lasterror ( -- error )
    cmd-collection H{ { "getlasterror" 1 } } <mdb-query-msg>
    find-one [ "err" ] dip at ;

GENERIC: validate. ( collection -- )

M: string validate.
    [ cmd-collection ] dip
    "validate" H{ } clone [ set-at ] keep
    <mdb-query-msg> find-one [ check-ok nip ] keep
    '[ "result" _ at print ] [  ] if ;

M: mdb-collection validate.
    name>> validate. ;

<PRIVATE

: send-message-check-error ( message -- )
    send-message lasterror [ mdb-error ] when* ;

PRIVATE>

GENERIC: save ( collection assoc -- )
M: assoc save
    [ check-collection ] dip
    <mdb-insert-msg> send-message-check-error ;

GENERIC: save-unsafe ( collection assoc -- )
M: assoc save-unsafe
    [ check-collection ] dip
    <mdb-insert-msg> send-message ;

GENERIC: ensure-index ( index-spec -- )
M: index-spec ensure-index
    <linked-hash> [ [ uuid1 "_id" ] dip set-at ] keep
    [ { [ [ name>> "name" ] dip set-at ]
        [ [ ns>> index-ns "ns" ] dip set-at ]
        [ [ key>> "key" ] dip set-at ]
        [ swap unique?>>
          [ swap [ "unique" ] dip set-at ] [ drop ] if* ] } 2cleave
    ] keep
    [ index-collection ] dip save ;

: drop-index ( collection name -- )
    H{ } clone
    [ [ "index" ] dip set-at ] keep
    [ [ "deleteIndexes" ] dip set-at ] keep
    [ cmd-collection ] dip <mdb-query-msg>
    find-one drop ;

: <update> ( collection selector object -- mdb-update-msg )
    [ check-collection ] 2dip <mdb-update-msg> ;

: >upsert ( mdb-update-msg -- mdb-update-msg )
    1 >>upsert? ; 

GENERIC: update ( mdb-update-msg -- )
M: mdb-update-msg update
    send-message-check-error ;

GENERIC: update-unsafe ( mdb-update-msg -- )
M: mdb-update-msg update-unsafe
    send-message ;
 
GENERIC: delete ( collection selector -- )
M: assoc delete
    [ check-collection ] dip
    <mdb-delete-msg> send-message-check-error ;

GENERIC: delete-unsafe ( collection selector -- )
M: assoc delete-unsafe
    [ check-collection ] dip
    <mdb-delete-msg> send-message ;

: load-index-list ( -- index-list )
    index-collection
    H{ } clone <mdb-query-msg> find nip ;

: ensure-collection ( name -- )
    check-collection drop ;

: drop-collection ( name -- )
    [ cmd-collection ] dip
    "drop" H{ } clone [ set-at ] keep
    <mdb-query-msg> find-one drop ;


