! Copyright (C) 2008 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors calendar calendar.format classes combinators
combinators.short-circuit concurrency.promises continuations
destructors ftp io io.directories io.encodings
io.encodings.binary io.encodings.latin1 io.encodings.utf8
io.files io.files.info io.pathnames io.servers io.sockets
io.streams.string io.timeouts kernel logging math math.bitwise
math.parser namespaces sequences simple-tokenizer splitting
strings threads tools.files unicode ;
IN: ftp.server

SYMBOL: server
SYMBOL: client

TUPLE: ftp-server < threaded-server { serving-directory string } ;

TUPLE: ftp-client user password extra-connection ;

TUPLE: ftp-command raw tokenized ;
: <ftp-command> ( str -- obj )
    dup \ <ftp-command> DEBUG log-message
    ftp-command new
        over >>raw
        swap tokenize >>tokenized ;

TUPLE: ftp-get path ;
C: <ftp-get> ftp-get

TUPLE: ftp-put path ;
C: <ftp-put> ftp-put

TUPLE: ftp-list ;
C: <ftp-list> ftp-list

TUPLE: ftp-disconnect ;
C: <ftp-disconnect> ftp-disconnect

: (send-response) ( n string separator -- )
    [ number>string write ] 2dip write ftp-send ;

: send-response ( ftp-response -- )
    [ n>> ] [ strings>> ] bi
    [ but-last-slice [ "-" (send-response) ] with each ]
    [ first " " (send-response) ] 2bi ;

: make-path-relative? ( path -- ? )
    {
        [ absolute-path? ]
        [ drop server get serving-directory>> ]
    } 1&& ;

