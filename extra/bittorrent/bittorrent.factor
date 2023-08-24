! Copyright (C) 2020 John Benediktsson
! See https://factorcode.org/license.txt for BSD license
USING: accessors arrays assocs bencode byte-arrays byte-vectors
calendar checksums checksums.sha combinators destructors endian
grouping http.client io io.encodings.binary io.files
io.pathnames io.sockets io.streams.byte-array io.streams.duplex
kernel literals make math math.bitwise math.functions math.order
math.parser namespaces random ranges sequences splitting strings
timers ui ui.gadgets.panes ui.tools.listener urls ;

IN: bittorrent

<<
CONSTANT: ALPHANUMERIC $[
    [
        CHAR: a CHAR: z [a..b] %
        CHAR: A CHAR: Z [a..b] %
        CHAR: 0 CHAR: 9 [a..b] %
        ".-_~" %
    ] { } make
]

: random-peer-id ( -- bytes )
    20 [ ALPHANUMERIC random ] B{ } replicate-as ;
>>

SYMBOL: torrent-peer-id
torrent-peer-id [ random-peer-id ] initialize

SYMBOL: torrent-port
torrent-port [ 6881 ] initialize


! bitfield

: bitfield-index ( n -- j i )
    8 /mod 7 swap - ;

: set-bitfield ( elt n bitfield -- )
    [ bitfield-index rot ] dip -rot
    '[ _ _ [ set-bit ] [ clear-bit ] if ] change-nth ;

: check-bitfield ( n bitfield -- ? )
    [ bitfield-index swap ] dip nth swap bit? ;


! http

: http-get-bencode ( url -- obj )
    <get-request> BV{ } clone [
        '[ _ push-all ] do-http-request check-response drop
    ] keep B{ } like bencode> ;


! metainfo

GENERIC: load-metainfo ( obj -- metainfo )

M: url load-metainfo http-get-bencode ;

M: pathname load-metainfo
    binary [ read-bencode ] with-file-reader ;

M: string load-metainfo
    dup "http" head? [ >url ] [ <pathname> ] if load-metainfo ;

: info-hash ( metainfo -- hash )
    "info hash" swap dup '[
        drop _ "info" of >bencode sha1 checksum-bytes
    ] cache ;

: announce-url ( metainfo -- url )
    dup "announce-list" of [ nip first random ] [ "announce" of ] if* ;

: scrape-url ( metainfo -- url/f )
    announce-url dup path>>  "announce" subseq-of? [
        [ "announce" "scrape" replace ] change-path
    ] [ drop f ] if ;



! tracker

: tracker-url ( metainfo -- url )
    {
        [ announce-url >url ]
        [
            info-hash "info_hash" set-query-param
            torrent-peer-id get "peer_id" set-query-param
            torrent-port get "port" set-query-param
            0 "uploaded" set-query-param
            0 "downloaded" set-query-param
            1 "compact" set-query-param
        ]
        [
            { "info" "length" } [ of ] each
            "left" set-query-param
        ]
    } cleave ;

TUPLE: magnet display-name exact-length exact-topic
web-seed acceptable-source exact-source keyword-topic
manifest-topic address-tracker select-only peer ;

: magnet-link>magnet ( url -- magnet-url )
    [ magnet new ] dip
    >url query>> {
        [ "dn" of >>display-name ]
        [ "xl" of >>exact-length ]
        [ "xt" of >>exact-topic ]
        [ "ws" of >>web-seed ]
        [ "as" of >>acceptable-source ]
        [ "xs" of >>exact-source ]
        [ "kt" of >>keyword-topic ]
        [ "mt" of >>manifest-topic ]
        [ "tr" of >>address-tracker ]
        [ "so" of >>select-only ]
        [ "x.pe" of >>peer ]
    } cleave ;

: parse-peer4 ( peerbin -- inet4 )
    4 cut [
        [ number>string ] { } map-as "." join
    ] dip be> <inet4> ;

: parse-peer4s ( peersbin -- inet4s )
    dup array? [
        [ [ "ip" of ] [ "port" of ] bi <inet4> ] map
    ] [
        6 <groups> [ parse-peer4 ] map
    ] if ;

: parse-peer6 ( peerbin -- inet6 )
    16 cut [
        2 <groups> [ be> number>string ] map ":" join
    ] dip be> <inet6> ;

: parse-peer6s ( peersbin -- inet6s )
    18 <groups> [ parse-peer6 ] map ;

: load-tracker ( torrent -- response )
    tracker-url http-get-bencode
    "peers" over [ parse-peer4s ] change-at ;

: send-event ( torrent event -- response )
    [ tracker-url ] [ "event" set-query-param ] bi*
    http-get-bencode ;



! messages

TUPLE: handshake string reserved info-hash peer-id ;

: <handshake> ( info-hash peer-id -- handshake )
    handshake new
        "BitTorrent protocol" >byte-array >>string
        8 <byte-array> >>reserved
        swap >>peer-id
        swap >>info-hash ;

