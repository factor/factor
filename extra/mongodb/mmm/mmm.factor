USING: accessors fry io io.encodings.binary io.servers.connection
io.sockets io.streams.byte-array kernel math mongodb.msg classes formatting
namespaces prettyprint tools.walker calendar calendar.format bson.writer.private
json.writer mongodb.operations.private mongodb.operations ;

IN: mongodb.mmm

SYMBOLS: mmm-port mmm-server-ip mmm-server-port mmm-server mmm-dump-output mmm-t-srv ; 

GENERIC: dump-message ( message -- )

: check-options ( -- )
    mmm-port get [ 27040 mmm-port set ] unless
    mmm-server-ip get [ "127.0.0.1" mmm-server-ip set ] unless
    mmm-server-port get [ 27017 mmm-server-port set ] unless
    mmm-server-ip get mmm-server-port get <inet> mmm-server set ;

: read-msg-binary ( -- )
    read-int32
    [ write-int32 ] keep
    4 - read write ;
    
: read-request-header ( -- msg-stub )
    mdb-msg new
    read-int32 MSG-HEADER-SIZE - >>length
    read-int32 >>req-id
    read-int32 >>resp-id
    read-int32 >>opcode ;
    
: read-request ( -- msg-stub binary )
    binary [ read-msg-binary ] with-byte-writer    
    [ binary [ read-request-header ] with-byte-reader ] keep ; ! msg-stub binary

: dump-request ( msg-stub binary -- )
    [ mmm-dump-output get ] 2dip
    '[ _ drop _ binary [ read-message dump-message ] with-byte-reader ] with-output-stream ;

: read-reply ( -- binary )
    binary [ read-msg-binary ] with-byte-writer ;

: forward-request-read-reply ( msg-stub binary -- binary )
    [ mmm-server get binary ] 2dip
    '[ _ opcode>> _ write flush
       OP_Query =
       [ read-reply ]
       [ f ] if ] with-client ; 

: dump-reply ( binary -- )
    [ mmm-dump-output get ] dip
    '[ _ binary [ read-message dump-message ] with-byte-reader ] with-output-stream ;

: message-prefix ( message -- prefix message )
    [ now timestamp>http-string ] dip
    [ class name>> ] keep
    [ "%s: %s" sprintf ] dip ; inline

M: mdb-query-msg dump-message ( message -- )
    message-prefix
    [ collection>> ] keep
    query>> >json
    "%s -> %s: %s \n" printf ;

M: mdb-insert-msg dump-message ( message -- )
    message-prefix
    [ collection>> ] keep
    objects>> >json
    "%s -> %s : %s \n" printf ;

M: mdb-reply-msg dump-message ( message -- )
    message-prefix
    [ cursor>> ] keep
    [ start#>> ] keep
    [ returned#>> ] keep
    objects>> >json
    "%s -> cursor: %d, start: %d, returned#: %d,  -> %s \n" printf ; 

M: mdb-msg dump-message ( message -- )
    message-prefix drop "%s \n" printf ;

: forward-reply ( binary -- )
    write flush ;

: handle-mmm-connection ( -- )
    read-request
    [ dump-request ] 2keep
    forward-request-read-reply
    [ dump-reply ] keep 
    forward-reply ; 

: start-mmm-server ( -- )
    output-stream get mmm-dump-output set
    <threaded-server> [ mmm-t-srv set ] keep 
    "127.0.0.1" mmm-port get <inet4> >>insecure
    binary >>encoding
    [ handle-mmm-connection ] >>handler
    start-server* ;

: run-mmm ( -- )
    check-options
    start-mmm-server ;
    
MAIN: run-mmm