USING: accessors assocs fry io.sockets kernel math mongodb.msg
namespaces sequences splitting math.parser io.encodings.binary ;

IN: mongodb.connection

TUPLE: mdb-node master? inet ;

TUPLE: mdb name nodes collections ;

: mdb>> ( -- mdb )
    mdb get ; inline

: with-db ( mdb quot -- ... )
    '[ _ mdb set _ call ] with-scope ;

: master>> ( mdb -- inet )
    nodes>> [ t ] dip at inet>> ;

: slave>> ( mdb -- inet )
    nodes>> [ f ] dip at inet>> ;

<PRIVATE

: ismaster-cmd ( node -- result )
    binary "admin.$cmd" H{ { "ismaster" 1 } } <mdb-query-one-msg>
    '[ _ write-message read-message ] with-client
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

: check-nodes ( node -- nodelist )
    check-node
    [ V{ } clone [ push ] keep ] dip
    [ split-host-str <inet> [ f ] dip
      mdb-node boa check-node drop
      swap tuck push
    ] when* ;

: verify-nodes ( -- )
    mdb>> nodes>> [ t ] dip at
    check-nodes
    H{ } clone tuck
    '[ dup master?>> _ set-at ] each
    [ mdb>> ] dip >>nodes drop ;

PRIVATE>

: (<mdb>) ( db host port -- mdb )
    [ f ] 2dip <inet> mdb-node boa
    check-nodes
    H{ } clone tuck
    '[ dup master?>> _ set-at ] each
    H{ } clone mdb boa ;
