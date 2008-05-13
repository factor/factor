USING: accessors combinators io io.encodings.8-bit
io.server io.sockets kernel sequences ftp
io.unix.launcher.parser unicode.case ;
IN: ftp.server

TUPLE: ftp-server port ;

: <ftp-server> ( -- ftp-server )
    ftp-server new
        21 >>port ;

TUPLE: ftp-client-command string tokenized ;
: <ftp-client-command> ( -- obj )
    ftp-client-command new ;

: read-client-command ( -- ftp-client-command )
    <ftp-client-command> readln
    [ >>string ] [ tokenize-command >>tokenized ] bi ;

: server>client ( string -- ftp-client-command )
    ftp-send read-client-command ;

: send-banner ( -- ftp-client-command )
    "220 Welcome to " host-name append server>client ;

: handle-client-loop ( ftp-client-command -- )
    <ftp-client-command> readln
    [ >>string ] [ tokenize-command >>tokenized ] bi
    first >upper {
        ! { "USER" [ ] }
        ! { "PASS" [ ] }
        ! { "ACCT" [ ] }
        ! { "CWD" [ ] }
        ! { "CDUP" [ ] }
        ! { "SMNT" [ ] }

        ! { "REIN" [ ] }
        ! { "QUIT" [ ] }

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
    } case ;

: handle-client ( -- ftp-response )
    "" [
        send-banner handle-client-loop
    ] with-directory ;

: ftpd ( port -- )
    internet-server "ftp.server"
    latin1 [ handle-client ] with-server ;

: ftpd-main ( -- )
    2100 ftpd ;

MAIN: ftpd-main
