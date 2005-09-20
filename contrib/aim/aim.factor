IN: aim
USING: kernel sequences lists stdio prettyprint strings namespaces math unparser threads vectors errors parser interpreter test io crypto words hashtables ;

SYMBOL: aim-login-server
SYMBOL: icq-login-server
SYMBOL: login-port

SYMBOL: client-md5-string
SYMBOL: client-id-string
SYMBOL: client-id-num
SYMBOL: client-major-ver
SYMBOL: client-minor-ver
SYMBOL: client-lesser-ver
SYMBOL: client-build-num
SYMBOL: client-distro-num
SYMBOL: client-language
SYMBOL: client-country
SYMBOL: client-ssi-flag

SYMBOL: username
SYMBOL: password
SYMBOL: conn
SYMBOL: seq-num 

SYMBOL: stage-num
SYMBOL: login-key
SYMBOL: aim-chat-ip
SYMBOL: aim-chat-port
SYMBOL: auth-code

SYMBOL: family
SYMBOL: opcode

: initialize ( username password -- )
    "login.oscar.aol.com" aim-login-server set
    "login.icq.com" icq-login-server set
    5190 login-port set

    "AOL Instant Messenger (SM)" client-md5-string set
    "AOL Instant Messenger, version 5.5 3595/WIN32" client-id-string set
    ! "AOL Instant Messenger, version 5.9 3690/WIN32" client-id-string set
    HEX: 109 client-id-num set
    5 client-major-ver set
    5 client-minor-ver set
    0 client-lesser-ver set
    3595 client-build-num set
    260 client-distro-num set
    "en" client-language set
    "us" client-country set
    1 client-ssi-flag set

    0 65535 random-int seq-num set
    1 stage-num set
    password set
    username set
    aim-login-server get login-port get <client> conn set ;

: get-seq-num ( -- int )
    seq-num get seq-num [ 1 + ] change ;

: (send-aim) ( str -- )
    conn get [ stream-write ] keep stream-flush ;

: (prepend-aim-protocol) ( data -- )
    [
        HEX: 2a >byte
        stage-num get >byte
        get-seq-num >short
    ] make-packet
    swap dup >r length >short r> append append ;

: send-aim ( data -- )
    make-packet
    (prepend-aim-protocol)
    "Sending: " write dup hexdump
    (send-aim) ;

: with-aim ( quot -- )
    conn get swap with-unscoped-stream ;

: read-aim ( -- bc )
    [
        head-byte drop
        head-byte drop
        head-short drop
        head-short head-string
    ] with-aim ;
    ! "Received: " write dup hexdump ;

: make-snac ( fam subtype flags req-id -- )
    4 >nvector { >short >short >short >int } papply ;

: parse-snac ( stream -- )
    head-short family set
    head-short opcode set
    head-short drop
    head-int drop ;

: (unhandled-opcode) ( -- )
    "Family: " write family get >hex "h" append write
    ", opcode: " write opcode get >hex "h" append writeln
    unscoped-stream get contents hexdump ;

: unhandled-opcode ( -- )
    "Unhandled opcode: " write (unhandled-opcode) ;

: incomplete-opcode ( -- )
    "Incomplete handling: " write (unhandled-opcode) ;

: unhandled-family-opcode ( -- )
    "Unhandled family: " write family get >hex "h" append writeln
    unhandled-opcode ;

! FAMILY/OPCODE TABLES
! returns handler table for a family
: FAMILY-TABLE
    {{
    }} ;

: add-family ( -- )
    word dup unparse "-" split second dup length 1- swap head hex> FAMILY-TABLE set-hash ; parsing

: FAMILY-1h
    {{
    }} ; add-family



: handle-3h-bh ( -- )
    ;

: FAMILY-3h ( -- hash)
    {{
        [[ HEX: b handle-3h-bh ]]
    }} ; add-family



: (drop-family-4h-header)
    head-short drop
    head-short drop
    head-short drop
    head-short drop
    8 head-string drop  ! message-id
    ;

    
: (parse-incoming-message-text) ( -- str )
    head-short drop head-short unscoped-stream get contents ;

: (parse-incoming-message-tlv2)
    unscoped-stream get empty? [
        head-byte
        head-byte drop ! fragVer
        head-short head-string <string-reader>
        [ 
            {
                { [ dup 1 = ] [ drop (parse-incoming-message-text) writeln ] }
                { [ dup 5 = ] [ drop ] }
                { [ t ] [ "Unknown frag: " write unparse writeln ] }
            } cond
        ] with-unscoped-stream
        (parse-incoming-message-tlv2)
    ] unless ;


