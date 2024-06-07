! Copyright (C) 2023 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.syntax assocs base64 combinators
continuations crypto.xor endian http io io.encodings.string
io.encodings.utf8 kernel math math.bitwise multiline namespaces
random sequences strings ;
IN: http.websockets

CONSTANT: websocket-version "13"

: random-websocket-key ( -- base64 )
    16 random-bytes >base64 >string ;

: add-websocket-upgrade-headers ( request -- request )
    "connection" over header>> delete-at
    websocket-version "Sec-WebSocket-Version" set-header
    random-websocket-key "Sec-WebSocket-Key" set-header
    ! websocket-extensions "Sec-WebSocket-Extensions" set-header
    ! websocket-protocol "Sec-WebSocket-Protocol" set-header
    "Upgrade" "Connection" set-header
    "websocket" "Upgrade" set-header
    "no-cache" "Pragma" set-header
    "no-cache" "Cache-Control" set-header
    "permessage-deflate; client_max_window_bits" "Sec-WebSocket-Extensions" set-header
    dup url>> host>> "Host" set-header
    dup url>> [ "ws" = "http" "https" ? ] change-protocol drop ;

CONSTANT: websocket-opcode-continue-frame 0
CONSTANT: websocket-opcode-text-frame 1
CONSTANT: websocket-opcode-binary-frame 2
CONSTANT: websocket-opcode-connection-close-frame 8
CONSTANT: websocket-opcode-ping-frame 9
CONSTANT: websocket-opcode-pong-frame 0xa

ENUM: WEBSOCKET-CLOSE
{ WEBSOCKET-CLOSE-NORMAL 1000 }
{ WEBSOCKET-CLOSE-GOING-AWAY 1001 }
{ WEBSOCKET-CLOSE-PROTOCOL-ERROR 1002 }
{ WEBSOCKET-CLOSE-UNSUPPORTED-DATA 1003 }
{ WEBSOCKET-CLOSE-RESERVED 1004 }
{ WEBSOCKET-CLOSE-NO-STATUS-RECEIVED 1005 }
{ WEBSOCKET-CLOSE-ABNORMAL-CLOSURE 1006 }
{ WEBSOCKET-CLOSE-INVALID-FRAME-PAYLOAD-DATA 1007 }
{ WEBSOCKET-CLOSE-PRIVACY-VIOLATION 1008 }
{ WEBSOCKET-CLOSE-MESSAGE-TOO-BIG 1009 }
{ WEBSOCKET-CLOSE-MANDATORY-EXT 1010 }
{ WEBSOCKET-CLOSE-INTERNAL-SERVER-ERRO 1011 }
{ WEBSOCKET-CLOSE-TLS-HANDSHAKE 1015 } ;

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

: send-websocket-bytes ( bytes mask? opcode final? -- )
    output-stream get disposed>> [
        4drop
    ] [
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
        ] if flush
    ] if ;

: send-websocket-text ( bytes mask? opcode fin? -- )
    [ utf8 encode ] 3dip send-websocket-bytes ;

: read-payload ( -- payload )
    get-read-payload-length [ [ 4 read ] dip read xor-crypt ] [ read ] if ;

: send-pong ( payload -- )
    t 0xa t send-websocket-bytes ;

: send-masked-message ( payload -- )
    t 0x1 t send-websocket-text ;

: send-unmasked-message ( payload -- )
    f 0x2 t send-websocket-text ;

ERROR: unimplemented-opcode opcode message ;

: read-websocket ( -- obj opcode loop? )
    [
        read1 [
            ! [ 0x80 mask? drop ] [ 7 clear-bit ] bi
            7 clear-bit
            [
                {
                    { f [ "disconnected" f ] }
                    { 0 [ 0 "continuation frame" unimplemented-opcode t ] }
                    { 1 [ read-payload t ] }
                    { 2 [ read-payload utf8 decode t ] }
                    { 8 [ read-payload be> f ] }
                    { 9 [ read-payload [ send-pong ] keep t ] }
                    { 0xa [ read-payload t ] }
                    [ "fall-through" unimplemented-opcode ]
                } case
            ] guard
        ] [
            f f f
        ] if*
    ] [
        drop f f f
    ] recover ;

: read-websocket-loop ( quot: ( obj opcode -- loop? ) -- )
    '[ read-websocket _ dip and ] loop ; inline
