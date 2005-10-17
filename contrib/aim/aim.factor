! All Talk

IN: aim-internals
USING: kernel sequences lists stdio prettyprint strings namespaces math unparser threads vectors errors parser interpreter test io crypto words hashtables inspector aim-internals generic queues ;

SYMBOL: username
SYMBOL: password
SYMBOL: conn
SYMBOL: seq-num 
SYMBOL: stage-num
SYMBOL: login-key
SYMBOL: aim-chat-ip
SYMBOL: aim-chat-port
SYMBOL: auth-code
! snac
SYMBOL: family
SYMBOL: opcode
SYMBOL: snac-flags
SYMBOL: snac-request-id

SYMBOL: name
SYMBOL: message
SYMBOL: encoding
SYMBOL: warning
SYMBOL: buddy-hash-name
SYMBOL: buddy-hash-id
SYMBOL: group-hash-name
SYMBOL: group-hash-id
SYMBOL: banned-hash-name
SYMBOL: banned-hash-id
SYMBOL: channel
SYMBOL: icbm-cookie
SYMBOL: message-type
SYMBOL: my-ip
SYMBOL: blue-ip
SYMBOL: file-transfer-cancelled
SYMBOL: direct-connect-cancelled
SYMBOL: remote-internal-ip
SYMBOL: remote-external-ip
SYMBOL: ssi-length
SYMBOL: modify-queue

TUPLE: group name id ;
TUPLE: buddy name id gid capabilities buddy-icon online ;

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
: file-transfer-url "http://dynamic.aol.com/cgi/redir?http://www.aol.com/aim/filetransfer/antivirus.html" ; inline
! : akadns-aol.com "http://www.aol.com.websys.akadns.net" ;
! 205.188.210.203
: aim-file-server-port 5190 ; inline

! Family names from ethereal
: family-names
{{
    [[ 1 "Generic" ]] [[ 2 "Location" ]] [[ 3 "Buddylist" ]]
    [[ 4 "Messaging" ]] [[ 6 "Invitation" ]] [[ 8 "Popup" ]]
    [[ 9 "BOS" ]] [[ 10 "User Lookup" ]] [[ 11 "Stats" ]]
    [[ 12 "Translate" ]] [[ 19 "SSI" ]] [[ 21 "ICQ" ]]
    [[ 34 "Unknown Family" ]] }} ;

: ch>lower ( int -- int ) dup LETTER? [ HEX: 20 + ] when ;
: ch>upper ( int -- int ) dup letter? [ HEX: 20 - ] when ;
: >lower ( seq -- seq ) [ ch>lower ] map ;
: >upper ( seq -- seq ) [ ch>upper ] map ;

: sanitize-name ( name -- name ) HEX: 20 swap remove >lower ;

: hash-swap ( hash -- hash )
    [ [ unswons cons , ] hash-each ] { } make alist>hash ;

: 2list>hash ( keys values -- hash )
    {{ }} clone -rot [ swap pick set-hash ] 2each ;

: capability-names
{{
    [[ "Unknown1" HEX: 094601054c7f11d18222444553540000 ]]
    [[ "Games" HEX: 0946134a4c7f11d18222444553540000 ]]
    [[ "Send Buddy List" HEX: 0946134b4c7f11d18222444553540000 ]]
    [[ "Chat" HEX: 748f2420628711d18222444553540000 ]]
    [[ "AIM/ICQ Interoperability" HEX: 0946134d4c7f11d18222444553540000 ]]
    [[ "Voice Chat" HEX: 094613414c7f11d18222444553540000 ]]
    [[ "iChat" HEX: 094600004c7f11d18222444553540000 ]]
    [[ "Send File" HEX: 094613434c7f11d18222444553540000 ]]
    [[ "Unknown2" HEX: 094601ff4c7f11d18222444553540000 ]]
    [[ "Live Video" HEX: 094601014c7f11d18222444553540000 ]]
    [[ "Direct Instant Messaging" HEX: 094613454c7f11d18222444553540000 ]]
    [[ "Unknown3" HEX: 094601034c7f11d18222444553540000 ]]
    [[ "Buddy Icon" HEX: 094613464c7f11d18222444553540000 ]]
    [[ "Add-Ins" HEX: 094613474c7f11d18222444553540000 ]]
}} ;