: (parse-incoming-message-chunks)
    unscoped-stream get empty? [
        head-short
        head-short head-string <string-reader> [
            {
                { [ dup 2 = ] [ drop (parse-incoming-message-tlv2) ] }
                { [ dup 11 = ] [ 2drop ] }
                { [ dup 13 = ] [ drop ] }
                { [ t ] [ "Unhandled chunk: " write unparse writeln ] }
            } cond
        ] with-unscoped-stream
        (parse-incoming-message-chunks)
    ] unless ;

: (parse-incoming-message-tlv) ( n -- )
    [
        head-short
        head-short head-string <string-reader>
        [
            {
                { [ dup 1 = ] [ drop head-short drop ] }
                { [ dup 2 = ] [ drop 15 head-string drop ] }
                { [ dup 3 = ] [ drop ] }
                { [ dup 15 = ] [ drop ] }
                { [ dup 29 = ] [ drop ] }
                { [ t ] [ "Unknown tlv: " write unparse writeln ] }
            } cond
        ] with-unscoped-stream
    ] repeat ;

: handle-incoming-message ( -- )
    (drop-family-4h-header)
    head-short drop ! channel
    head-byte head-string "Incoming msg from " write write ": " write ! from name
    head-short drop ! warning-level
    head-short (parse-incoming-message-tlv)
    (parse-incoming-message-chunks)
    ;

: handle-typing-message ( -- )
    (drop-family-4h-header)
    head-short drop
    head-byte head-string write
    head-short
    {
        { [ dup 0 = ] [ drop " has an empty textbox." writeln ] }
        { [ dup 1 = ] [ drop " has entered text." writeln ] }
        { [ dup 2 = ] [ drop " is typing..." writeln ] }
        { [ t ] [ " does 4h.14h unknown: " write unparse writeln ] }
    } cond ;

: FAMILY-4h ( -- hash)
    {{
        [[ 7 handle-incoming-message ]]
        [[ HEX: 14 handle-typing-message ]]
    }} ; add-family




: FAMILY-13h ( -- hash)
    {{
    }} ; add-family

: (print-op) ( op -- )
    "Op: " write . ;

: (parse-server) ( ip:port -- )
    ":" split [ first ] keep second string>number aim-chat-port set aim-chat-ip set ;


: (process-login-chunks) ( stream -- )
    unscoped-stream get empty?  [
        head-short
        head-short
        swap
        {
            { [ dup 1 = ] [ (print-op) head-string . ] }
            { [ dup 5 = ] [ (print-op) head-string dup . (parse-server) ] }
            { [ dup 6 = ] [ (print-op) head-string dup . auth-code set ] }
            { [ dup 8 = ] [ (print-op) head-string . ] }
            { [ t ] [ (print-op) head-string . ] }
        } cond
        (process-login-chunks)
    ] unless ;

: handle-login-packet ( -- )
    (process-login-chunks) ;

: password-md5 ( password -- md5 )
    login-key get
    password get string>md5 append
    client-md5-string get append
    string>md5 >string ;

: respond-login-key-packet ( -- )
    [
        HEX: 17 HEX: 2 0 0 make-snac
        1 >short
        username get length >short
        username get

        ! password hash chunk
        HEX: 25 >short
        HEX: 10 >short
        password-md5

        HEX: 4c >short
        HEX: 00 >short
        HEX: 03 >short client-id-string get length >short client-id-string get
        HEX: 16 >short HEX: 02 >short client-id-num get >short
        HEX: 17 >short HEX: 02 >short client-major-ver get >short
        HEX: 18 >short HEX: 02 >short client-minor-ver get >short
        HEX: 19 >short HEX: 02 >short client-lesser-ver get >short
        HEX: 1a >short HEX: 02 >short client-build-num get >short
        HEX: 14 >short HEX: 04 >short client-distro-num get >int
        HEX: 0f >short client-language get length >short client-language get
        HEX: 0e >short client-country get length >short client-country get
        HEX: 4a >short HEX: 01 >short client-ssi-flag get >byte
    ] send-aim ;

: handle-login-key-packet ( -- )
    head-short head-string login-key set
    respond-login-key-packet ;

: FAMILY-17h ( -- hash)
    {{
        [[ 7 handle-login-key-packet ]]
        [[ 3 handle-login-packet ]]
    }} ; add-family




: handle-packet ( packet -- )
    <string-reader>
    [
        parse-snac
        family get FAMILY-TABLE hash dup [
            execute opcode get swap hash dup [
                execute ] [
                    unhandled-opcode drop
                ] ifte
            ] [
            unhandled-family-opcode
            drop
        ] ifte
        unscoped-stream get empty? [ incomplete-opcode ] unless
    ] with-unscoped-stream ;

: send-first-login ( -- )
    [ 1 >int ] send-aim ;

