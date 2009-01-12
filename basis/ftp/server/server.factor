! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators.short-circuit accessors combinators io
io.encodings.8-bit io.encodings io.encodings.binary
io.encodings.utf8 io.files io.files.info io.directories
io.sockets kernel math.parser namespaces make sequences
ftp io.launcher.unix.parser unicode.case splitting
assocs classes io.servers.connection destructors calendar
io.timeouts io.streams.duplex threads continuations math
concurrency.promises byte-arrays io.backend tools.hexdump
io.streams.string math.bitwise tools.files io.pathnames ;
IN: ftp.server

TUPLE: ftp-client url mode state command-promise user password ;

: <ftp-client> ( url -- ftp-client )
    ftp-client new
        swap >>url ;
    
SYMBOL: client

: ftp-server-directory ( -- str )
    \ ftp-server-directory get-global "resource:temp" or
    normalize-path ;

TUPLE: ftp-command raw tokenized ;

: <ftp-command> ( -- obj )
    ftp-command new ;

TUPLE: ftp-get path ;

: <ftp-get> ( path -- obj )
    ftp-get new
        swap >>path ;

TUPLE: ftp-put path ;

: <ftp-put> ( path -- obj )
    ftp-put new
        swap >>path ;

TUPLE: ftp-list ;

C: <ftp-list> ftp-list

: read-command ( -- ftp-command )
    <ftp-command> readln
    [ >>raw ] [ tokenize-command >>tokenized ] bi ;

: (send-response) ( n string separator -- )
    [ number>string write ] 2dip write ftp-send ;

: send-response ( ftp-response -- )
    [ n>> ] [ strings>> ] bi
    [ but-last-slice [ "-" (send-response) ] with each ]
    [ first " " (send-response) ] 2bi ;

: server-response ( n string -- )
    <ftp-response>
        swap add-response-line
        swap >>n
    send-response ;

: ftp-error ( string -- )
    500 "Unrecognized command: " rot append server-response ;

: send-banner ( -- )
    220 "Welcome to " host-name append server-response ;

: anonymous-only ( -- )
    530 "This FTP server is anonymous only." server-response ;

: handle-QUIT ( obj -- )
    drop 221 "Goodbye." server-response ;

: handle-USER ( ftp-command -- )
    [
        tokenized>> second client get (>>user)
        331 "Please specify the password." server-response
    ] [
        2drop "bad USER" ftp-error
    ] recover ;

: handle-PASS ( ftp-command -- )
    [
        tokenized>> second client get (>>password)
        230 "Login successful" server-response
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
        [ 200 ] dip "Switching to " " mode" surround server-response
    ] [
        2drop "TYPE is binary only" ftp-error
    ] recover ;

: random-local-server ( -- server )
    remote-address get class new 0 >>port binary <server> ;

: port>bytes ( port -- hi lo )
    [ -8 shift ] keep [ 8 bits ] bi@ ;

: handle-PWD ( obj -- )
    drop
    257 current-directory get "\"" dup surround server-response ;

: handle-SYST ( obj -- )
    drop
    215 "UNIX Type: L8" server-response ;

: if-command-promise ( quot -- )
    [ client get command-promise>> ] dip
    [ "Establish an active or passive connection first" ftp-error ] if* ;

: handle-STOR ( obj -- )
    [
        tokenized>> second
        [ [ <ftp-put> ] dip fulfill ] if-command-promise
    ] [
        2drop
    ] recover ;

! EPRT |2|::1|62138|
! : handle-EPRT ( obj -- )
    ! tokenized>> second "|" split harvest ;

: start-directory ( -- )
    150 "Here comes the directory listing." server-response ;

: finish-directory ( -- )
    226 "Directory send OK." server-response ;

GENERIC: service-command ( stream obj -- )

M: ftp-list service-command ( stream obj -- )
    drop
    start-directory [
        utf8 encode-output
        [ current-directory get directory. ] with-string-writer string-lines
        harvest [ ftp-send ] each
    ] with-output-stream
    finish-directory ;

: transfer-outgoing-file ( path -- )
    [
        150
        "Opening BINARY mode data connection for "
    ] dip
    [
        file-name
    ] [
        file-info size>> number>string
        "(" " bytes)." surround
    ] bi " " glue append server-response ;

: transfer-incoming-file ( path -- )
    [ 150 ] dip "Opening BINARY mode data connection for " prepend
    server-response ;

: finish-file-transfer ( -- )
    226 "File send OK." server-response ;

M: ftp-get service-command ( stream obj -- )
    [
        path>>
        [ transfer-outgoing-file ]
        [ binary <file-reader> swap stream-copy ] bi
        finish-file-transfer
    ] [
        3drop "File transfer failed" ftp-error
    ] recover ;

M: ftp-put service-command ( stream obj -- )
    [
        path>>
        [ transfer-incoming-file ]
        [ binary <file-writer> stream-copy ] bi
        finish-file-transfer
    ] [
        3drop "File transfer failed" ftp-error
    ] recover ;