: capability-values
    capability-names hash-swap ;

: capability-abbrevs
{{
    [[ CHAR: A "Voice" ]]
    [[ CHAR: C "Send File" ]]
    [[ CHAR: E "AIM Direct IM" ]]
    [[ CHAR: F "Buddy Icon" ]]
    [[ CHAR: G "Add-Ins" ]]
    [[ CHAR: H "Get File" ]]
    [[ CHAR: K "Send Buddy List" ]]
}} ;

! AIM errors
: aim-errors
{{
    [[ 1 "Invalid SNAC header." ]]
    [[ 2 "Server rate limit exceeded." ]]
    [[ 3 "Client rate limit exceeded." ]]
    [[ 4 "Recipient is not logged in." ]]
    [[ 5 "Requested service unavailable." ]]
    [[ 6 "Requested service not defined." ]]
    [[ 7 "You sent obsolete SNAC." ]]
    [[ 8 "Not supported by server." ]]
    [[ 9 "Not supported by client." ]]
    [[ 10 "Refused by client." ]]
    [[ 11 "Reply too big." ]]
    [[ 12 "Responses lost." ]]
    [[ 13 "Request denied." ]]
    [[ 14 "Incorrect SNAC format." ]]
    [[ 15 "Insufficient rights." ]]
    [[ 16 "In local permit/deny. (recipient blocked)" ]]
    [[ 17 "Sender too evil." ]]
    [[ 18 "Receiver too evil." ]]
    [[ 19 "User temporarily unavailable." ]]
    [[ 20 "No match." ]]
    [[ 22 "List overflow." ]]
    [[ 23 "Request ambiguous." ]]
    [[ 24 "Server queue full." ]]
    [[ 25 "Not while on AOL." ]]
}} ;


: initialize-aim ( username password -- )
    password set username set
    {{ }} clone buddy-hash-name set
    {{ }} clone buddy-hash-id set
    {{ }} clone group-hash-name set
    {{ }} clone group-hash-id set
    {{ }} clone banned-hash-name set
    {{ }} clone banned-hash-id set
    <queue> modify-queue set
    ! 65535 random-int seq-num set
    0 seq-num set
    1 stage-num set ;

: prepend-aim-protocol ( data -- )
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
    make-packet prepend-aim-protocol (send-aim) terpri ;

: with-aim ( quot -- )
    conn get swap with-unscoped-stream ;

: read-aim ( -- bc )
    [ [
        head-byte drop
        head-byte drop
        head-short drop
        head-short head-string
    ] with-aim ] catch [ "Socket error" print throw ] when
    "Received: " write dup hexdump ;

: make-snac ( fam subtype flags req-id -- )
    4vector { (>short) (>short) (>short) (>int) } papply % ;

: parse-snac ( stream -- )
    head-short family set
    head-short opcode set
    head-short snac-flags set
    head-int snac-request-id set ;

: (unhandled-opcode) ( str -- )
    ! "Family: " write family get >hex write
    ! ", opcode: " write opcode get >hex writeln
    head-contents hexdump ;

: unhandled-opcode ( -- )
    "Unhandled opcode!" writeln (unhandled-opcode) ;

: incomplete-opcode ( -- )
    "Incomplete handling: " write (unhandled-opcode) ;

: unhandled-family-opcode ( -- )
    "Unhandled family: " write family get unparse writeln
    unhandled-opcode ;

GENERIC: get-buddy
M: integer get-buddy ( bid -- <buddy> )
    buddy-hash-id get hash ;
M: object get-buddy ( name -- <buddy> )
    sanitize-name buddy-hash-name get hash ;

