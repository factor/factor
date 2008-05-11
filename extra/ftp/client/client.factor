! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators continuations io io.encodings.binary
io.encodings.ascii io.files io.sockets kernel math
math.parser sequences splitting namespaces ;
IN: ftp.client

TUPLE: ftp-client host port stream user password ;
TUPLE: ftp-response n strings ;

: <ftp-response> ( -- ftp-response )
    ftp-response new
        V{ } clone >>strings ;

: <ftp-client> ( host -- ftp-client )
    ftp-client new
        swap >>host
        21 >>port
        "anonymous" >>user
        "lol@test.com" >>password ;

: read-epsv ( stream -- port )
    dup stream-readln dup print
    "|" split 2 tail* first string>number ;

: read-until-command ( stream ftp-response -- n )
    over stream-readln
    " " split1 drop string>number dup number? [
        nip
    ] [
        drop read-until-command
    ] if ;

: ftp-read ( ftp-client -- ftp-response )
    stream>> <ftp-response> [ read-until-command ] keep
    dup strings>> peek " " split1 ;

: ftp-send ( str ftp-client -- )
    stream>>
    [ stream-write ]
    [ "\r\n" swap stream-write ]
    [ stream-flush ] tri ;

: ftp-command ( ftp-client string -- n )
    swap
    [ ftp-send ] [ ftp-read ] bi ;

: ftp-user ( ftp-client -- n ) dup user>> "USER " prepend ftp-command ;
: ftp-password ( ftp-client -- n ) dup password>> "PASS " prepend ftp-command ;
: ftp-set-binary ( ftp-client -- n ) "TYPE I" ftp-command ;
: ftp-set-ascii ( ftp-client -- n ) "TYPE A" ftp-command ;
: ftp-system ( ftp-client -- n ) "SYST" ftp-command ;
: ftp-features ( ftp-client -- n ) "FEAT" ftp-command ;
: ftp-pwd ( ftp-client -- n ) "PWD" ftp-command ;
: ftp-list ( ftp-client -- n ) "LIST" ftp-command ;
: ftp-quit ( ftp-client -- n ) "QUIT" ftp-command ;
: ftp-epsv ( ftp-client -- n str ) "EPSV" ftp-command ;
: ftp-cwd ( ftp-client directory -- n ) "CWD " prepend ftp-command ;
: ftp-retr ( ftp-client filename -- n ) "RETR " prepend ftp-command ;

M: ftp-client dispose ( ftp-client -- )
    [ "QUIT" ftp-command ] [ stream>> dispose ] bi ;

ERROR: ftp-error got expected ;
: ftp-assert ( m n -- )
    2dup = [ 2drop ] [ ftp-error ] if ;

: ftp-connect ( ftp-client -- stream )
    dup
    [ host>> ] [ port>> ] bi <inet> ascii <client>
    >>stream drop ;

: ftp-login ( ftp-client -- )
    {
        [ ftp-connect ]
        [ ftp-read 220 ftp-assert ]
        [ ftp-user 331 ftp-assert ]
        [ ftp-password 230 ftp-assert ]
        [ ftp-set-binary 200 ftp-assert ]
    } cleave ;

: list ( stream -- )
    dup ftp-epsv
    dup read-epsv
    ! host get swap <inet> binary <client>
    over ftp-list
    over read-until-command drop
    contents write
    read-until-command drop ;

: ftp-get ( ftp-client filename -- )
    over ftp-epsv 229 ftp-assert
    
    ;

! : ftp-get ( path stream -- )
    ! dup ftp-epsv
    ! dup read-epsv
    ! ! host get swap <inet> binary <client>
    ! >r [ ftp-retr ] 2keep dup read-until-command drop r>
    ! rot binary <file-writer> stream-copy
    ! read-until-command drop ;



: ftp-interact ( stream -- )
    readln over ftp-send read-until-command drop ;
