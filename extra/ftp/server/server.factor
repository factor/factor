! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators io io.encodings.8-bit
io.encodings io.encodings.binary io.encodings.utf8 io.files
io.server io.sockets kernel math.parser namespaces sequences
ftp io.unix.launcher.parser unicode.case splitting assocs
classes io.server destructors calendar io.timeouts
io.streams.duplex threads continuations math
concurrency.promises byte-arrays ;
IN: ftp.server

SYMBOL: client

TUPLE: ftp-command raw tokenized ;

: <ftp-command> ( -- obj )
    ftp-command new ;

TUPLE: ftp-get path ;

: <ftp-get> ( path -- obj )
    ftp-get new swap >>path ;

TUPLE: ftp-put path ;

: <ftp-put> ( path -- obj )
    ftp-put new swap >>path ;

TUPLE: ftp-list ;

C: <ftp-list> ftp-list

: read-command ( -- ftp-command )
    <ftp-command> readln
    [ >>raw ] [ tokenize-command >>tokenized ] bi ;

: (send-response) ( n string separator -- )
    rot number>string write write ftp-send ;

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
        tokenized>> second client get swap >>user drop
        331 "Please specify the password." server-response
    ] [
        2drop "bad USER" ftp-error
    ] recover ;

: handle-PASS ( ftp-command -- )
    [
        tokenized>> second client get swap >>password drop
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
        200 "Switching to " rot " mode" 3append server-response
    ] [
        2drop "TYPE is binary only" ftp-error
    ] recover ;

: random-local-server ( -- server )
    remote-address get class new 0 >>port binary <server> ;

: port>bytes ( port -- hi lo )
    [ -8 shift ] keep [ HEX: ff bitand ] bi@ ;

: handle-PWD ( obj -- )
    drop
    257 current-directory get "\"" swap "\"" 3append server-response ;

: handle-SYST ( obj -- )
    drop
    215 "UNIX Type: L8" server-response ;

: handle-STOR ( obj -- )
    [
        drop
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
    start-directory
    [
        utf8 encode-output
        directory-list [ ftp-send ] each
    ] with-output-stream
    finish-directory ;

: start-file-transfer ( path -- )
    150 "Opening BINARY mode data connection for "
    rot   
    [ file-name ] [
        " " swap  file-info file-info-size number>string
        "(" " bytes)." swapd 3append append
    ] bi 3append server-response ;
    
: finish-file-transfer ( -- )
    226 "File send OK." server-response ;

M: ftp-get service-command ( stream obj -- )
    [
        path>>
        [ start-file-transfer ]
        [ binary <file-reader> swap stream-copy ] bi
        finish-file-transfer
    ] [
        3drop "File transfer failed" ftp-error
    ] recover ;

M: ftp-put service-command ( stream obj -- )
    [
        path>>
        [ start-file-transfer ]
        [ binary <file-reader> swap stream-copy ] bi
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
        [ ] cleanup
    ] with-destructors ;

: if-command-promise ( quot -- )
    >r client get command-promise>> r>
    [ "Establish an active or passive connection first" ftp-error ] if* ;

: handle-LIST ( obj -- )
    drop
    [ <ftp-list> swap fulfill ] if-command-promise ;

: handle-SIZE ( obj -- )
    [
        tokenized>> second file-info size>>
        213 swap number>string server-response
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
    expect-connection
    [
        "Entering Passive Mode (127,0,0,1," %
        port>bytes [ number>string ] bi@ "," swap 3append %
        ")" %
    ] "" make 227 swap server-response ;

: handle-EPSV ( obj -- )
    drop
    client get command-promise>> [
        "You already have a passive stream" ftp-error
    ] [
        229 "Entering Extended Passive Mode (|||"
        expect-connection number>string
        "|)" 3append server-response
    ] if ;

! LPRT 6,16,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,2,242,186
! : handle-LPRT ( obj -- ) tokenized>> "," split ;

ERROR: not-a-directory ;

: handle-CWD ( obj -- )
    [
        tokenized>> second dup directory? [
            set-current-directory
            250 "Directory successully changed." server-response
        ] [
            not-a-directory throw
        ] if
    ] [
        2drop
        550 "Failed to change directory." server-response
    ] recover ;

: unrecognized-command ( obj -- ) raw>> ftp-error ;

: handle-client-loop ( -- )
    <ftp-command> readln
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

        ! { "PORT" [ ] }
        { "PASV" [ handle-PASV t ] }
        ! { "MODE" [ ] }
        { "TYPE" [ handle-TYPE t ] }
        ! { "STRU" [ ] }

        ! { "ALLO" [ ] }
        ! { "REST" [ ] }
        ! { "STOR" [ handle-STOR t ] }
        ! { "STOU" [ ] }
        { "RETR" [ handle-RETR t ] }
        { "LIST" [ handle-LIST t ] }
        { "SIZE" [ handle-SIZE t ] }
        ! { "NLST" [ ] }
        ! { "APPE" [ ] }
        ! { "RNFR" [ ] }
        ! { "RNTO" [ ] }
        ! { "DELE" [ ] }
        ! { "RMD" [ ] }
        ! { "MKD" [ ] }
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

: handle-client ( -- )
    [
        "" [
            host-name <ftp-client> client set
            send-banner handle-client-loop
        ] with-directory
    ] with-destructors ;

: ftpd ( port -- )
    internet-server "ftp.server"
    latin1 [ handle-client ] with-server ;

: ftpd-main ( -- ) 2100 ftpd ;

MAIN: ftpd-main

! sudo tcpdump -i en1 -A -s 10000  tcp port 21
