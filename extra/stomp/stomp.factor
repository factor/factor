! Copyright (C) 2024 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors arrays assocs calendar combinators
concurrency.mailboxes continuations io io.files io.timeouts
kernel linked-assocs math math.order math.parser mime.types
namespaces prettyprint sbufs sequences sequences.extras
splitting threads ;

IN: stomp

SYMBOL: stomp-username
SYMBOL: stomp-password

! http://stomp.github.io/stomp-specification-1.0.html
! http://stomp.github.io/stomp-specification-1.1.html
! http://stomp.github.io/stomp-specification-1.2.html

INITIALIZED-SYMBOL: stomp-version [ "1.1" ]

: escape-header ( key value -- key' value' )
    stomp-version get {
        { "1.0" [ ] }
        { "1.1" [ "\\" "\\\\" replace "\n" "\\n" replace ":" "\\c" replace ] }
        { "1.2" [ "\\" "\\\\" replace "\n" "\\n" replace ":" "\\c" replace "\r" "\\r" replace ] }
    } case ;

: unescape-header ( key value -- key' value' )
    stomp-version get {
        { "1.0" [ f ] }
        { "1.1" [ H{
            { CHAR: \\ CHAR: \\ }
            { CHAR: n  CHAR: \n }
            { CHAR: c  CHAR: :  } } ] }
        { "1.2" [ H{
            { CHAR: \\ CHAR: \\ }
            { CHAR: n  CHAR: \n }
            { CHAR: c  CHAR: :  }
            { CHAR: r  CHAR: \r } } ] }
    } case [
        [ "\\" split1 ] dip '[
            [ >sbuf ] dip [
                unclip-slice _ at* t assert= swap
                [ suffix! ]
                [ "\\" split1 [ append! ] dip ] bi*
            ] until-empty "" like
        ] unless-empty
    ] when* ;

: read-command ( -- command )
    readln ;

: read-headers ( -- headers )
    [ readln dup empty? not ]
    [ ":" split1 unescape-header 2array ] produce nip ;

: read-body ( content-length/f -- body )
    [ read read1 ] [ B{ 0 } read-until ] if* 0 assert= ;

TUPLE: frame command headers body ;

: <frame> ( command -- frame ) LH{ } clone f frame boa ;

: set-header ( frame header-value header-name -- frame )
    pick headers>> set-at ;

SYMBOL: stomp-debug?

: stomp-debug ( frame -- frame )
    stomp-debug? get [ [ dup . flush ] with-global ] when ;

! if receipts enabled, attach receipt-id to each outbound message using message counter or something
SYMBOL: stomp-receipts?
SYMBOL: stomp-receipt#
SYMBOL: stomp-receipt-disconnect

: receipt-id ( frame -- frame )
    dup command>> "DISCONNECT" = stomp-receipts? get or [
        stomp-receipt# counter number>string
        [ "receipt-id" set-header ]
        [
            over command>> "DISCONNECT" = [
                receipt-id stomp-receipt-disconnect set-global
            ] [ drop ] if
        ] bi
    ] when ;

: read-frame ( -- frame/f )
    read-command {
        { [ dup not ] [ ] }
        { [ dup empty? ] [ drop read-frame ] }
        [
            read-headers
            dup "content-length" of string>number
            read-body frame boa stomp-debug
        ]
    } cond ;

: wait-for-disconnect ( frame -- ? )
    stomp-receipt-disconnect get
    [ swap header>> "receipt-id" of = not ] [ drop t ] if* ;

:: read-frames ( quot: ( frame -- ) -- )
    [
        read-frame [
            dup quot call( frame -- ) wait-for-disconnect
        ] [ f ] if*
    ] loop ;

! 1.0: auto, client
! 1.1: auto, client, client-individual
! 1.2: auto, client, client-individual
INITIALIZED-SYMBOL: stomp-ack-mode [ "auto" ]

! XXX: write content-length for all messages
! XXX: make binary encoding, utf8 explicitly encode all fields

: write-frame ( frame -- )
    receipt-id stomp-debug
    [ command>> print ]
    [ headers>> [ escape-header ":" swap [ write ] tri@ nl ] assoc-each nl ]
    [ body>> [ write ] when* 0 write1 ] tri flush ;

