! All Talk

IN: aim
USING: kernel sequences lists stdio prettyprint strings namespaces math unparser threads vectors errors parser interpreter test io crypto words hashtables inspector ;

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
SYMBOL: name
SYMBOL: message
SYMBOL: buddy-list

: aim-login-server "login.oscar.aol.com" ; inline
: icq-login-server "login.icq.com" ; inline
: login-port 5190 ; inline
: client-md5-string "AOL Instant Messenger (SM)" ; inline
: client-id-string "AOL Instant Messenger, version 5.5 3595/WIN32" ; inline
: client-id-num HEX: 109 ; inline
: client-major-ver 5 ; inline
: client-minor-ver 5 ; inline
: client-lesser-ver 0 ; inline
: client-build-num 3595 ; inline
: client-distro-num 260 ; inline
: client-language "en" ; inline
: client-country "us" ; inline
: client-ssi-flag 1 ; inline
: client-charset "text/aolrtf; charset=\"us-ascii\"" ; inline

! Family names from ethereal
: family-names
{{
    [[ 1 "Generic" ]]
    [[ 2 "Location" ]]
    [[ 3 "Buddylist" ]]
    [[ 4 "Messaging" ]]
    [[ 6 "Invitation" ]]
    [[ 8 "Popup" ]]
    [[ 9 "BOS" ]]
    [[ 10 "User Lookup" ]]
    [[ 11 "Stats" ]]
    [[ 12 "Translate" ]]
    [[ 19 "SSI" ]]
    [[ 21 "ICQ" ]]
    [[ 34 "Unknown Family" ]]
}} ;

: capability-names
{{
    [[ HEX: 094601054c7f11d18222444553540000 "Unknown1" ]]
    [[ HEX: 0946134a4c7f11d18222444553540000 "Games" ]]
    [[ HEX: 0946134b4c7f11d18222444553540000 "Send Buddy List" ]]
    [[ HEX: 748f2420628711d18222444553540000 "Chat" ]]
    [[ HEX: 0946134d4c7f11d18222444553540000 "AIM/ICQ Interoperability" ]]
    [[ HEX: 094613414c7f11d18222444553540000 "Voice Chat" ]]
    [[ HEX: 094600004c7f11d18222444553540000 "iChat" ]]
    [[ HEX: 094613434c7f11d18222444553540000 "Send File" ]]
    [[ HEX: 094601ff4c7f11d18222444553540000 "Unknown2" ]]
    [[ HEX: 094601014c7f11d18222444553540000 "Live Video" ]]
    [[ HEX: 094613454c7f11d18222444553540000 "Direct Instant Messaging" ]]
    [[ HEX: 094601034c7f11d18222444553540000 "Unknown3" ]]
    [[ HEX: 094613464c7f11d18222444553540000 "Buddy Icon" ]]
    [[ HEX: 094613474c7f11d18222444553540000 "Add-Ins" ]]
}} ;

: initialize-aim ( username password -- )
    password set username set
    {{ }} clone buddy-list set
    ! 65535 random-int seq-num set
    0 seq-num set
    1 stage-num set ;

: (prepend-aim-protocol) ( data -- )
    [
        HEX: 2a >byte
        stage-num get >byte
        seq-num get >short
    ] "" make
    seq-num [ 1+ ] change
    swap dup >r length (>short) r> append append ;

: (send-aim) ( str -- )
    "Sending: " print
    dup hexdump
    conn get [ stream-write ] keep stream-flush ;

: send-aim ( data -- )
    make-packet (prepend-aim-protocol) (send-aim) terpri ;

: with-aim ( quot -- )
    conn get swap with-unscoped-stream ;

: read-aim ( -- bc )
    [
        head-byte drop
        head-byte drop
        head-short drop
        head-short head-string
    ] with-aim
    "Received: " write dup hexdump ;

: make-snac ( fam subtype flags req-id -- )
    4vector { (>short) (>short) (>short) (>int) } papply % ;

: parse-snac ( stream -- )
    head-short family set
    head-short opcode set
    head-short drop
    head-int drop ;