: fixup-relative-path ( string -- string' )
    dup make-path-relative? [
        [ server get serving-directory>> ] dip append-relative-path
    ] when ;

: server-response ( string n -- )
    2dup number>string swap ":" glue \ server-response DEBUG log-message
    <ftp-response>
        swap >>n
        swap add-response-line
    send-response ;

: serving? ( path -- ? )
    resolve-symlinks server get serving-directory>> head? ;

: can-serve-directory? ( path -- ? )
    { [ file-exists? ] [ file-info directory? ] [ serving? ] } 1&& ;

: can-serve-file? ( path -- ? )
    {
        [ file-exists? ]
        [ file-info regular-file? ]
        [ serving? ]
    } 1&& ;

: ftp-error ( string -- ) 500 server-response ;

: ftp-unimplemented ( string -- ) 502 server-response ;

: send-banner ( -- )
    "Welcome to " host-name append 220 server-response ;

: anonymous-only ( -- )
    "This FTP server is anonymous only." 530 server-response ;

: handle-QUIT ( obj -- )
    drop "Goodbye." 221 server-response ;

: handle-USER ( ftp-command -- )
    [
        tokenized>> second client get user<<
        "Please specify the password." 331 server-response
    ] [
        2drop "bad USER" ftp-error
    ] recover ;

: handle-PASS ( ftp-command -- )
    [
        tokenized>> second client get password<<
        "Login successful" 230 server-response
    ] [
        2drop "PASS error" ftp-error
    ] recover ;

ERROR: type-error type ;

: parse-type ( string -- string' )
    >upper {
        { "IMAGE" [ "Binary" ] }
        { "I" [ "Binary" ] }
        [ type-error ]
    } case ;

: handle-TYPE ( obj -- )
    [
        tokenized>> second parse-type
        "Switching to " " mode" surround 200 server-response
    ] [
        2drop "TYPE is binary only" ftp-error
    ] recover ;

: random-local-server ( -- server )
    remote-address get class-of new binary <server> ;

: port>bytes ( port -- hi lo )
    [ -8 shift ] keep [ 8 bits ] bi@ ;

: display-directory ( -- string )
    current-directory get server get serving-directory>> swap ?head drop
    [ "/" ] when-empty ;

: handle-PWD ( obj -- )
    drop
    display-directory "\"" 1surround 257 server-response ;

: handle-SYST ( obj -- )
    drop
    "UNIX Type: L8" 215 server-response ;

: start-directory ( -- )
    "Here comes the directory listing." 150 server-response ;

: transfer-outgoing-file ( path -- )
    [ "Opening BINARY mode data connection for " ] dip
    [ file-name ] [
        file-info size>> number>string
        "(" " bytes)." surround
    ] bi " " glue append 150 server-response ;

: transfer-incoming-file ( path -- )
    "Opening BINARY mode data connection for " prepend
    150 server-response ;

: finish-file-transfer ( -- )
    "File send OK." 226 server-response ;

GENERIC: handle-passive-command ( stream obj -- )

: passive-loop ( server -- )
    [
        [
            |dispose
            30 seconds over set-timeout
            accept drop &dispose
            client get extra-connection>>
            30 seconds ?promise-timeout
            handle-passive-command
        ]
        [ client get f >>extra-connection drop ]
        [ drop ] cleanup
    ] with-destructors ;

: finish-directory ( -- )
    "Directory send OK." 226 server-response ;

M: ftp-list handle-passive-command
    drop
    start-directory [
        utf8 encode-output [
            "." directory.
        ] with-string-writer split-lines
        harvest [ ftp-send ] each
    ] with-output-stream finish-directory ;

M: ftp-get handle-passive-command
    [
        path>>
        [ transfer-outgoing-file ]
        [ binary <file-reader> swap stream-copy ] bi
        finish-file-transfer
    ] [
        3drop "File transfer failed" ftp-error
    ] recover ;

M: ftp-put handle-passive-command
    [
        path>>
        [ transfer-incoming-file ]
        [ binary <file-writer> stream-copy ] bi
        finish-file-transfer
    ] [
        3drop "File transfer failed" ftp-error
    ] recover ;

M: ftp-disconnect handle-passive-command
    drop dispose ;

: fulfill-client ( obj -- )
    client get extra-connection>> [
        fulfill
    ] [
        drop
        "Establish an active or passive connection first" ftp-error
    ] if* ;

: handle-STOR ( obj -- )
    tokenized>> second
    dup can-serve-file? [
        <ftp-put> fulfill-client
    ] [
        drop
        <ftp-disconnect> fulfill-client
    ] if ;

: handle-LIST ( obj -- )
    drop current-directory get
    can-serve-directory? [
        <ftp-list> fulfill-client
    ] [
        <ftp-disconnect> fulfill-client
    ] if ;

: not-a-plain-file ( path -- )
    ": not a plain file." append ftp-error ;

: handle-RETR ( obj -- )
    tokenized>> second
    fixup-relative-path
    dup can-serve-file? [
        <ftp-get> fulfill-client
    ] [
        not-a-plain-file
        <ftp-disconnect> fulfill-client
    ] if ;

: handle-SIZE ( obj -- )
    tokenized>> second
    dup can-serve-file? [
        file-info size>> number>string 213 server-response
    ] [
        not-a-plain-file
    ] if ;

: expect-connection ( -- port )
    <promise> client get extra-connection<<
    random-local-server
    [ [ passive-loop ] curry in-thread ]
    [ addr>> port>> ] bi ;

: handle-PASV ( obj -- )
    drop
    expect-connection port>bytes [ number>string ] bi@ "," glue
    "Entering Passive Mode (127,0,0,1," ")" surround
    221 server-response ;

: handle-EPSV ( obj -- )
    drop
    client get f >>extra-connection drop
    expect-connection number>string
    "Entering Extended Passive Mode (|||" "|)" surround
    229 server-response ;

: handle-MDTM ( obj -- )
    tokenized>> ?second [
        fixup-relative-path
        dup file-info dup directory? [
            drop not-a-plain-file
        ] [
            nip
            modified>> timestamp>mdtm
            213 server-response
        ] if
    ] [
        "" not-a-plain-file
    ] if* ;

: directory-change-success ( -- )
    "Directory successully changed." 250 server-response ;

: directory-change-failed ( -- )
    "Failed to change directory." 553 server-response ;

: handle-CWD ( obj -- )
    tokenized>> ?second [
        fixup-relative-path
        dup can-serve-directory? [
            set-current-directory
            directory-change-success
        ] [
            drop
            directory-change-failed
        ] if
    ] [
        directory-change-success
    ] if* ;

: unrecognized-command ( obj -- )
    raw>> "Unrecognized command: " prepend ftp-error ;

: client-loop-dispatch ( str/f -- ? )
    dup tokenized>> first >upper {
        { "QUIT" [ handle-QUIT f ] }
        { "USER" [ handle-USER t ] }
        { "PASS" [ handle-PASS t ] }
        { "SYST" [ handle-SYST t ] }
        { "ACCT" [ drop "ACCT unimplemented" ftp-unimplemented t ] }
        { "PWD" [ handle-PWD t ] }
        { "TYPE" [ handle-TYPE t ] }
        { "CWD" [ handle-CWD t ] }
        { "PASV" [ handle-PASV t ] }
        { "EPSV" [ handle-EPSV t ] }
        { "LIST" [ handle-LIST t ] }
        { "STOR" [ handle-STOR t ] }
        { "RETR" [ handle-RETR t ] }
        { "SIZE" [ handle-SIZE t ] }
        { "MDTM" [ handle-MDTM t ] }
        [ drop unrecognized-command t ]
    } case ;

: read-command ( -- ftp-command/f )
    readln [ f ] [ <ftp-command> ] if-empty ;

: handle-client-loop ( -- )
    read-command [
        client-loop-dispatch
        [ handle-client-loop ] when
    ] when* ;

: serve-directory ( server -- )
    serving-directory>> [
        send-banner
        handle-client-loop
    ] with-directory ;

M: ftp-server handle-client*
    [
        "New client" \ handle-client* DEBUG log-message
        ftp-client new client set
        [ server set ] [ serve-directory ] bi
    ] with-destructors ;

: <ftp-server> ( directory port -- server )
    latin1 ftp-server new-threaded-server
        swap >>insecure
        swap resolve-symlinks >>serving-directory
        "ftp.server" >>name
        5 minutes >>timeout ;

: ftpd ( directory port -- server )
    <ftp-server> start-server ;

! sudo tcpdump -i en1 -A -s 10000  tcp port 21
! [2010-09-04T22:07:58-05:00] DEBUG server-response: 500:Unrecognized command: EPRT |2|0:0:0:0:0:0:0:1|59359|
