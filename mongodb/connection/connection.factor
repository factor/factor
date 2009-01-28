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

: -push ( seq elt -- )
    swap push ; inline

: split-host-str ( hoststr -- host port )
    ":" split [ first ] keep
    second string>number ; inline

: check-nodes ( node -- nodelist )
    [ V{ } clone ] dip
    [ -push ] 2keep 
    dup inet>> ismaster-cmd ! vec node result
    dup [ "ismaster" ] dip at 
    >fixnum 1 =             ! vec node result
    [ [ t >>master? drop ] dip f ]
    [ [ f >>master? drop ] dip t ] if
    [ "remote" ] 2dip [ at split-host-str <inet> ] dip
    swap mdb-node boa swap
    [ push ] keep ;

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