: (unhandled-opcode) ( str -- )
    "Family: " write family get unparse write
    ", opcode: " write opcode get unparse writeln
    unscoped-stream get contents hexdump ;

: unhandled-opcode ( -- )
    "Unhandled opcode: " write (unhandled-opcode) ;

: incomplete-opcode ( -- )
    "Incomplete handling: " write (unhandled-opcode) ;

: unhandled-family-opcode ( -- )
    "Unhandled family: " write family get unparse writeln
    unhandled-opcode ;


! Events
: buddy-signon ( name -- )
    0 swap buddy-list get set-hash ;

: buddy-signoff ( name -- )
    buddy-list get remove-hash ;

: print-buddy-list
    [ buddy-list get hash-keys string-sort [ , ] each ] { } make [ drop ] simple-outliner ;




: family-table ( -- hash )
    {{ }} ;

: FAMILY: ( -- fam# )
    scan 10 base> swons dup car family-table hash dup [
        drop
    ] [
        drop {{ }} clone over car family-table set-hash
    ] if ; parsing

: OPCODE: ( fam# -- )
    car family-table hash word scan 10 base> rot set-hash f ; parsing



: (handle-reply-info)
    head-byte head-string name set
    "Warning: " write head-short unparse writeln
    head-short dup unparse print
    [
        head-short
        head-short head-string <string-reader> [
            {
                ! { [ 1 = ] [ drop head-short drop ] }
                ! { [ 3 = ] [ drop ] }
                ! { [ 5 = ] [ drop ] }
                ! { [ 10 = ] [ drop ] }
                ! { [ 13 = ] [ drop ] }
                ! { [ 15 = ] [ drop ] }
                ! { [ 29 = ] [ drop ] }
                ! { [ 30 = ] [ drop ] }
                ! { [ 34 = ] [ drop ] }
                { [ t ] [ "  Unhandled tlv 1-15: " write unparse writeln unscoped-stream get contents hexdump ] }
            } cond
        ] with-unscoped-stream
    ] repeat ;

: (handle-supported-families)
	unscoped-stream get empty? [
		head-short family-names hash .
		(handle-supported-families)
	] unless ;

: handle-supported-families
	"Families: " print
	(handle-supported-families) ; FAMILY: 1 OPCODE: 3

: handle-
	; FAMILY: 1 OPCODE: 7
: handle-
	; FAMILY: 1 OPCODE: 15
: handle-
	; FAMILY: 1 OPCODE: 19
: handle-
	; FAMILY: 1 OPCODE: 24


! : handle-reply-info
    ! "HANDLE REPLY INFO" print
    ! 4 [ head-short drop ] repeat
        ! (handle-reply-info)
    ! ; FAMILY: 1 OPCODE: 15

    ! unscoped-stream get empty? [
    ! ] unless ; FAMILY: 1 OPCODE: 15

: handle-2-1
	"2-1: " write head-short unparse writeln 
	; FAMILY: 2 OPCODE: 1

! : handle-
	! ; FAMILY: 2 OPCODE: 3

! : handle-away-message
    ! head-byte head-string name set
    ! name get write "'s away message: " write

    ! ; FAMILY: 2 OPCODE: 6


: handle-capabilities
    unscoped-stream get empty? [
        head-longlong capability-names hash dup [ "Unknown Capability" nip ] unless
        writeln handle-capabilities
    ] unless ;

: handle-29
    "(29)" print
    head-short drop
    head-byte drop
    head-byte head-string drop
    unscoped-stream get empty? [ handle-29 ] unless ;

: handle-buddy-status
    head-byte head-string name set
    head-short drop
    head-short
    [
        head-short
        head-short head-string <string-reader> [
            {
                { [ dup 1 = ] [ drop name get write head-short HEX: 20 bitand 1 > [ " is away." ] [ " is online." ] if writeln ] }
                { [ dup 2 = ] [ drop "Member since: " write head-short unparse writeln ] }
                { [ dup 3 = ] [ drop name get write " went online at " write head-int unparse writeln name get buddy-signon ] }
                { [ dup 4 = ] [ drop name get write " has been idle for " write head-short unparse write " minutes." writeln ] }
                { [ dup 6 = ] [ drop name get write ": (6): " write head-short unparse write " " write head-short unparse writeln ] }
                ! { [ dup 10 = ] [ drop ] } ! external ip
                ! { [ dup 12 = ] [ drop ] } ! same as CLI_SETSTATUS
                { [ dup 13 = ] [ drop "Capabilities:" print handle-capabilities  ] }
                { [ dup 14 = ] [ drop "Capabilities:" print handle-capabilities  ] }
                { [ dup 15 = ] [ drop name get write " has been online for " write head-int unparse write " seconds." writeln ] }
                { [ dup 27 = ] [ drop "(27): " write 4 [ head-int unparse write " " write ] repeat terpri ] }
                { [ dup 29 = ] [ drop handle-29 ] }
                { [ t ] [ "  Unhandled tlv 3h-bh: " write unparse writeln unscoped-stream get contents hexdump ] }
            } cond
        ] with-unscoped-stream
    ] repeat ; FAMILY: 3 OPCODE: 11

: handle-buddy-signoff ( -- )
    head-byte head-string name set
    head-short drop
    head-short
    [
        head-short
        head-short head-string <string-reader> [
            {
                { [ dup 1 = ] [ drop name get write " signed off." writeln name get buddy-signoff ] }
                { [ dup HEX: 1d = ] [ drop ] }
                { [ t ] [ "Unhandled tlv 3h-ch: " write unparse writeln unscoped-stream get contents hexdump ] }
            } cond
        ] with-unscoped-stream
    ] repeat ; FAMILY: 3 OPCODE: 12

: drop-family-4h-header
    head-short drop
    head-short drop
    head-short drop
    head-short drop
    8 head-string drop  ( message-id ) ;
    
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
                { [ t ] [ "Unknown frag: " write unparse writeln unscoped-stream get contents hexdump ] }
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
                { [ t ] [ "Unhandled chunk: " write unparse writeln unscoped-stream get contents hexdump ] }
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
                { [ t ] [ "Unknown tlv: " write unparse writeln unscoped-stream get contents hexdump ] }
            } cond
        ] with-unscoped-stream
    ] repeat ;

