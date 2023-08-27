! Copyright (C) 2019 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators
combinators.short-circuit continuations destructors endian
io io.directories io.encodings.binary io.encodings.latin1
io.encodings.string io.encodings.utf8 io.files io.files.info
io.sockets kernel math math.parser namespaces pack prettyprint
random sequences sequences.extras splitting strings ;
IN: tftp

CONSTANT: TFTP-RRQ 1 ! Read request (RRQ)
CONSTANT: TFTP-WRQ 2 ! Write request (WRQ)
CONSTANT: TFTP-DATA 3 ! Data (DATA)
CONSTANT: TFTP-ACK 4 ! Acknowledgment (ACK)
CONSTANT: TFTP-ERROR 5 ! Error (ERROR)

GENERIC: get-tftp-host ( server -- host )
M: string get-tftp-host resolve-host random host>> 69 <inet4> ;
M: integer get-tftp-host "127.0.0.1" swap <inet4> ;
M: inet4 get-tftp-host ;
M: f get-tftp-host drop "127.0.0.1" 69 <inet4> ;

: tftp-get ( filename encoding server -- bytes )
    '[
        TFTP-RRQ _ _ 3array "Saa" pack-be
        _ get-tftp-host
        f 0 <inet4> <datagram> &dispose
        [ send ] keep
        dup
        '[
            _ receive
            [ 4 cut swap 2 cut nip be> TFTP-ACK swap 2array "SS" pack-be ] dip
            _ send
            dup length 511 >
        ] loop>array* concat
    ] with-destructors ;

: tftp-get-netascii ( filename server/port/inet4/f -- bytes )
    "netascii" swap tftp-get latin1 decode ;

: tftp-get-octet ( filename server/port/inet4/f -- bytes )
    "octet" swap tftp-get ;

SYMBOL: tftp-server
SYMBOL: tftp-client
SYMBOL: clients
SYMBOL: tftp-servers
tftp-servers [ H{ } clone ] initialize
TUPLE: read-file path encoding block ;

: send-client ( bytes -- )
    tftp-client get tftp-server get send ;

: send-error ( message -- )
    [ TFTP-ERROR 1 ] dip 3array "SSa" pack-be send-client ;

: send-file-block ( bytes block -- )
    TFTP-DATA swap 2array "SS" pack-be B{ } prepend-as
    send-client ;

: read-file-block ( path n -- bytes )
    binary swap
    '[ _ 512 * seek-absolute seek-input 512 read ] with-file-reader ;

: handle-send-file-next ( block -- )
    drop
    tftp-client get clients get ?at [
        [ [ path>> ] [ block>> ] bi read-file-block ]
        [ [ 1 + ] change-block block>> ] bi
        send-file-block
    ] [
        drop
    ] if ;

: handle-send-file ( bytes -- )
    "\0" split harvest first2 [ utf8 decode ] bi@
    over { [ file-exists? ] [ file-info directory? not ] } 1&& [
        "netascii" sequence= utf8 binary ? 0 read-file boa
        tftp-client get clients get set-at
        0 handle-send-file-next
    ] [
        2drop "File not found" send-error
    ] if ;

: read-tftp-command ( -- )
    tftp-server get receive tftp-client [
        2 cut swap be> {
            { TFTP-RRQ [ handle-send-file ] }
            { TFTP-ACK [ be> handle-send-file-next ] }
            [ number>string " unimplemented" append throw ]
        } case
    ] with-variable ;

: start-tftp-server ( directory port/f -- )
    get-tftp-host
    '[
        H{ } clone clients [
            _ <datagram> tftp-server [
                tftp-server get dup addr>> port>> tftp-servers get-global set-at
                [
                    [ read-tftp-command t ]
                    [ [ . flush ] with-global f ] recover
                ] loop
            ] with-variable
        ] with-variable
    ] with-directory ;

ERROR: tftp-server-not-running port ;
: stop-tftp-server ( port -- )
    tftp-servers get-global ?delete-at [
        dispose
    ] [
        tftp-server-not-running
    ] if ;
