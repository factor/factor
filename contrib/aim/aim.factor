IN: aim
USING: kernel sequences lists stdio prettyprint strings namespaces math unparser threads vectors errors parser interpreter test io crypto ;

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
    "Sending: " print dup hexdump
    (send-aim) ;

: read-net ( n s -- bc )
    stream-read
    "Received: " print dup hexdump ;

: drop-header ( str -- )
    6 swap tail ;

: parse-snac ( str -- )
    "SNAC" print
    dup head-short .
    dup head-short .
    dup head-short .
    head-int . ;

: with-aim ( quot -- )
    conn get swap with-default-stream ;

: read-aim ( -- bc )
    [
        head-byte .
        head-byte .
    ] with-aim ;

: make-snac ( fam subtype flags req-id -- )
    4 >nvector { >short >short >short >int } papply ;

: send-first ( -- )
    [ 1 >int ] send-aim ;

: send-second ( -- )
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


: respond-second ( -- )
    [
        HEX: 17 HEX: 2 0 0 make-snac
        1 >short
        username get length >short
        username get

        ! password hash chunk
        25 >short
        10 >short append
        login-key get append
        password get string>md5 append
        client-md5-string get append
        string>md5 >string

        HEX: 4c >short
        HEX: 00 >short
        HEX: 16 >short HEX: 02 >short client-id-num get >short
        HEX: 03 >short client-id-string get length >short client-id-string get
        HEX: 17 >short HEX: 02 >short client-major-ver get >short
        HEX: 18 >short HEX: 02 >short client-minor-ver get >short
        HEX: 19 >short HEX: 02 >short client-lesser-ver get >short
        HEX: 1a >short HEX: 02 >short client-build-num get >short
        HEX: 14 >short HEX: 04 >short client-distro-num get >int
        HEX: 0f >short client-language get length >short client-language get
        HEX: 0e >short client-country get length >short client-country get
        HEX: 4a >short HEX: 01 >short client-ssi-flag get >byte
    ] send-aim ;

: parse-second ( str -- )
    ;
    ! drop-header
    ! dup parse-snac
    ! dup head-short-be swap head-string-nonull login-key set
    ! respond-second ;

: print-op ( op -- )
    "Op: " write . ;

: parse-server ( ip:port -- )
    ":" split [ first ] keep second string>number aim-chat-port set aim-chat-ip set ;

! : process-third-chunks ( bc -- )
    ! dup bc-bytes empty? [
        ! drop
    ! ] [
        ! dup head-short-be
        ! over head-short-be
        ! swap
        ! {
            ! { [ dup 1 = ] [ print-op over head-string-nonull . ] }
            ! { [ dup 5 = ] [ print-op over head-string-nonull dup . parse-server ] }
            ! { [ dup 6 = ] [ print-op over head-string-nonull dup . auth-code set ] }
            ! { [ dup 8 = ] [ print-op over head-string-nonull . ] }
            ! { [ t ] [ print-op over head-string-nonull . ] }
        ! } cond
        ! process-third-chunks
    ! ] ifte ;
! 
! : parse-third ( bc -- )
    ! dup drop-header
    ! dup parse-snac
    ! process-third-chunks ;

: send-third ( -- )
    [
        1 >int
        6 >short
        auth-code get length
        auth-code get
    ] send-aim ;

: send-fourth ( -- )
    [
        1 HEX: 17 0 HEX: 17 make-snac
        [ 1 4  HEX: 13 3  2 1  3 1  4 1  6 1  8 1  9 1  HEX: a 1  HEX: b 1 ]
        [ >short ] each
    ] send-aim ;

: send-fifth ( -- )
    [
        1 6 0 6 make-snac
    ] send-aim ;

: send-sixth ( -- )
    [
        1 8 0 8 make-snac
        [ 1 2 3 4 5 ] [ >short ] each
    ] send-aim ;

: send-bunch ( -- )
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
    [ 9 2 0 2 make-snac ] send-aim ;
    
: send-bunch2
    [
        HEX: 13 7 0 7 make-snac
    ] send-aim

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

: connect-aim ( -- )
    ! first server
    ! new connection stage
    ! send-first
    ! read-aim drop
    ! stage-num [ 1 + ] change

    ! normal transmission stage
    ! send-second
    ! read-aim parse-second
    ! read-aim parse-third
    ! read-aim drop
    ! conn get stream-close

    ! second server
    ! 1 stage-num set
    ! aim-chat-ip get aim-chat-port get <client> conn set
    ! send-third
    ! read-aim drop
    ! stage-num [ 1 + ] change
    ! ! read-aim
    ! send-fourth 
    ! send-fifth
    ! ! read-aim
    ! ! read-aim
    ! ! read-aim
    ! send-sixth
    ! send-bunch
    ! ! 9 [ drop read-aim drop ] each
    ! send-bunch2
    ;

: bug-demo ( -- )
    "username" "password" initialize
    send-first
    [ head-byte . ] with-aim 
    [ head-byte . ] with-aim 
    ;

: test-login ( <net> -- )
    "username" "password" initialize connect-aim ;