: read-handshake ( -- handshake/f )
    read1 [
        [ 48 + read ] keep cut 8 cut 20 cut handshake boa
    ] [ f ] if* ;

: write-handshake ( handshake -- )
    {
        [ string>> [ length write1 ] [ write ] bi ]
        [ reserved>> write ]
        [ info-hash>> write ]
        [ peer-id>> write ]
    } cleave flush ;

TUPLE: keep-alive ;
TUPLE: choke ;
TUPLE: unchoke ;
TUPLE: interested ;
TUPLE: not-interested ;
TUPLE: have index ;
TUPLE: bitfield bitfield ;
TUPLE: request index begin length ;
TUPLE: piece index begin block ;
TUPLE: cancel index begin length ;
TUPLE: port port ;
TUPLE: suggest-piece index ;
TUPLE: have-all ;
TUPLE: have-none ;
TUPLE: reject-request index begin length ;
TUPLE: allowed-fast index ;
TUPLE: extended id payload ;
TUPLE: unknown id payload ;

: read-int ( -- n/f ) 4 read [ be> ] [ f ] if* ;

: parse-message ( bytes -- message/f )
    unclip {
        ! Core Protocol
        { 0 [ drop choke boa ] }
        { 1 [ drop unchoke boa ] }
        { 2 [ drop interested boa ] }
        { 3 [ drop not-interested boa ] }
        { 4 [ 4 head be> have boa ] }
        { 5 [ bitfield boa ] }
        { 6 [ 4 cut 4 cut 4 head [ be> ] tri@ request boa ] }
        { 7 [ 4 cut 4 cut [ [ be> ] bi@ ] dip piece boa ] }
        { 8 [ 4 cut 4 cut 4 head [ be> ] tri@ cancel boa ] }

        ! DHT Extension
        { 9 [ be> port boa ] }

        ! Fast Extensions
        { 0x0D [ 4 head be> suggest-piece boa ] }
        { 0x0E [ drop have-all boa ] }
        { 0x0F [ drop have-none boa ] }
        { 0x10 [ 4 cut 4 cut 4 head [ be> ] tri@ reject-request boa ] }
        { 0x11 [ 4 head be> allowed-fast boa ] }

        ! Extension Protocol
        { 0x14 [ unclip swap extended boa ] }

        ! Hash Transfer Protocol
        ! { 0x15 [ "HashRequest" ] }
        ! { 0x16 [ "Hashes" ] }
        ! { 0x17 [ "HashReject" ] }
        [ swap unknown boa ]
    } case ;

: read-message ( -- message )
    read-int {
        { f [ f ] }
        { 0 [ keep-alive boa ] }
        [ read [ parse-message ] [ f ] if* ]
    } case ;

: write-int ( n -- ) 4 >be write ;

GENERIC: write-message ( message -- )

M: keep-alive write-message drop 0 write-int ;

M: choke write-message drop 1 write-int 0 write1 ;

M: unchoke write-message drop 1 write-int 1 write1 ;

M: interested write-message drop 1 write-int 2 write1 ;

M: not-interested write-message drop 1 write-int 3 write1 ;

M: have write-message
    5 write-int 4 write1 index>> write-int ;

M: bitfield write-message
    field>> dup length 1 + write-int 5 write1 write ;

M: request write-message
    [ index>> ] [ begin>> ] [ length>> ] tri
    13 write-int 6 write1 [ write-int ] tri@ ;

M: piece write-message
    [ index>> ] [ offset>> ] [ block>> ] tri
    dup length 9 + write-int 7 write1
    [ write-int ] [ write-int ] [ write ] tri* ;

M: cancel write-message
    [ index>> ] [ offset>> ] [ length>> ] tri
    13 write-int 8 write1 [ write-int ] tri@ ;

M: port write-message
    5 write-int 9 write1 port>> write-int ;

M: suggest-piece write-message
    5 write-int 0x0D write1 index>> write-int ;

M: have-all write-message drop 1 write-int 0x0E write1 ;

M: have-none write-message drop 1 write-int 0x0F write1 ;

M: reject-request write-message
    [ index>> ] [ begin>> ] [ length>> ] tri
    13 write-int 0x10 write1 [ write-int ] tri@ ;

M: allowed-fast write-message
    5 write-int 0x11 write1 index>> write-int ;

M: extended write-message
    [ payload>> ] [ id>> ] bi
    over length 2 + write-int 0x14 write1 write1 write ;

M: unknown write-message
    [ payload>> ] [ id>> ] bi
    over length 1 + write-int write1 write ;

: >message ( bytes -- message )
    binary [ read-message ] with-byte-reader ;

: message> ( message -- bytes )
    binary [ write-message ] with-byte-writer ;




SYMBOL: torrent-max-block-size
torrent-max-block-size [ 16384 ] initialize

SYMBOL: torrent-directory
torrent-directory [ "~/Desktop" ] initialize