: passive-loop ( server -- )
    [
        [
            |dispose
            30 seconds over set-timeout
            accept drop &dispose
            client get command-promise>>
            30 seconds ?promise-timeout
            service-command
        ]
        [ client get f >>command-promise drop ]
        [ drop ] cleanup
    ] with-destructors ;

: handle-LIST ( obj -- )
    drop
    [ [ <ftp-list> ] dip fulfill ] if-command-promise ;

: handle-SIZE ( obj -- )
    [
        [ 213 ] dip
        tokenized>> second file-info size>>
        number>string server-response
    ] [
        2drop
        550 "Could not get file size" server-response
    ] recover ;

: handle-RETR ( obj -- )
    [ tokenized>> second <ftp-get> swap fulfill ]
    curry if-command-promise ;

: expect-connection ( -- port )
    random-local-server
    client get <promise> >>command-promise drop
    [ [ passive-loop ] curry in-thread ]
    [ addr>> port>> ] bi ;

: handle-PASV ( obj -- )
    drop client get passive >>mode drop
    221
    expect-connection port>bytes [ number>string ] bi@ "," glue
    "Entering Passive Mode (127,0,0,1," ")" surround
    server-response ;

: handle-EPSV ( obj -- )
    drop
    client get command-promise>> [
        "You already have a passive stream" ftp-error
    ] [
        229
        expect-connection number>string
        "Entering Extended Passive Mode (|||" "|)" surround
        server-response
    ] if ;

! LPRT 6,16,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,2,242,186
! : handle-LPRT ( obj -- ) tokenized>> "," split ;

ERROR: not-a-directory ;
ERROR: no-permissions ;

: handle-CWD ( obj -- )
    [
        tokenized>> second dup normalize-path
        dup ftp-server-directory head? [
            no-permissions
        ] unless

        file-info directory? [
            set-current-directory
            250 "Directory successully changed." server-response
        ] [
            not-a-directory
        ] if
    ] [
        2drop
        550 "Failed to change directory." server-response
    ] recover ;

: unrecognized-command ( obj -- ) raw>> ftp-error ;

: handle-client-loop ( -- )
    <ftp-command> readln
    USE: prettyprint    global [ dup . flush ] bind
    [ >>raw ]
    [ tokenize-command >>tokenized ] bi
    dup tokenized>> first >upper {
        { "USER" [ handle-USER t ] }
        { "PASS" [ handle-PASS t ] }
        { "ACCT" [ drop "ACCT unimplemented" ftp-error t ] }
        { "CWD" [ handle-CWD t ] }
        ! { "XCWD" [ ] }
        ! { "CDUP" [ ] }
        ! { "SMNT" [ ] }

        ! { "REIN" [ drop client get reset-ftp-client t ] }
        { "QUIT" [ handle-QUIT f ] }

        ! { "PORT" [  ] } ! TODO
        { "PASV" [ handle-PASV t ] }
        ! { "MODE" [ ] }
        { "TYPE" [ handle-TYPE t ] }
        ! { "STRU" [ ] }

        ! { "ALLO" [ ] }
        ! { "REST" [ ] }
        { "STOR" [ handle-STOR t ] }
        ! { "STOU" [ ] }
        { "RETR" [ handle-RETR t ] }
        { "LIST" [ handle-LIST t ] }
        { "SIZE" [ handle-SIZE t ] }
        ! { "NLST" [ ] }
        ! { "APPE" [ ] }
        ! { "RNFR" [ ] }
        ! { "RNTO" [ ] }
        ! { "DELE" [ handle-DELE t ] }
        ! { "RMD" [ handle-RMD t ] }
        ! ! { "XRMD" [ handle-XRMD t ] }
        ! { "MKD" [ handle-MKD t ] }
        { "PWD" [ handle-PWD t ] }
        ! { "ABOR" [ ] }

        { "SYST" [ handle-SYST t ] }
        ! { "STAT" [ ] }
        ! { "HELP" [ ] }

        ! { "SITE" [ ] }
        ! { "NOOP" [ ] }

        ! { "EPRT" [ handle-EPRT ] }
        ! { "LPRT" [ handle-LPRT ] }
        { "EPSV" [ handle-EPSV t ] }
        ! { "LPSV" [ drop handle-LPSV t ] }
        [ drop unrecognized-command t ]
    } case [ handle-client-loop ] when ;

TUPLE: ftp-server < threaded-server ;

M: ftp-server handle-client* ( server -- )
    drop
    [
        ftp-server-directory [
            host-name <ftp-client> client set
            send-banner handle-client-loop
        ] with-directory
    ] with-destructors ;

: <ftp-server> ( port -- server )
    ftp-server new-threaded-server
        swap >>insecure
        "ftp.server" >>name
        5 minutes >>timeout
        latin1 >>encoding ;

: ftpd ( port -- )
    <ftp-server> start-server ;

: ftpd-main ( -- ) 2100 ftpd ;

MAIN: ftpd-main

! sudo tcpdump -i en1 -A -s 10000  tcp port 21
