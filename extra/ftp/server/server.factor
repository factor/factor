! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators io io.encodings.8-bit
io.files io.server io.sockets kernel math.parser
namespaces sequences ftp io.unix.launcher.parser
unicode.case splitting assocs ;
IN: ftp.server

SYMBOL: client
SYMBOL: stream

TUPLE: ftp-command raw tokenized ;

: <ftp-command> ( -- obj )
    ftp-command new ;

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

: send-banner ( -- )
    220 "Welcome to " host-name append server-response ;

: send-PASS-request ( -- )
    331 "Please specify the password." server-response ;

: anonymous-only ( -- )
    530 "This FTP server is anonymous only." server-response ;

: parse-USER ( ftp-command -- )
    tokenized>> second client get swap >>user drop ;

: send-login-response ( -- )
    ! client get
    230 "Login successful" server-response ;

: parse-PASS ( ftp-command -- )
    tokenized>> second client get swap >>password drop ;

: send-quit-response ( ftp-command -- )
    drop 221 "Goodbye." server-response ;

: ftp-error ( string -- )
    500 "Unrecognized command: " rot append server-response ;

: send-type-error ( -- )
    "TYPE is binary only" ftp-error ;

: send-type-success ( string -- )
    200 "Switching to " rot " mode" 3append server-response ;

: parse-TYPE ( obj -- )
    tokenized>> second >upper {
        { "IMAGE" [ "Binary" send-type-success ] }
        { "I" [ "Binary" send-type-success ] }
        [ drop send-type-error ]
    } case ;

: pwd-response ( -- )
    257 current-directory get "\"" swap "\"" 3append server-response ;

! : random-local-inet ( -- spec )
    ! remote-address get class new 0 >>port ;

! : handle-LIST ( -- )
    ! random-local-inet ascii <server> ;

: handle-STOR ( obj -- )
    ;

! EPRT |2|::1|62138|
! : handle-EPRT ( obj -- )
    ! tokenized>> second "|" split harvest ;

! : handle-EPSV ( obj -- )
    ! 229 "Entering Extended Passive Mode (|||"
    ! random-local-inet ! get port number>string
    ! "|)" 3append server-response ;

! LPRT 6,16,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,2,242,186
: handle-LPRT ( obj -- )
    tokenized>> "," split ;

: start-directory ( -- )
    150 "Here comes the directory listing." server-response ;

: finish-directory ( -- )
    226 "Directory send OK." server-response ;

: send-directory-list ( stream -- )
    [ directory-list write ] with-output-stream ;

: unrecognized-command ( obj -- ) raw>> ftp-error ;

: handle-client-loop ( -- )
    <ftp-command> readln
    [ >>raw ]
    [ tokenize-command >>tokenized ] bi
    dup tokenized>> first >upper {
        { "USER" [ parse-USER send-PASS-request t ] }
        { "PASS" [ parse-PASS send-login-response t ] }
        { "ACCT" [ drop "ACCT unimplemented" ftp-error t ] }
        ! { "CWD" [ ] }
        ! { "CDUP" [ ] }
        ! { "SMNT" [ ] }

        ! { "REIN" [ drop client get reset-ftp-client t ] }
        { "QUIT" [ send-quit-response f ] }

        ! { "PORT" [ ] }
        ! { "PASV" [ ] }
        ! { "MODE" [ ] }
        { "TYPE" [ parse-TYPE t ] }
        ! { "STRU" [ ] }

        ! { "ALLO" [ ] }
        ! { "REST" [ ] }
        ! { "STOR" [ handle-STOR t ] }
        ! { "STOU" [ ] }
        ! { "RETR" [ ] }
        ! { "LIST" [ drop handle-LIST t ] }
        ! { "NLST" [ ] }
        ! { "APPE" [ ] }
        ! { "RNFR" [ ] }
        ! { "RNTO" [ ] }
        ! { "DELE" [ ] }
        ! { "RMD" [ ] }
        ! { "MKD" [ ] }
        { "PWD" [ drop pwd-response t ] }
        ! { "ABOR" [ ] }

        ! { "SYST" [ drop ] }
        ! { "STAT" [ ] }
        ! { "HELP" [ ] }

        ! { "SITE" [ ] }
        ! { "NOOP" [ ] }

        ! { "EPRT" [ handle-eprt ] }
        ! { "LPRT" [ handle-lprt ] }
        ! { "EPSV" [ drop handle-epsv t ] }
        ! { "LPSV" [ drop handle-lpsv t ] }
        [ drop unrecognized-command t ]
    } case [ handle-client-loop ] when ;

: handle-client ( -- )
    "" [
        host-name <ftp-client> client set
        send-banner handle-client-loop
    ] with-directory ;

: ftpd ( port -- )
    internet-server "ftp.server"
    latin1 [ handle-client ] with-server ;

: ftpd-main ( -- ) 2100 ftpd ;

MAIN: ftpd-main

! sudo tcpdump -i en1 -A -s 10000  tcp port 21
