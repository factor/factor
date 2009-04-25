USING: accessors assocs fry io.encodings.binary io.sockets kernel math
math.parser mongodb.msg mongodb.operations namespaces destructors
constructors sequences splitting checksums checksums.md5 formatting
io.streams.duplex io.encodings.utf8 io.encodings.string combinators.smart
arrays hashtables sequences.deep vectors locals ;

IN: mongodb.connection

: md5-checksum ( string -- digest )
    utf8 encode md5 checksum-bytes hex-string ; inline

TUPLE: mdb-db name username pwd-digest nodes collections ;

TUPLE: mdb-node master? { address inet } remote ;

CONSTRUCTOR: mdb-node ( address master? -- mdb-node ) ;

TUPLE: mdb-connection instance node handle remote local ;

CONSTRUCTOR: mdb-connection ( instance -- mdb-connection ) ;

: check-ok ( result -- errmsg ? )
    [ [ "errmsg" ] dip at ] 
    [ [ "ok" ] dip at >integer 1 = ] bi ; inline 

: <mdb-db> ( name nodes -- mdb-db )
    mdb-db new swap >>nodes swap >>name H{ } clone >>collections ;

: master-node ( mdb -- node )
    nodes>> t swap at ;

: slave-node ( mdb -- node )
    nodes>> f swap at ;

: with-connection ( connection quot -- * )
    [ mdb-connection set ] prepose with-scope ; inline
    
: mdb-instance ( -- mdb )
    mdb-connection get instance>> ; inline

: index-collection ( -- ns )
    mdb-instance name>> "%s.system.indexes" sprintf ; inline

: namespaces-collection ( -- ns )
    mdb-instance name>> "%s.system.namespaces" sprintf ; inline

: cmd-collection ( -- ns )
    mdb-instance name>> "%s.$cmd" sprintf ; inline

: index-ns ( colname -- index-ns )
    [ mdb-instance name>> ] dip "%s.%s" sprintf ; inline

: send-message ( message -- )
    [ mdb-connection get handle>> ] dip '[ _ write-message ] with-stream* ;

: send-query-plain ( query-message -- result )
    [ mdb-connection get handle>> ] dip
    '[ _ write-message read-message ] with-stream* ;

: send-query-1result ( collection assoc -- result )
    <mdb-query-msg>
        1 >>return#
    send-query-plain objects>>
    [ f ] [ first ] if-empty ;

<PRIVATE

: get-nonce ( -- nonce )
    cmd-collection H{ { "getnonce" 1 } } send-query-1result 
    [ "nonce" swap at ] [ f ] if* ;

: auth? ( mdb -- ? )
    [ username>> ] [ pwd-digest>> ] bi and ; 

: calculate-key-digest ( nonce -- digest )
    mdb-instance
    [ username>> ]
    [ pwd-digest>> ] bi
    3array concat md5-checksum ; inline

: build-auth-query ( -- query-assoc )
    { "authenticate" 1 }
    "user"  mdb-instance username>> 2array
    "nonce" get-nonce 2array
    3array >hashtable
    [ [ "nonce" ] dip at calculate-key-digest "key" ] keep
    [ set-at ] keep ; 
    
: perform-authentication ( --  )
    cmd-collection build-auth-query send-query-1result
    check-ok [ drop ] [ throw ] if ; inline

: authenticate-connection ( mdb-connection -- )
   [ mdb-connection get instance>> auth?
     [ perform-authentication ] when
   ] with-connection ; inline

: open-connection ( mdb-connection node -- mdb-connection )
   [ >>node ] [ address>> ] bi
   [ >>remote ] keep binary <client>
   [ >>handle ] dip >>local ;

: get-ismaster ( -- result )
    "admin.$cmd" H{ { "ismaster" 1 } } send-query-1result ; 

: split-host-str ( hoststr -- host port )
   ":" split [ first ] [ second string>number ] bi ; inline

: eval-ismaster-result ( node result -- )
   [ [ "ismaster" ] dip at >integer 1 = >>master? drop ]
   [ [ "remote" ] dip at
     [ split-host-str <inet> f <mdb-node> >>remote ] when*
     drop ] 2bi ;

: check-node ( mdb node --  )
   [ <mdb-connection> &dispose ] dip
   [ open-connection ] keep swap
   [ get-ismaster eval-ismaster-result ] with-connection ;

: nodelist>table ( seq -- assoc )
   [ [ master?>> ] keep 2array ] map >hashtable ;
   
PRIVATE>

:: verify-nodes ( mdb -- )
    [ [let* | acc [ V{ } clone ]
              node1 [ mdb dup master-node [ check-node ] keep ]
              node2 [ mdb node1 remote>>
                      [ [ check-node ] keep ]
                      [ drop f ] if*  ]
              | node1 [ acc push ] when*
                node2 [ acc push ] when*
                mdb acc nodelist>table >>nodes drop 
              ]
    ] with-destructors ; 
              
: mdb-open ( mdb -- mdb-connection )
    clone [ <mdb-connection> ] keep
    master-node open-connection
    [ authenticate-connection ] keep ; 

: mdb-close ( mdb-connection -- )
     [ dispose f ] change-handle drop ;

M: mdb-connection dispose
     mdb-close ;