: with-debug ( quot -- )
    ui-running? [
        get-listener output>> <pane-stream> swap
        '[ @ flush ] with-output-stream*
    ] [
        '[ @ flush ] with-global
    ] if ; inline


! connection

TUPLE: torrent metainfo tracker peers ;

:: <torrent> ( metainfo -- torrent )
    torrent new
        metainfo >>metainfo
        metainfo load-tracker >>tracker
        V{ } clone >>peers
    ;

: torrent-path ( torrent -- path )
    metainfo>> { "info" "name" } [ of ] each
    torrent-directory get prepend-path ;


DEFER: <peer>

: random-peer ( torrent -- peer )
    dup tracker>> "peers" of random <peer> ;

: update-tracker ( client -- client )
    dup metainfo>> load-tracker >>tracker ;


! peers

TUPLE: peer < disposable torrent remote stream local handshake
self-choking self-interested peer-choking peer-interested timer
#pieces piece-length bitfield current-index current-piece ;

DEFER: with-peer

:: <peer> ( torrent remote -- peer )
    peer new
        torrent >>torrent
        remote >>remote

        t >>self-choking
        f >>self-interested
        t >>peer-choking
        f >>peer-interested

        dup '[
            _ [ T{ keep-alive } write-message flush ] with-peer
        ] 30 seconds dup <timer> >>timer

        torrent metainfo>> "info" of
        "pieces" of length 20 / [ >>#pieces ] keep

        8 / ceiling <byte-array> >>bitfield

        torrent metainfo>> "info" of
        "piece length" of [ >>piece-length ] keep

        <byte-vector> >>current-piece
    ;

M: peer dispose
    dup timer>> stop-timer
    [ dispose f ] change-stream
    f >>local f >>remote drop ;

:: with-peer ( peer quot -- )
    [
        peer remote>> remote-address set
        peer local>> local-address set
        peer stream>> quot with-stream*
    ] with-scope ; inline

: connect-peer ( peer -- peer )
    dup remote>> binary <client> [ >>stream ] [ >>local ] bi* ;

: handshake-peer ( peer -- peer )
    dup torrent>> metainfo>> info-hash
    torrent-peer-id get <handshake> write-handshake
    read-handshake >>handshake ;

: fast-peer? ( peer -- ? )
    handshake>> reserved>> 7 swap nth 3 swap bit? ;

: unchoke-peer ( peer -- peer )
    T{ unchoke } write-message f >>self-choking
    T{ interested } write-message t >>self-interested
    flush ;

: choke-peer ( peer -- peer )
    T{ choke } write-message t >>self-choking
    T{ not-interested } write-message f >>self-interested
    flush ;

:: verify-block ( peer -- peer )
    peer current-piece>> sha1 checksum-bytes
    peer current-index>> 20 * dup 20 +
    peer torrent>> metainfo>>
    { "info" "pieces" } [ of ] each
    B{ } subseq-as assert=
    peer ;

:: save-block ( peer -- peer )
    peer torrent>> torrent-path binary [
        peer current-index>>
        peer piece-length>> *
        seek-absolute seek-output
        peer current-piece>> write
    ] with-file-appender peer ;

:: next-block ( peer -- peer )
    peer current-index>> [ 1 + ] [ 0 ] if*
    peer #pieces>>
    peer bitfield>> '[ _ check-bitfield ] find-integer-from
    peer current-index<<
    0 peer current-piece>> set-length
    peer ;

:: request-piece ( peer -- peer )
    peer current-index>>
    [ peer next-block current-index>> ] unless*
    peer current-piece>> length
    peer piece-length>> over - torrent-max-block-size get min
    [
        2drop
        peer
        verify-block
        save-block
        next-block
        request-piece
    ] [
        request boa write-message flush peer
    ] if-zero ;

GENERIC: handle-message ( peer message -- peer )

M: object handle-message drop ;

M: choke handle-message
    drop t >>peer-choking ;

M: unchoke handle-message
    drop f >>peer-choking
    dup self-choking>> [ next-block request-piece ] unless ;

M: interested handle-message
    drop t >>peer-interested ;

M: not-interested handle-message
    drop f >>peer-interested ;

M: have handle-message
    t swap index>> pick bitfield>> set-nth ;

M: bitfield handle-message
    2dup [ bitfield>> length ] bi@ assert=
    bitfield>> >>bitfield ;

M: request handle-message
    [ index>> ] [ begin>> ] [ length>> ] tri
    reject-request boa write-message ;

M: have-all handle-message
    drop [ length [ 255 ] B{ } replicate-as ] change-bitfield ;

M: have-none handle-message
    drop [ length <byte-array> ] change-bitfield ;

M:: piece handle-message ( peer message -- peer )
    peer current-index>> message index>> assert=
    peer current-piece>> length message begin>> assert=
    message [ block>> ] [ begin>> ] bi peer current-piece>> copy
    peer request-piece ;

: read-messages ( peer -- peer )
    [ read-message ] [ handle-message ] while* ;