: send-first-request-auth ( -- )
    stage-num [ 1 + ] change
    [
        HEX: 17 HEX: 6 0 0 make-snac
        1 >short
        username get length >short
        username get
        HEX: 4b >short
        HEX: 00 >short
        HEX: 5a >short
        HEX: 00 >short
    ] send-aim ;

: send-second-login
    [
        1 >int
        6 >short
        auth-code get length >short
        auth-code get
    ] send-aim ;

: send-second-bunch ( -- )
    stage-num [ 1 + ] change
    [
        1 HEX: 17 0 HEX: 17 make-snac
        [ 1 4  HEX: 13 3  2 1  3 1  4 1  6 1  8 1  9 1  HEX: a 1  HEX: b 1 ]
        [ >short ] each
    ] send-aim
    [ 1 6 0 6 make-snac ] send-aim
    [ 1 8 0 8 make-snac [ 1 2 3 4 5 ] [ >short ] each ] send-aim
    [ 1 HEX: e 0 HEX: e make-snac ] send-aim
    [ HEX: 13 2 0 2 make-snac ] send-aim
    [
        HEX: 13 5 HEX: 7e6d 5 make-snac
        HEX: 41c1 >int
        HEX: 3670 >int
        HEX: bb >short
    ] send-aim
    [ 2 2 0 2 make-snac ] send-aim
    [ 2 3 0 2 make-snac ] send-aim
    [ 3 2 0 2 make-snac ] send-aim
    [ 4 4 0 4 make-snac ] send-aim
    [ 9 2 0 2 make-snac ] send-aim
    [ HEX: 13 7 0 7 make-snac ] send-aim
    [
        2 4 0 4 make-snac
        5 >short
        HEX: d >short
        [
            HEX: 094601054c7f11d1 HEX: 8222444553540000
            HEX: 0946134a4c7f11d1 HEX: 8222444553540000
            HEX: 0946134b4c7f11d1 HEX: 8222444553540000
            HEX: 748f2420628711d1 HEX: 8222444553540000
            HEX: 0946134d4c7f11d1 HEX: 8222444553540000
            HEX: 094613414c7f11d1 HEX: 8222444553540000
            HEX: 094600004c7f11d1 HEX: 8222444553540000
            HEX: 094613434c7f11d1 HEX: 8222444553540000
            HEX: 094601ff4c7f11d1 HEX: 8222444553540000
            HEX: 094601014c7f11d1 HEX: 8222444553540000
            HEX: 094613454c7f11d1 HEX: 8222444553540000
            HEX: 094601034c7f11d1 HEX: 8222444553540000
            HEX: 094613474c7f11d1 HEX: 8222444553540000
        ] [ >long ] each
        6 >short
        6 >short
        4 >short
        2 >short
        2 >short
    ] send-aim
    [
        4 2 0 2 make-snac
        0 >int
        HEX: b >short
        HEX: 1f40 >short
        HEX: 03e70 >short
        HEX: 03e70 >short
        0 >int
    ] send-aim
    [
        1 2 0 2 make-snac
        [
            HEX: 1 HEX: 4 HEX: 110 HEX: 8f1
            HEX: 13 HEX: 3 HEX: 110 HEX: 8f1
            HEX: 2 HEX: 1 HEX: 110 HEX: 8f1
            HEX: 3 HEX: 1 HEX: 110 HEX: 8f1
            HEX: 4 HEX: 4 HEX: 110 HEX: 8f1
            HEX: 6 HEX: 1 HEX: 110 HEX: 8f1
            HEX: 8 HEX: 1 HEX: 104 HEX: 8f1
            HEX: 9 HEX: 1 HEX: 110 HEX: 8f1
            HEX: a HEX: 1 HEX: 110 HEX: 8f1
            HEX: b HEX: 1 HEX: 110 HEX: 8f1
        ] [ >short ] each
    ] send-aim ;

: handle-loop ( -- )
    read-aim handle-packet handle-loop ;

: first-server
    ! first server
    1 stage-num set
    send-first-login read-aim drop

    ! normal transmission stage
    send-first-request-auth read-aim handle-packet
    read-aim handle-packet
    read-aim drop
    conn get stream-close ;

: second-server
    1 stage-num set
    aim-chat-ip get aim-chat-port get <client> conn set
    send-second-login read-aim drop

    ! normal transmission stage
    send-second-bunch ;

: connect-aim ( -- )
    first-server
    aim-chat-ip get 
    [ "No aim server received (too many logins, try again later)" throw ] unless
    second-server [ handle-loop ] in-thread ;

: run ( username password -- )
    initialize connect-aim ;
    ! [ initialize connect-aim ] with-scope ;

! my aim test account.  you can use it.
: run-test-account
    "FactorTest" "factoraim" run ;