: handle-incoming-message ( -- )
    drop-family-4h-header
    head-short drop ! channel
    head-byte head-string "Incoming msg from " write write ": " write
    head-short drop ! warning-level
    head-short (parse-incoming-message-tlv)
    (parse-incoming-message-chunks) ; FAMILY: 4 OPCODE: 7

! : handle-4-12
	! head-short 2 / [ head-short drop ] repeat
	! head-cstring drop
	! head-short drop
	! head-byte head-string
	! ; FAMILY: 4 OPCODE: 12

: handle-typing-message ( -- )
    drop-family-4h-header
    head-short drop
    head-byte head-string write
    head-short
    {
        { [ dup 0 = ] [ drop " has an empty textbox." writeln ] }
        { [ dup 1 = ] [ drop " has entered text." writeln ] }
        { [ dup 2 = ] [ drop " is typing..." writeln ] }
        { [ t ] [ " does 4h.14h unknown: " write unparse writeln ] }
    } cond ; FAMILY: 4 OPCODE: 20


! : handle-
	! ; FAMILY: 19 OPCODE: 3

: print-op ( op -- )
    "Op: " write . ;

: (parse-server) ( ip:port -- )
    ":" split [ first ] keep second string>number aim-chat-port set aim-chat-ip set ;

: process-login-chunks ( stream -- )
    unscoped-stream get empty?  [
        head-short
        head-short
        swap
        {
            ! { [ dup 1 = ] [ print-op head-string . ] }
            { [ dup 5 = ] [ drop head-string (parse-server) ] }
            { [ dup 6 = ] [ drop head-string auth-code set ] }
            ! { [ dup 8 = ] [ print-op head-string . ] }
            ! { [ t ] [ print-op head-string . ] }
            { [ t ] [ drop head-string drop ] }
        } cond
        process-login-chunks
    ] unless ;