GENERIC: get-group
M: integer get-group ( bid -- <group> )
    group-hash-id get hash ;
M: object get-group ( name -- <group> )
    sanitize-name group-hash-name get hash ;

GENERIC: get-banned
M: integer get-banned ( bid -- <buddy> )
    banned-hash-id get hash ;
M: object get-banned ( name -- <buddy> )
    sanitize-name banned-hash-name get hash ;

: buddy-name? ( name -- bool )
    get-buddy >boolean ;

: group-name? ( name -- bool )
    get-group >boolean ;

: banned-name? ( name -- bool )
    get-banned >boolean ;

: random-buddy-id ( -- id )
    HEX: fff0 random-int 1+ dup get-buddy [ drop random-buddy-id ] when ;

: random-group-id ( -- id )
    HEX: fff0 random-int 1+ dup get-group [ drop random-group-id ] when ;


! Events
: buddy-signon ( name -- )
    get-buddy dup [ t swap set-buddy-online ] [ drop "Can't find buddy in buddylist: " write name get writeln ] if ;

: buddy-signoff ( name -- )
    get-buddy dup [ f swap set-buddy-online ] [ drop "Can't find buddy in buddylist: " write name get writeln ] if ;

: print-buddylist
    ! group-list get [ [ buddy-name , ] each ] { } make
    ! [ buddylist get hash-keys string-sort [ , ] each ] { } make [ drop ] simple-outliner ;
    ;

: family-table ( -- hash )
    {{ }} ;

