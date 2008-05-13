USING: accessors combinators io io.encodings.8-bit
io.files io.server io.sockets kernel math.parser
namespaces sequences ftp io.unix.launcher.parser
unicode.case ;
IN: ftp.server

SYMBOL: client

TUPLE: ftp-client-command string tokenized ;

: <ftp-client-command> ( -- obj )
    ftp-client-command new ;

: read-client-command ( -- ftp-client-command )
    <ftp-client-command> readln
    [ >>string ] [ tokenize-command >>tokenized ] bi ;

: send-response ( ftp-response -- )
    [ n>> ] [ strings>> ] bi
    2dup
    but-last-slice [
        [ number>string write "-" write ] [ ftp-send ] bi*
    ] with each
    first [ number>string write bl ] [ ftp-send ] bi* ;

: server-response ( n string -- )
    <ftp-response>
        swap add-response-line
        swap >>n
    send-response ;

: send-banner ( -- )
    220 "Welcome to " host-name append server-response ;

: send-PASS-request ( -- )
    331 "Please specify the password." server-response ;

: parse-USER ( ftp-client-command -- )
    tokenized>> second client get swap >>user drop ;

: send-login-response ( -- )
    ! client get
    230 "Login successful" server-response ;

: parse-PASS ( ftp-client-command -- )
    tokenized>> second client get swap >>password drop ;

: send-quit-response ( ftp-client-command -- )
    drop 221 "Goodbye." server-response ;

: unimplemented-command ( ftp-client-command -- )
    500 "Unimplemented command: " rot string>> append server-response ;

: handle-client-loop ( -- )
    <ftp-client-command> readln
    [ >>string ]
    [ tokenize-command >>tokenized ] bi
    dup tokenized>> first >upper {
        { "USER" [ parse-USER send-PASS-request t ] }
        { "PASS" [ parse-PASS send-login-response t ] }
        ! { "ACCT" [ ] }
        ! { "CWD" [ ] }
        ! { "CDUP" [ ] }
        ! { "SMNT" [ ] }

        ! { "REIN" [ ] }
        { "QUIT" [ send-quit-response f ] }

        ! { "PORT" [ ] }
        ! { "PASV" [ ] }
        ! { "MODE" [ ] }
        ! { "TYPE" [ ] }
        ! { "STRU" [ ] }

        ! { "ALLO" [ ] }
        ! { "REST" [ ] }
        ! { "STOR" [ ] }
        ! { "STOU" [ ] }
        ! { "RETR" [ ] }
        ! { "LIST" [ ] }
        ! { "NLST" [ ] }
        ! { "LIST" [ ] }
        ! { "APPE" [ ] }
        ! { "RNFR" [ ] }
        ! { "RNTO" [ ] }
        ! { "DELE" [ ] }
        ! { "RMD" [ ] }
        ! { "MKD" [ ] }
        ! { "PWD" [ ] }
        ! { "ABOR" [ ] }

        ! { "SYST" [ ] }
        ! { "STAT" [ ] }
        ! { "HELP" [ ] }

        ! { "SITE" [ ] }
        ! { "NOOP" [ ] }

        ! { "EPRT" [ ] }
        ! { "LPRT" [ ] }
        ! { "EPSV" [ ] }
        ! { "LPSV" [ ] }
        [ drop unimplemented-command t ]
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
