! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: io.server io.sockets io strings parser byte-arrays
namespaces ui.clipboards ui.gadgets.panes ui.gadgets.scrollers
ui.gadgets.buttons ui.gadgets.tracks ui.gadgets ui.operations
ui.commands ui kernel splitting combinators continuations
sequences io.streams.duplex models ;
IN: network-clipboard

: clipboard-port 4444 ;

: get-request
    clipboard get clipboard-contents write ;

: contents ( -- str )
    [ 1024 read dup ] [ ] [ drop ] unfold concat ;

: set-request
    contents clipboard get set-clipboard-contents ;

: clipboard-server ( -- )
    clipboard-port internet-server "clip-server" [
        readln {
            { "GET" [ get-request ] }
            { "SET" [ set-request ] }
        } case
    ] with-server ;

\ clipboard-server H{
    { +nullary+ t }
    { +listener+ t }
} define-command

: <client-datagram> ( -- datagram )
    "0.0.0.0" 0 <inet4> <datagram> ;

: with-client ( addrspec quot -- )
    >r <client> r> with-stream ; inline

: send-text ( text host -- )
    clipboard-port <inet4> [ write ] with-client ;

TUPLE: host name ;

C: <host> host

M: string host-name ;

: send-clipboard ( host -- )
    host-name
    "SET\n" clipboard get clipboard-contents append swap send-text ;

[ host? ] \ send-clipboard H{ } define-operation

: ask-text ( text host -- )
    clipboard-port <inet4>
    [ write flush contents ] with-client ;

: receive-clipboard ( host -- )
    host-name
    "GET\n" swap ask-text
    clipboard get set-clipboard-contents ;

[ host? ] \ receive-clipboard H{ } define-operation

: hosts. ( seq -- )
    "Hosts:" print
    [ dup <host> write-object nl ] each ;

TUPLE: network-clipboard-tool ;

\ network-clipboard-tool "toolbar" f {
    { f clipboard-server }
} define-command-map

: <network-clipboard-tool> ( model -- gadget )
    \ network-clipboard-tool construct-empty [
        toolbar,
        [ hosts. ] <pane-control> <scroller> 1 track,
    ] { 0 1 } build-track ;

SYMBOL: network-clipboards

{ } <model> network-clipboards set-global

: set-network-clipboards ( seq -- )
    network-clipboards get set-model ;

: add-network-clipboard ( host -- )
    network-clipboards get [ swap add ] change-model ;

: network-clipboard-tool ( -- )
    [
        network-clipboards get
        <network-clipboard-tool>
        "Network clipboard" open-window
    ] with-ui ;

MAIN: network-clipboard-tool