: FAMILY: ( -- fam# )
    scan hex> swons dup car family-table hash dup [
        drop
    ] [
        drop {{ }} clone over car family-table set-hash
    ] if ; parsing

: OPCODE: ( fam# -- )
    car family-table hash word scan hex> rot set-hash f ; parsing


! Generic, Capabilities
: send-generic-capabilities
    [
        1 HEX: 17 0 HEX: 17 make-snac
        [ 1 4  HEX: 13 3  2 1  3 1  4 1  6 1  8 1  9 1  HEX: a 1  HEX: b 1 ]
        [ >short ] each
    ] send-aim ;

: (handle-supported-families)
	unscoped-stream get empty? [
		head-short family-names hash .
		(handle-supported-families)
	] unless ;

: handle-supported-families
	"Families: " print
	(handle-supported-families) 
    send-generic-capabilities
    ; FAMILY: 1 OPCODE: 3

: send-requests ( -- )
    ! Self Info Request
    [ 1 HEX: e 0 HEX: e make-snac ] send-aim

    ! Request Rights
    [ HEX: 13 2 0 2 make-snac ] send-aim

    ! Request List
    [ HEX: 13 4 0 HEX: 3efb0004 make-snac ] send-aim

    ! Location, Request Rights
    [ 2 2 0 2 make-snac ] send-aim

    ! Buddylist Service, Rights Request
    [ 3 2 0 2 make-snac ] send-aim

    ! Messaging, Request Parameter Info
    [ 4 4 0 4 make-snac ] send-aim

    ! Privacy Management Service, Rights Query
    [ 9 2 0 2 make-snac ] send-aim ;

: handle-1-7
    [
        1 8 0 8 make-snac
        head-short dup [ 
            ! "Rate Classes: " write
            head-short >short ! rate class id
            head-int drop ! window size
            head-int drop ! clear level
            head-int drop ! alert level
            head-int drop ! limit level
            head-int drop ! disconnect level
            head-int drop ! current level
            head-int drop ! max level
            head-int drop ! last time
            head-byte drop ! current state
        ] repeat
        [ 
            head-short drop ( rate class id again )
            ! Pairs
            head-short [ head-int drop ] repeat
        ] repeat
    ] send-aim ( BOS, Rights Query )
    send-requests ; FAMILY: 1 OPCODE: 7

: handle-capabilities
    unscoped-stream get empty? [
        head-u128 capability-values hash dup [ "Unknown Capability" nip ] unless
        writeln handle-capabilities
    ] unless ;

: (handle-online-info)
    unscoped-stream get empty? [
        head-byte head-string name set
        head-short drop
        head-short
        [
            head-short
            head-short head-string <string-reader> [
                {
                    { [ dup 1 = ] [ drop head-short "Class: " write unparse writeln ] }
                    { [ dup 3 = ] [ drop head-int "Time went online: " write unparse writeln ] }
                    { [ dup 4 = ] [ drop head-short "Unknown4: " write unparse writeln ] }
                    { [ dup 5 = ] [ drop head-int "Time registered: " write unparse writeln ] }
                    { [ dup 10 = ] [ drop head-int int>ip "IP: " write writeln ] }
                    { [ dup 13 = ] [ drop handle-capabilities ] }
                    { [ dup 15 = ] [ drop head-int "Idle: " write unparse writeln ] }
                    { [ dup 20 = ] [ drop head-byte "Unknown20: " write unparse writeln ] }
                    ! { [ dup 29 = ] [ drop ] }
                    { [ dup 30 = ] [ drop head-int "Unknown30: " write unparse writeln ] }
                    { [ dup 34 = ] [ drop head-short "Unknown32: " write unparse writeln ] }
                    { [ t ] [ "  Unhandled tlv 1h-fh: " write unparse writeln head-contents hexdump ] }
            } cond
            ] with-unscoped-stream
        ] repeat (handle-online-info)
    ] unless ;

: handle-online-info
    snac-flags get 32768 = [
        head-short drop
        head-short drop
        head-short drop
        head-short drop
    ] when
    (handle-online-info)
    ; FAMILY: 1 OPCODE: f

! message of the day
: handle-1-13
    7 [ head-short drop ] repeat
    ! Generic, Rate Info Request
    [ 1 6 0 6 make-snac ] send-aim ; FAMILY: 1 OPCODE: 13

! capabilities ack
: handle-1-18
    "Unhandled ack: " write head-contents writeln
	; FAMILY: 1 OPCODE: 18

: handle-1-21
    ! AIM Email
    ! [ 1 4 HEX: 02cc 4 make-snac HEX: 18 >short ] send-aim

    ! AIM Location
    ! [ 2 HEX: b HEX: 446d HEX: b make-snac username get length >byte username get % ] send-aim

    ! head-short
    ! [
        ! head-short
        ! head-short head-string <string-reader> [
            ! {
                ! ! { [ ] [ ] }
                ! { [ t ] [ "  Unhandled tlv 1h-21h: " write unparse writeln head-contents hexdump ] }
            ! } cond
        ! ] with-unscoped-stream
    ! ] repeat
    ; FAMILY: 1 OPCODE: 21


: handle-2-1
    head-short aim-errors hash "Error: " write writeln
	; FAMILY: 2 OPCODE: 1


! : handle-2-3
	! ; FAMILY: 2 OPCODE: 3

! : handle-away-message
    ! head-byte head-string name set
    ! name get write "'s away message: " write
    ! ; FAMILY: 2 OPCODE: 6

! : handle-3-3
	! ; FAMILY: 3 OPCODE: 3


: handle-29
    unscoped-stream get empty? [
        "(29)" print
        head-short drop
        head-byte drop
        head-byte head-string drop
        handle-29
    ] unless ;

: handle-abbrev-capabilities
    unscoped-stream get empty? [
        head-short .h
        handle-abbrev-capabilities
    ] unless ;

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
                { [ dup 13 = ] [ drop "Capabilities3:" print handle-capabilities  ] }
                { [ dup 14 = ] [ drop "Capabilities4:" print handle-capabilities  ] }
                { [ dup 15 = ] [ drop name get write " has been online for " write head-int unparse write " seconds." writeln ] }
                { [ dup 25 = ] [ drop "Abbreviated capabilities: " write handle-abbrev-capabilities ] }
                { [ dup 27 = ] [ drop "(27): " write 4 [ head-int unparse write " " write ] repeat terpri ] }
                { [ dup 29 = ] [ drop handle-29 ] }
                { [ t ] [ "  Unhandled tlv 3h-bh: " write unparse writeln head-contents hexdump ] }
            } cond
        ] with-unscoped-stream
    ] repeat ; FAMILY: 3 OPCODE: b