: handle-login-packet ( -- )
    process-login-chunks ; FAMILY: 23 OPCODE: 3

: password-md5 ( password -- md5 )
    login-key get
    password get string>md5 append
    client-md5-string append
    string>md5 >string ;

: respond-login-key-packet ( -- )
    [
        HEX: 17 HEX: 2 0 0 make-snac
        1 >short
        username get length >short
        username get %

        ! password hash chunk
        HEX: 25 >short
        HEX: 10 >short
        password-md5 %

        HEX: 4c >short
        HEX: 00 >short
        HEX: 03 >short client-id-string length >short client-id-string %
        HEX: 16 >short HEX: 02 >short client-id-num >short
        HEX: 17 >short HEX: 02 >short client-major-ver >short
        HEX: 18 >short HEX: 02 >short client-minor-ver >short
        HEX: 19 >short HEX: 02 >short client-lesser-ver >short
        HEX: 1a >short HEX: 02 >short client-build-num >short
        HEX: 14 >short HEX: 04 >short client-distro-num >int
        HEX: 0f >short client-language length >short client-language %
        HEX: 0e >short client-country length >short client-country %
        HEX: 4a >short HEX: 01 >short client-ssi-flag >byte
    ] send-aim ;

: handle-login-key-packet ( -- )
    head-short head-string login-key set
    respond-login-key-packet ; FAMILY: 23 OPCODE: 7

: handle-packet ( packet -- )
    <string-reader>
    [
        parse-snac
        family get family-table hash dup [
            opcode get swap hash dup [
                    execute
		] [
                    unhandled-opcode drop
                ] if
            ] [
            	unhandled-family-opcode
            	drop
        ] if
        unscoped-stream get empty? [ incomplete-opcode ] unless
    ] with-unscoped-stream ;




! Commands
: send-im ( name message -- )
    message set
    name set
    [
        4 6 0 HEX: 7c3a0006 make-snac
        "1973973" >cstring
        1 >short
        name get length >byte
        name get %
        2 >short

        [
            5 >byte 1 >byte 3 >short 1 >byte 1 >byte 2 >byte
            HEX: 101 >short
            message get length 4 + >short
            0 >short
            HEX: ffff >short
            message get %
        ] make-packet 
        dup length >short %
        3 >short 0 >short 6 >short 0 >short
    ] send-aim ;

: query-info ( name -- )
    name set
    [
        2 HEX: 15 0 HEX: 29cb0015 make-snac
        1 >int
        name get length >byte
        name get %
    ] send-aim ;

: query-away ( name -- )
    name set
    [
        2 HEX: 15 0 HEX: 29cb0015 make-snac
        2 >int
        name get length >byte
        name get %
    ] send-aim ;

: set-away ( message -- )
    message set
    [
        2 4 0 4 make-snac
        3 >short
        client-charset length >short
        client-charset %
        4 >short
        message get length >short
        message get %
    ] send-aim ;

: return-from-away ( -- )
    [
        2 4 0 4 make-snac
        4 >short
        0 >short
    ] send-aim ;

: set-info ( message -- )
    message set
    ! [ 2 9 0 HEX: 63e40000 ] send-aim
    [
        2 4 0 4 make-snac
        1 >short
        client-charset length >short
        client-charset %
        2 >short
        message get length >short
        message get %
    ] send-aim ;

: buddy-list-edit-start
    [ HEX: 13 HEX: 11 0 HEX: 11 ] send-aim ;

: buddy-list-edit-stop
    [ HEX: 13 HEX: 12 0 HEX: 12 ] send-aim ;
    

! add, delete groups, move buddies from group to group
! parse buddy list

: add-buddy ( name group -- )
    name set
    buddy-list-edit-start
    [
        HEX: 13 8 0 HEX: 57e60008
        name get length >short
        name get %
        ! BUDDY GROUP ID HEX: 1a4c
        ! BUDDY ID HEX: 1812
        0 >short
        0 >short
    ] send-aim
    buddy-list-edit-stop ;

