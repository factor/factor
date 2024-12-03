! Copyright (C) 2010 Chris Double.
! See https://factorcode.org/license.txt for BSD license.
!
! bitcoin API documentation at:
!  https://www.bitcoin.org/wiki/doku.php?id=api
!
! Donations can be sent to the following bitcoin address:
! 1HVMkUcaPhCeCK3rrBm31EY2bf5r33VHsj

USING: accessors assocs base64 byte-arrays http http.client
io.encodings.binary json kernel namespaces sequences strings
urls ;

IN: bitcoin.client

: bitcoin-server ( -- string )
    \ bitcoin-server get "localhost" or ;

: bitcoin-port ( -- n )
    \ bitcoin-port get 8332 or ;

: bitcoin-user ( -- string )
    \ bitcoin-user get "" or ;

: bitcoin-password ( -- string )
    \ bitcoin-password get ;

<PRIVATE

: bitcoin-url ( -- url )
    <url>
      "https" >>protocol
      "/" >>path
      bitcoin-server >>host
      bitcoin-port >>port ;

:: payload ( method params -- data )
    "text/plain" <post-data>
        binary >>content-encoding
        H{
            { "method" method }
            { "params" params }
        } clone >json >byte-array >>data ;

: basic-auth ( -- string )
    bitcoin-user bitcoin-password ":" glue >base64 >string
    "Basic " prepend ;

: bitcoin-request ( method params -- request )
    payload bitcoin-url <post-request>
    basic-auth "Authorization" set-header
    dup data>> data>> length "Content-Length" set-header
    http-request nip >string json> "result" of ;

PRIVATE>

:: get-addresses-by-label ( label -- seq )
    "getaddressesbylabel" { label } bitcoin-request ;

: get-balance ( -- n )
    "getbalance" { } bitcoin-request ;

: get-block-count ( -- n )
    "getblockcount" { } bitcoin-request ;

: get-block-number ( -- n )
    "getblocknumber" { } bitcoin-request ;

: get-connection-count ( -- n )
    "getconnectioncount" { } bitcoin-request ;

: get-difficulty ( -- n )
    "getdifficulty" { } bitcoin-request ;

: get-generate ( -- ? )
    "getgenerate" { } bitcoin-request ;

:: set-generate ( gen n -- )
    "setgenerate" { gen n } bitcoin-request  drop ;

: get-info ( -- result )
    "getinfo" { } bitcoin-request ;

:: get-label ( address -- label )
    "getlabel" { address } bitcoin-request ;

:: set-label ( address label -- )
    "setlabel" { address  label } bitcoin-request  drop ;

:: remove-label ( address -- )
    "setlabel" { address } bitcoin-request  drop ;

: get-new-address ( -- address )
    "getnewaddress" { } bitcoin-request ;

:: get-new-labelled-address ( label -- address )
    "getnewaddress" { label } bitcoin-request ;

:: get-received-by-address ( address -- amount )
    "getreceivedbyaddress" { address } bitcoin-request ;

:: get-confirmed-received-by-address ( address minconf -- amount )
    "getreceivedbyaddress" { address minconf } bitcoin-request ;

:: get-received-by-label ( label -- amount )
    "getreceivedbylabel" { label } bitcoin-request ;

:: get-confirmed-received-by-label ( label minconf -- amount )
    "getreceivedbylabel" { label minconf } bitcoin-request ;

:: list-received-by-address ( minconf include-empty -- seq )
    "listreceivedbyaddress" { minconf include-empty } bitcoin-request ;

:: list-received-by-label ( minconf include-empty -- seq )
    "listreceivedbylabel" { minconf include-empty } bitcoin-request ;

:: send-to-address ( address amount -- ? )
    "sendtoaddress" { address amount } bitcoin-request "sent" = ;

: stop ( -- )
    "stop" { } bitcoin-request drop ;

! requires patched bitcoind
:: list-transactions ( count include-generated -- seq )
    "listtransactions" { count include-generated } bitcoin-request ;