! : handle-4-5
	! ; FAMILY: 4 OPCODE: 5

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
                { [ t ] [ "Unhandled tlv 3h-ch: " write unparse writeln head-contents hexdump ] }
            } cond
        ] with-unscoped-stream
    ] repeat ; FAMILY: 3 OPCODE: c

: parse-family-4h-header
    head-short drop
    head-short drop
    head-short drop
    head-short drop
    8 head-string drop
    head-short channel set ;
    
: parse-message-text ( -- str )
    head-short drop head-short drop head-contents ;

: parse-message-tlv2
    unscoped-stream get empty? [
        head-byte
        head-byte drop ! fragVer
        head-short head-string <string-reader>
        [ 
            {
                { [ dup 1 = ] [ drop parse-message-text message set ] }
                { [ dup 5 = ] [ drop ] }
                { [ t ] [ "Unknown frag: " write unparse writeln unscoped-stream get contents hexdump ] }
            } cond
        ] with-unscoped-stream
        parse-message-tlv2
    ] unless ;

: handle-file-transfer-start-tlvs
    unscoped-stream get empty? [
        head-short
        head-short head-string <string-reader> [
            file-transfer-cancelled off
            dup unparse write ": " write
            {
                { [ dup 2 = ] [ drop head-int int>ip dup my-ip set "my ip: " write write ] }
                { [ dup 3 = ] [ drop head-int int>ip dup blue-ip set "blue.aol ip: " write write  ] }
                { [ dup 4 = ] [ drop head-int unparse write ] }
                { [ dup 5 = ] [ drop head-short unparse write ] }
                { [ dup 10 = ] [ drop head-short unparse write ] }
                { [ dup 11 = ] [ drop head-short unparse . "Transfer canclled" print file-transfer-cancelled on ] }
                { [ dup 12 = ] [ drop head-contents message set "Message: " write message get writeln ] }
                { [ dup 13 = ] [ drop head-contents encoding set ] }
                { [ dup 14 = ] [ drop head-short unparse write ] }
                { [ dup 15 = ] [ drop ( do nothing ) ] }
                { [ dup 22 = ] [ drop head-int unparse write ] }
                { [ dup 23 = ] [ drop head-short unparse write ] }
                { [ dup 10001 = ] [ drop head-contents write ] }
                { [ dup 10002 = ] [ drop head-contents write ] }
                { [ t ] [ "Unhandled file transfer tlv: " write unparse writeln head-contents hexdump ] }
            } cond terpri
        ] with-unscoped-stream
        handle-file-transfer-start-tlvs
    ] unless ;

: send-file-transfer-start
    "STARTING FILE TRANSFER" print
    [
        4 6 0 HEX: 778f0006 make-snac
        icbm-cookie get >longlong
        2 >short
        name get length >byte
        name get %
        5 >short
        56 >short
        0 >short
        icbm-cookie get >longlong
        "Send File" capability-names hash >u128
        10 >short 2 >short 2 >short
        2 >short 4 >short 0 >int
        22 >short 4 >short HEX: ffffffff >int ! gateway?
        3 >short 4 >short 0 >int
    ] send-aim ;

