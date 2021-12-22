! Copyright (C) 2021 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.enums alien.syntax assocs base64
byte-arrays combinators combinators.short-circuit crypto.xor
http http.client io io.binary io.encodings.string
io.encodings.utf8 kernel math math.bitwise multiline namespaces
prettyprint random sequences strings tools.hexdump ;
IN: http.websockets

! TODO: multiplexing, fragmented send

CONSTANT: websocket-version "13"

: random-websocket-key ( -- base64 )
    16 random-bytes >base64 >string ;

: add-websocket-headers ( request -- request )
    "connection" over header>> delete-at
    "Upgrade" "Connection" set-header
    "no-cache" "Pragma" set-header
    "no-cache" "Cache-Control" set-header
    "websocket" "Upgrade" set-header
    ! "http://www.websocket.org" "Origin" set-header
    "https://www.piesocket.com" "Origin" set-header
    websocket-version "Sec-WebSocket-Version" set-header
    random-websocket-key "Sec-WebSocket-Key" set-header
    "permessage-deflate; client_max_window_bits" "Sec-WebSocket-Extensions" set-header
    "gzip, deflate" "Accept-Encoding" set-header
    "en-US,en;q=0.9,sw-TZ;q=0.8,sw;q=0.7,es-US;q=0.6,es;q=0.5,de-DE;q=0.4,de;q=0.3,fr-FR;q=0.2,fr;q=0.1" "Accept-Language" set-header ;

: add-origin-header ( request origin -- request ) "Origin" set-header ;

ENUM: WEBSOCKET-OPCODE
    { WS-CONTINUE 0 }
    { WS-TEXT 1 }
    { WS-BINARY 2 }
    { WS-CONNECTION-CLOSE 8 }
    { WS-PING 9 }
    { WS-PONG 0xa } ;

: get-read-payload-length ( -- length masked? )
    read1 [
        {
            { [ dup 125 <= ] [ ] }
            { [ dup 126 = ] [ drop 2 read be> ] }
            { [ dup 127 = ] [ drop 8 read be> ] }
        } cond
    ] [
        0x80 mask?
    ] bi ;

: get-write-payload-length ( bytes -- length-byte length-bytes/f )
    length {
        { [ dup 125 <= ] [ f ] }
        { [ dup 0xffff <= ] [ [ drop 126 ] [ 2 >be ] bi ] }
        [ [ drop 127 ] [ 8 >be ] bi ]
    } cond ;

! The final packet of a fragmented send has high bit set
! opcode should be WS-TEXT or WS-binary
! mask is a random 4 bytes to XOR with the data, optional
: send-websocket-bytes ( bytes mask? opcode final? -- )
    0b10000000 0b0 ? bitor write1
    [
        [
            get-write-payload-length [ 0x80 bitor ] dip
            [ write1 ] [ [ write ] when* ] bi*
        ] [
            4 random-bytes
            [ write drop ]
            [ xor-crypt [ write ] when* ] 2bi
        ] bi
    ] [
        [ get-write-payload-length [ write1 ] [ [ write ] when* ] bi* ]
        [ [ write ] when* ] bi
    ] if flush ;

: send-websocket-text ( bytes mask? opcode fin? -- )
    [ utf8 encode ] 3dip send-websocket-bytes ;

: read-payload ( -- payload )
    get-read-payload-length [ [ 4 read ] dip read xor-crypt ] [ read ] if ;

: send-pong ( payload -- )
    t 0xa t send-websocket-bytes ;

SYMBOL: websocket-received

ERROR: unsupported-opcode n ;
: read-websocket ( -- loop? obj opcode )
    read1 [
        [ 0x80 mask? drop ] [ 7 clear-bit ] bi
        [
            WEBSOCKET-OPCODE number>enum
            {
                { f [ f "disconnected" ] }
                ! { WS-CONTINUE [ t websocket-received dup get push ] }
                { WS-TEXT [ t read-payload ] }
                { WS-BINARY [ t read-payload utf8 decode ] }
                { WS-CONNECTION-CLOSE [ f read1 ] }
                { WS-PING [ t read-payload [ send-pong ] keep ] }
                { WS-PONG [ t read-payload ] }
                [ unsupported-opcode ]
            } case
        ] keep
    ] [
        f f f
    ] if* ;

: read-websocket-loop ( quot -- )
    '[
        websocket-received V{ } clone [
            read-websocket @
        ] with-variable
    ] loop ; inline


: default-handle-websocket ( obj opcode -- )
    WEBSOCKET-OPCODE number>enum
    {
        { f [ [ drop "closed with error" . ] with-global ] }
        ! { WS-CONTINUE [  ] }
        { WS-TEXT [ [ [ hexdump. ] with-global ] when* ] }
        { WS-BINARY [ [ [ hexdump. ] with-global ] when* ] }
        { WS-CONNECTION-CLOSE [ [ [ . ] when* ] with-global ] }
        { WS-PING [ [ [ hexdump. ] with-global ] when* ] }
        [ 2drop ]
    } case ;

: check-websocket-upgraded? ( response -- ? )
    {
        [ code>> 101 = ]
        [
            header>> {
                [ "connection" of "upgrade" = ]
                [ "upgrade" of "websocket" = ]
            } 1&&
        ]
    } 1&& ;

: start-websocket ( url -- response )
    <get-request> add-websocket-headers http-request* drop
    dup check-websocket-upgraded? [ ] [ ] if ;