SYMBOL: stomp-heartbeat

: stomp-connect ( -- frame )
    "CONNECT" <frame>
        stomp-version get "accept-version" set-header
        stomp-username get [ "login" set-header ] when*
        stomp-password get [ "passcode" set-header ] when*
        stomp-heartbeat get "0,0" or "heart-beat" set-header ;

: wait-for-connected ( -- frame )
    f [ drop read-frame dup command>> "CONNECTED" = not ] loop ;

: stomp-connect-and-wait ( -- frame )
    stomp-connect write-frame wait-for-connected ;

:: stomp-send ( destination body -- frame )
    "SEND" <frame>
        body >>body
        destination "destination" set-header ;

:: stomp-sendfile ( destination path -- frame )
    "SEND" <frame>
        destination "destination" set-header
        path dup mime-type
        [ mime-type-encoding file-contents >>body ]
        [ "content-type" set-header ] bi ;

SYMBOL: stomp-subscriptions
H{ } clone stomp-subscriptions set-global
SYMBOL: stomp-subscription#

:: stomp-subscribe ( destination -- frame )
    "SUBSCRIBE" <frame>
        destination stomp-subscriptions get [
            drop stomp-subscription# counter number>string
        ] cache :> id
        id "id" set-header
        destination "destination" set-header
        stomp-ack-mode get "auto" or "ack" set-header ;

:: stomp-unsubscribe ( destination -- frame )
    "UNSUBSCRIBE" <frame>
        destination stomp-subscriptions get at :> id
        id "id" set-header
        destination "destination" set-header ;

: stomp-begin ( transaction -- frame )
    "BEGIN" <frame> swap "transaction" set-header ;

: stomp-commit ( transaction -- frame )
    "COMMIT" <frame> swap "transaction" set-header ;

: stomp-ack-headers ( frame headers -- frame )
    ! XXX: stomp-transaction get transaction set-header
    stomp-version get {
        { "1.0" [ "message-id" of "message-id" set-header ] }
        { "1.1" [
            [ "subscription" of "subscription" set-header ]
            [ "message-id" of "message-id" set-header ] bi ] }
        { "1.2" [ "ack" of "id" set-header ] }
    } case ;

: stomp-ack ( message -- frame )
    "ACK" <frame> swap headers>> stomp-ack-headers ;

: stomp-nack ( message -- frame )
    "NACK" <frame> swap headers>> stomp-ack-headers ;

: stomp-abort ( transaction -- frame )
    "ABORT" <frame> swap "transaction" set-header ;

:: with-stomp-transaction ( transaction quot -- )
    [
        transaction stomp-begin write-frame
        quot call
        transaction stomp-abort write-frame
    ] [ drop transaction stomp-abort write-frame ] recover ; inline

: stomp-disconnect ( -- frame )
    "DISCONNECT" <frame> ;

: parse-heartbeat ( heartbeat -- x y )
    "0,0" or "," split1 [ string>number ] bi@ ;

: heartbeat-interval ( client server -- milliseconds )
    2dup [ 0 <= ] either? [ 2drop 0 ] [ max ] if ;

: adjust-stomp-version ( frame -- frame )
    dup headers>> "accept-version" of [
        '[ _ min ] stomp-version change
    ] when* ;

:: stomp-loop ( mailbox quot: ( frame -- ) -- )
    stomp-heartbeat get parse-heartbeat :> ( cx cy )

    10 seconds timeouts ! connect timeout
    stomp-connect-and-wait adjust-stomp-version
    f timeouts ! reset timeout

    headers>> "heart-beat" of "0,0" or
    "," split1 [ string>number ] bi@ :> ( sx sy )

    cx sy heartbeat-interval :> client-heartbeat-interval
    cy sx heartbeat-interval :> server-heartbeat-interval

    server-heartbeat-interval [
        2 * milliseconds timeouts ! read timeout
    ] unless-zero

    mailbox
    client-heartbeat-interval [ f ] when-zero
    stomp-version get "1.2" = "\n" "\r\n" ?
    '[
        [
            _ _ mailbox-get-timeout
            [ write-frame t ]
            [ stomp-disconnect write-frame f ] if*
        ] [ drop _ write flush t ] recover
    ] "stomp writer" spawn-server drop

    quot read-frames ;