: handle-chat-start-tlvs
    unscoped-stream get empty? [
        head-short
        head-short head-string <string-reader> [
            dup unparse write ": " write
            {
                { [ dup 10 = ] [ drop head-short unparse write ] }
                { [ dup 12 = ] [ drop head-contents message set ] }
                { [ dup 13 = ] [ drop head-contents encoding set ] }
                { [ dup 14 = ] [ drop head-byte unparse write ] }
                { [ dup 15 = ] [ drop ( do nothing ) ] }
                { [ dup 10001 = ] [ drop head-contents hexdump ] }
                { [ t ] [ "Unhandled chat transfer tlv: " write unparse writeln head-contents hexdump ] }
            } cond terpri
        ] with-unscoped-stream
        handle-chat-start-tlvs
    ] unless ;

: handle-direct-start-tlvs
    unscoped-stream get empty? [
        head-short
        head-short head-string <string-reader> [
            dup unparse write ": " write
            {
                { [ dup 2 = ] [ drop head-int int>ip dup remote-internal-ip set "remote internal ip: " write write ] }
                { [ dup 3 = ] [ drop head-int int>ip dup remote-external-ip set "remote external? ip: " write write ] }
                { [ dup 4 = ] [ drop head-int int>ip dup my-ip set "my? ip: " write write ] }
                { [ dup 5 = ] [ drop head-short unparse "port?" write write ] }
                { [ dup 10 = ] [ drop head-short unparse write ] }
                { [ dup 11 = ] [ drop head-short unparse write direct-connect-cancelled set ] }
                { [ dup 15 = ] [ drop ( do nothing ) ] }
                { [ dup 22 = ] [ drop head-int unparse write ] }
                { [ dup 23 = ] [ drop head-short unparse "port?" write write ] }
                { [ t ] [ "Unhandled direct transfer tlv: " write unparse writeln head-contents hexdump ] }
            } cond terpri
        ] with-unscoped-stream
        handle-direct-start-tlvs
    ] unless ;

: send-direct-connect-start
    ;

: send-auth-file-transfer
    [
        0 >short
        1 >short
        "Send File" capability-names hash >u128
        0 >short
    ] send-aim ;

: connect-aim-file-transfer-server
    "205.188.210.203" aim-file-server-port <client> ;
    

: handle-file-transfer-start
    head-short message-type set
    head-longlong icbm-cookie set
    head-u128 capability-values hash 
    {
        { [ dup "Send File" = ]
            [ . handle-file-transfer-start-tlvs 
                file-transfer-cancelled get [ send-file-transfer-start ] unless
            ] }
        { [ dup "Chat" = ] [ . handle-chat-start-tlvs 
            "Chat join message: " write message get writeln ] }
        { [ dup "AIM Direct IM" = ] [ . handle-direct-start-tlvs
                direct-connect-cancelled get [ send-direct-connect-start ] unless
            ] }
        { [ t ] [ "Unsupported capability in channel 2: " write writeln head-contents hexdump ] }
    } cond ;

: parse-message-chunks
    unscoped-stream get empty? [
        head-short
        head-short head-string <string-reader> [
            {
                { [ dup 2 = ] [ drop parse-message-tlv2 ] }
                { [ dup 5 = ] [ drop handle-file-transfer-start ] }
                { [ dup 11 = ] [ drop ] }
                ! { [ dup 13 = ] [ drop ] }
                { [ t ] [ "Unhandled chunk: " write unparse writeln head-contents hexdump ] }
            } cond
        ] with-unscoped-stream
        parse-message-chunks
    ] unless ;

: parse-message-tlv ( n -- )
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
                { [ t ] [ "Unknown tlv: " write unparse writeln head-contents hexdump ] }
            } cond
        ] with-unscoped-stream
    ] repeat ;

: handle-incoming-message ( -- )
    parse-family-4h-header
    head-byte head-string name set
    head-short warning set
    head-short parse-message-tlv
    parse-message-chunks

    channel get 1 = [
        "Incoming msg from " write name get write ": " write
        "Warning: " write warning get 10 /f unparse write "%" writeln
        "Message: " write message get writeln
    ] when ; FAMILY: 4 OPCODE: 7

! : handle-4-12
	! head-short 2 / [ head-short drop ] repeat
	! head-cstring drop
	! head-short drop
	! head-byte head-string
	! ; FAMILY: 4 OPCODE: 12

