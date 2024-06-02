USING: accessors arrays assocs byte-vectors checksums
checksums.md5 constructors continuations destructors hashtables
hex-strings io.encodings.binary io.encodings.string
io.encodings.utf8 io.sockets io.streams.duplex kernel math
math.parser mongodb.cmd mongodb.msg namespaces sequences
splitting strings ;
IN: mongodb.connection

: md5-checksum ( string -- digest )
    utf8 encode md5 checksum-bytes bytes>hex-string ; inline

TUPLE: mdb-db name username pwd-digest nodes collections ;

TUPLE: mdb-node master? { address inet } remote ;

CONSTRUCTOR: <mdb-node> mdb-node ( address master? -- mdb-node ) ;

TUPLE: mdb-connection < disposable instance node handle remote local buffer ;

: connection-buffer ( -- buffer )
    mdb-connection get buffer>> 0 >>length ; inline

USE: mongodb.operations

: <mdb-connection> ( instance -- mdb-connection )
    mdb-connection new-disposable swap >>instance ;

: check-ok ( result -- errmsg ? )
    [ [ "errmsg" ] dip at ]
    [ [ "ok" ] dip at ] bi ; inline

: <mdb-db> ( name nodes -- mdb-db )
    mdb-db new swap >>nodes swap >>name H{ } clone >>collections ;

: master-node ( mdb -- node )
    nodes>> t of ;

: slave-node ( mdb -- node )
    nodes>> f of ;

: with-connection ( connection quot -- * )
    [ mdb-connection ] dip with-variable ; inline

: mdb-instance ( -- mdb )
    mdb-connection get instance>> ; inline

: index-collection ( -- ns )
    mdb-instance name>> "system.indexes" "." glue ; inline

: namespaces-collection ( -- ns )
    mdb-instance name>> "system.namespaces" "." glue ; inline

: cmd-collection ( cmd -- ns )
    admin?>> [ "admin"  ] [ mdb-instance name>> ] if
    "$cmd" "." glue ; inline

: index-ns ( colname -- index-ns )
    [ mdb-instance name>> ] dip "." glue ; inline

: send-message ( message -- )
    [ mdb-connection get handle>> ] dip '[ _ write-message ] with-stream* ;

: send-query-plain ( query-message -- result )
    [ mdb-connection get handle>> ] dip
    '[ _ write-message read-message ] with-stream* ;

: send-query-1result ( collection assoc -- result )
    <mdb-query-msg> -1 >>return# send-query-plain
    objects>> ?first ;

: send-cmd ( cmd -- result )
    [ cmd-collection ] [ assoc>> ] bi send-query-1result ; inline

<PRIVATE

: get-nonce ( -- nonce )
    getnonce-cmd make-cmd send-cmd
    [ "nonce" of ] [ f ] if* ;

: auth? ( mdb -- ? )
    [ username>> ] [ pwd-digest>> ] bi and ;

: calculate-key-digest ( nonce -- digest )
    mdb-instance
    [ username>> ]
    [ pwd-digest>> ] bi
    3array concat md5-checksum ; inline

: build-auth-cmd ( cmd -- cmd )
    mdb-instance username>> "user" set-cmd-opt
    get-nonce [ "nonce" set-cmd-opt ] [ ] bi
    calculate-key-digest "key" set-cmd-opt ; inline

: perform-authentication ( -- )
    authenticate-cmd make-cmd
    build-auth-cmd send-cmd
    check-ok [ drop ] [ throw ] if ; inline

: authenticate-connection ( mdb-connection -- )
    [
        mdb-connection get instance>> auth?
        [ perform-authentication ] when
    ] with-connection ; inline

: open-connection ( mdb-connection node -- mdb-connection )
    [ >>node ] [ address>> ] bi
    [ >>remote ] keep binary <client>
    [ >>handle ] dip >>local 4096 <byte-vector> >>buffer ;

: get-ismaster ( -- result )
    "admin.$cmd" H{ { "ismaster" 1 } } send-query-1result ;

: split-host-str ( hoststr -- host port )
    ":" split [ first ] [ second string>number ] bi ; inline

: eval-ismaster-result ( node result -- )
    [
        [ "ismaster" ] dip at dup string?
        [ >integer 1 = ] when >>master? drop
    ] [
        [ "remote" ] dip at
        [ split-host-str <inet> f <mdb-node> >>remote ] when* drop
    ] 2bi ;

: check-node ( mdb node -- )
    [ <mdb-connection> &dispose ] dip
    [ [ open-connection ] [ 3drop f ] recover ] keep swap
    [ [ get-ismaster eval-ismaster-result ] with-connection ] [ drop ] if* ;

: nodelist>table ( seq -- assoc )
    [ [ master?>> ] keep 2array ] map >hashtable ;

PRIVATE>

:: verify-nodes ( mdb -- )
    [
        V{ } clone :> acc
        mdb dup master-node [ check-node ] keep :> node1
        mdb node1 remote>>
        [ [ check-node ] keep ]
        [ drop f ] if*  :> node2
        node1 [ acc push ] when*
        node2 [ acc push ] when*
        mdb acc nodelist>table >>nodes drop
    ] with-destructors ;

ERROR: mongod-connection-error address message ;

: mdb-open ( mdb -- mdb-connection )
    clone [ verify-nodes ] [ <mdb-connection> ] [ ] tri
    master-node [
        open-connection [ authenticate-connection ] keep
    ] [
        drop nip address>> "Could not open connection to mongod"
        mongod-connection-error
    ] recover ;

: mdb-close ( mdb-connection -- )
    [ [ dispose ] when* f ] change-handle drop ;

M: mdb-connection dispose* mdb-close ;
