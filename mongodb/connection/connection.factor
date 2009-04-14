USING: accessors assocs fry io.encodings.binary io.sockets kernel math
math.parser mongodb.msg mongodb.operations namespaces destructors
constructors sequences splitting ;

IN: mongodb.connection

TUPLE: mdb-db name username password nodes collections ;

TUPLE: mdb-node master? inet ;

CONSTRUCTOR: mdb-node ( inet master? -- mdb-node ) ;

TUPLE: mdb-connection instance handle remote local ;

: (<mdb-db>) ( name nodes -- mdb-db )
    mdb-db new swap >>nodes swap >>name H{ } clone >>collections ;

: master-node ( mdb -- inet )
    nodes>> [ t ] dip at inet>> ;

: slave-node ( mdb -- inet )
    nodes>> [ f ] dip at inet>> ;

: >mdb-connection ( stream -- )
    mdb-connection set ; inline

: mdb-connection> ( -- stream )
    mdb-connection get ; inline

: mdb-instance ( -- mdb )
    mdb-connection> instance>> ;

<PRIVATE


: ismaster-cmd ( node -- result )
    binary "admin.$cmd" H{ { "ismaster" 1 } } <mdb-query-msg>
    1 >>return# '[ _ write-message read-message ] with-client
    objects>> first ; 

: split-host-str ( hoststr -- host port )
    ":" split [ first ] keep
    second string>number ; inline

: eval-ismaster-result ( node result -- node result )
    [ [ "ismaster" ] dip at
      >fixnum 1 =
      [ t >>master? ] [ f >>master? ] if ] keep ;

: check-node ( node -- node remote )
    dup inet>> ismaster-cmd  
    eval-ismaster-result
    [ "remote" ] dip at ;

PRIVATE>

: check-nodes ( node -- nodelist )
    check-node
    [ V{ } clone [ push ] keep ] dip
    [ split-host-str <inet> [ f ] dip
      mdb-node boa check-node drop
      swap tuck push
    ] when* ;

: verify-nodes ( -- )
    mdb-instance nodes>> [ t ] dip at
    check-nodes
    H{ } clone tuck
    '[ dup master?>> _ set-at ] each
    [ mdb-instance ] dip >>nodes drop ;

: mdb-open ( mdb -- connection )
    mdb-connection new swap
    [ >>instance ] keep
    master-node [ >>remote ] keep
    binary <client> [ >>handle ] dip >>local ; inline    

: mdb-close ( mdb-connection -- )
     [ dispose f ] change-handle drop ;

M: mdb-connection dispose
     mdb-close ;