: handle-typing-message ( -- )
    parse-family-4h-header
    head-byte head-string write
    head-short
    {
        { [ dup 0 = ] [ drop " has an empty textbox." writeln ] }
        { [ dup 1 = ] [ drop " has entered text." writeln ] }
        { [ dup 2 = ] [ drop " is typing..." writeln ] }
        { [ t ] [ " does 4h.14h unknown: " write unparse writeln ] }
    } cond ; FAMILY: 4 OPCODE: 14

! : handle-9-3
	! ; FAMILY: 9 OPCODE: 3

: handle-b-2
    head-short "Send status report every: " write unparse write " hours" writeln
    head-short "Unknown: " write unparse writeln
    ; FAMILY: b OPCODE: 2

! : handle-19-3
    ! ; FAMILY: 13 OPCODE: 3

SYMBOL: gid ! group id
SYMBOL: bid ! buddy id
SYMBOL: type
: handle-19-6
    head-byte drop ! ssi version, probably 0
    head-short [ 
        head-short head-string name set   name get .
        head-short gid set    gid get .
        head-short bid set    bid get .
        head-short type set      type get .  ! type 0 is a buddy, 1 is a group
        "TLV CHAIN DATA: " print
        head-short head-string hexdump   ! short short data

        type get
        {
            { [ dup 0 = ] [ drop name get bid get gid get { } clone f f <buddy> 
            dup name get sanitize-name buddy-hash-name get set-hash bid get buddy-hash-id get set-hash ] }
            { [ dup 1 = ] [ drop name get dup length 0 = [ drop ] [ gid get <group> 
            dup name get sanitize-name group-hash-name get set-hash gid get group-hash-id get set-hash ] if ] }
            { [ dup 3 = ] [ drop name get bid get gid get { } clone f f <buddy>
            dup name get sanitize-name banned-hash-name get set-hash bid get banned-hash-id get set-hash ] }
            { [ t ] [ drop "Unknown 19-6 type" print ] }
        } cond
    ] repeat
    head-short drop ! unknown or timestamp
    head-short drop ! unknown or timestamp

    snac-flags get 0 = [
        ! SSI, Activate
        [ HEX: 13 7 0 7 make-snac ] send-aim
        ! Set User Info.  Capabilities!
        ! if you send this packet correctly you get capabilities
        ! and others' capabilities turn into letters instead of u128s
        [
            2 4 0 4 make-snac
            5 >short
            capability-values hash-keys length 16 * >short ! size
            capability-values hash-keys [ >u128 ] each
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
        ] send-aim
        
        ! Process
    ] when ; FAMILY: 13 OPCODE: 6


: parse-server ( ip:port -- )
    ":" split [ first ] keep second string>number aim-chat-port set aim-chat-ip set ;

: process-login-chunks ( stream -- )
    unscoped-stream get empty?  [
        head-short
        head-short
        swap
        {
            { [ dup 5 = ] [ drop head-string parse-server ] }
            { [ dup 6 = ] [ drop head-string auth-code set ] }
            { [ t ] [ drop head-string drop ] }
        } cond
        process-login-chunks
    ] unless ;

: handle-login-packet ( -- )
    process-login-chunks ; FAMILY: 17 OPCODE: 3

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
    respond-login-key-packet ; FAMILY: 17 OPCODE: 7