! : modify-buddy
    ! [
        ! HEX: 13 9 0 HEX: 56ef0009
        ! group length
        ! group name
    ! ] send-aim ;

: delete-buddy ( name group -- )
    name set
    buddy-list-edit-start
    [
        HEX: 13 HEX: a 0 HEX: 60c0000a
        name get length >short
        name get %
        ! BUDDY GROUP ID HEX: 1a4c
        ! BUDDY ID HEX: 1812
        0 >short
        0 >short
    ] send-aim
    ! modify-buddy
    buddy-list-edit-stop ;




! Login
: send-first-login ( -- )
    [ 1 >int ] send-aim ;

: send-first-request-auth ( -- )
    stage-num [ 1 + ] change
    [
        HEX: 17 HEX: 6 0 0 make-snac
        1 >short
        username get length >short
        username get %
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
        auth-code get %
    ] send-aim ;

: send-second-bunch ( -- )
    stage-num [ 1 + ] change
    ! Generic, Capabilities
    [
        1 HEX: 17 0 HEX: 17 make-snac
        [ 1 4  HEX: 13 3  2 1  3 1  4 1  6 1  8 1  9 1  HEX: a 1  HEX: b 1 ]
        [ >short ] each
    ] send-aim
    ! Handle Message of the Day
    ! read-aim handle-packet

    ! Generic, Rate Info Request
    [ 1 6 0 6 make-snac ] send-aim
    ! handle rate info
    ! read-aim handle-packet ! send rate info ack

    ! BOS, Rights Query
    [ 1 8 0 8 make-snac [ 1 2 3 4 5 ] [ >short ] each ] send-aim
    ! BOS, handle rights
    ! read-aim handle-packet

    ! SSI, No List
    ! read-aim handle-packet

    ! Self Info Request
    [ 1 HEX: e 0 HEX: e make-snac ] send-aim

    ! Request Rights
    [ HEX: 13 2 0 2 make-snac ] send-aim

    ! Request List
    ! [
        ! HEX: 13 5 HEX: 7e6d 5 make-snac
        ! HEX: 41c1 >int
        ! HEX: 3670 >int
        ! HEX: bb >short
    ! ] send-aim
    [
        HEX: 13 5 HEX: 2575 5 make-snac
        HEX: 434d >short
        HEX: 4951 >short
        HEX: 0b >short
    ] send-aim

    ! Location, Request Rights
    [ 2 2 0 2 make-snac ] send-aim

    ! Buddylist Service, Rights Request
    [ 3 2 0 2 make-snac ] send-aim

    ! Messaging, Request Parameter Info
    [ 4 4 0 4 make-snac ] send-aim

    ! Privacy Management Service, Rights Query
    [ 9 2 0 2 make-snac ] send-aim

    ! [ 2 3 0 2 make-snac ] send-aim

    ! SSI, Activate
    [ HEX: 13 7 0 7 make-snac ] send-aim

    ! Set User Info.  Capabilities!
    [
        2 4 0 4 make-snac
        5 >short
        HEX: e0 >short
        capability-names hash-keys [ >longlong ] each
        6 >short 6 >short 4 >short 2 >short 2 >short
    ] send-aim

    ! Set ICBM Parameter
    [
        4 2 0 2 make-snac
        0 >int
        HEX: b >short
        HEX: 1f40 >short
        HEX: 03e7 >short
        HEX: 03e7 >short
        0 >int
    ] send-aim

    ! Client Ready
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
    read-aim handle-packet terpri handle-loop ;

: first-server
    ! first server
    1 stage-num set
    aim-login-server login-port <client> conn set

    send-first-login read-aim drop

    ! normal transmission stage
    send-first-request-auth read-aim handle-packet
    read-aim handle-packet
    read-aim drop
    conn get stream-close ;

: second-server
    1 stage-num set
    1 seq-num set
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
    initialize-aim connect-aim ;
    ! [ initialize-aim connect-aim ] with-scope ;

! my aim test account.  you can use it.
: run-test-account
    "FactorTest" "factoraim" run ;