: handle-packet ( packet -- )
    <string-reader>
    [
        parse-snac
        "Family: " write family get >hex write
        ", Opcode: " write opcode get >hex writeln
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

! Login
: send-first-login ( -- )
    [ 1 >int ] send-aim ;

: send-first-request-auth ( -- )
    2 stage-num set
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

! AIM Chat Server
: send-second-login
    [
        1 >int
        6 >short
        auth-code get length >short
        auth-code get %
    ] send-aim ;

: first-server
    ! first server
    1 stage-num set
    aim-login-server login-port <client> conn set

    send-first-login read-aim drop

    ! normal transmission stage
    send-first-request-auth read-aim handle-packet
    read-aim handle-packet
    read-aim drop  ! handle-packet
    conn get stream-close ;

: second-server
    aim-chat-ip get aim-chat-port get <client> conn set
    1 stage-num set
    65535 random-int seq-num set
    send-second-login read-aim drop
    2 stage-num set ;

: handle-loop ( -- )
    read-aim handle-packet terpri handle-loop ;

: connect-aim ( -- )
    first-server
    aim-chat-ip get 
    [ "No aim server received (too many logins, try again later)" throw ] unless
    second-server [ handle-loop ] in-thread ;

IN: aim

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

: buddylist-edit-start
    [ HEX: 13 HEX: 11 0 HEX: 11 make-snac ] send-aim ;

: buddylist-edit-stop
    [ HEX: 13 HEX: 12 0 HEX: 12 make-snac ] send-aim ;
    

! add, delete groups, move buddies from group to group
! parse buddy list

: add-group ( name -- )
    dup name set modify-queue get enque
    buddylist-edit-start
    [
        HEX: 13 8 0 HEX: 4fb20008 make-snac
        name get length >short
        name get %
        random-group-id >short
        0 >short ! buddy id
        1 >short ! buddy type
        0 >short ! tlv len
    ] send-aim ;

: delete-group ( name -- )
    dup name set modify-queue get enque
    buddylist-edit-start
    [
        HEX: 13 HEX: a 0 HEX: 5086000a make-snac
        name get length >short
        name get %
        name get get-group group-id >short
        0 >short
        1 >short
        0 >short
    ] send-aim ;

! TODO: make sure buddy doesnt already exist, makd sure group exists
: add-buddy ( name group -- )
    group set 
    dup name set modify-queue get enque
    buddylist-edit-start
    [
        HEX: 13 9 0 HEX: 72470009 make-snac
        0 >short
        0 >short
        0 >short
        1 >short
        6 >short
        HEX: c8 >short
        2 >short
        HEX: 6dc5 >short
    ] send-aim

    [
        HEX: 13 8 0 HEX: 5b2f0008 make-snac
        name get length >short
        name get %
        group get get-group group-id >short
        random-buddy-id >short
        0 >short ! buddy type
        0 >short ! tlv len
    ] send-aim ;

: delete-buddy ( name -- )
    dup name set modify-queue get enque
    buddylist-edit-start
    [
        HEX: 13 HEX: a 0 HEX: 5086000a make-snac
        name get length >short
        name get %
        name get get-buddy dup buddy-gid >short
        buddy-id >short
        0 >short
        0 >short
    ] send-aim ;

: modify-buddylist ( name -- )
    ! dup buddy-name? [ dup name set dup buddy-id bid set buddy-gid gid set ] when
    ! dup group-name? [ dup name set dup group-id gid set 0 bid set ] when
    ! dup banned-name? [ dup name set dup buddy-id bid set buddy-gid gid set ] when
    ! [
        ! HEX: 13 9 0 HEX: 6e190009 make-snac
        ! name get dup length >short %
        ! gid get >short
        ! 0 >short
        ! 1 >short  ! group type = 1
   
        ! "members of this group" tlv
        ! 8 >short
        ! HEX: c8 >short
        ! 4 >short
        ! HEX: 4e833ea8 >int
    ! ] send-aim ;
    drop ;

IN: aim-internals
: buddylist-error
    ; FAMILY: 13 OPCODE: b

: buddylist-ack
    ! modify-queue get deque modify-buddylist
    buddylist-edit-stop ; FAMILY: 13 OPCODE: d

IN: aim

: run ( username password -- )
    initialize-aim connect-aim ;
    ! [ initialize-aim connect-aim ] with-scope ;

! my aim test account.  you can use it.
: run-test-account
    "FactorTest" "factoraim" run ;

