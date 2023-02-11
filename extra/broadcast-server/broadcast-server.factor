! Copyright (C) 2021 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs calendar combinators
continuations destructors io io.encodings.string
io.encodings.utf8 io.files.info io.sockets io.streams.string
kernel layouts make parser prettyprint prettyprint.config
sequences splitting system system-info threads ;
IN: broadcast-server

TUPLE: broadcast-server < disposable
    broadcast-inet4
    receive-inet4
    should-stop?
    received
    broadcast-socket
    receive-socket ;

: <broadcast-server> ( broadcast-ip port -- obj )
    broadcast-server new-disposable
        over f swap <inet4> >>receive-inet4
        -rot <inet4> >>broadcast-inet4
        H{ } clone >>received ; inline

M: broadcast-server dispose*
    [ receive-socket>> dispose ]
    [ broadcast-socket>> dispose ] bi ;

: broadcast-server-send ( bytes type broadcast-server -- )
    [ 2array unparse utf8 encode ] dip
    [ broadcast-inet4>> ] [ broadcast-socket>> ] bi send ;

SINGLETONS: command data ;

: send-broadcast-command ( str server -- )
    [ command ] dip broadcast-server-send ;

: send-broadcast-data ( str server -- )
    [ data ] dip broadcast-server-send ;

: run-command ( string -- out )
    [ parse-lines [ [ call( -- ) ] with-string-writer ] without-limits ]
    [ drop ] recover ;

: handle-data ( data inet4 broadcast-server -- )
    [ received>> push-at ]
    [
        [ . ] dip
        swap dup ...
        first
        unclip-last {
            { data [ 2drop ] }
            { command [ run-command swap send-broadcast-data ] }
            [ unparse "unknown command: " prepend print 2drop ]
        } case
        nl
    ] 3bi ;

: receive-loop ( broadcast-server -- )
    '[
        [
            _ dup should-stop?>> [
                dispose f
            ] [
                [
                    receive-socket>> receive
                    [ utf8 decode split-lines parse-lines ] dip
                ] keep handle-data t
            ] if
        ] loop
    ] in-thread ;

: payload ( -- byte-array )
    [
        computer-name "computer-name" ,,
        os unparse "os" ,,
        os-version "os-version" ,,
        cpu unparse "cpu" ,,
        cell-bits "cell-bits" ,,
        username "username" ,,

        build "build" ,,
        vm-git-id "git-id" ,,
        version-info "version-info" ,,
        vm-path "vm-path" ,,
        vm-path file-info size>> "vm-size" ,,
        image-path "image-path" ,,
        image-path file-info size>> "image-size" ,,

        cpus "cpus" ,,
        cpu-mhz "cpu-mhz" ,,
        physical-mem "physical-mem" ,,
        vm-path file-system-info
        [ total-space>> "disk-total-size" ,, ]
        [ free-space>> "disk-free-size" ,, ] bi
    ] { } make ;

: send-loop ( broadcast-server -- )
    '[
        [
            _ dup should-stop?>> [
                dispose f
            ] [
                payload data rot broadcast-server-send t
            ] if
            3 seconds sleep
        ] loop
    ] in-thread ;

: start-broadcast-server ( ip port -- obj )
    [
        <broadcast-server>
            dup receive-inet4>> <datagram> |dispose >>receive-socket
            dup broadcast-inet4>> <any-port-local-broadcast> |dispose >>broadcast-socket
        [ receive-loop ]
        [ send-loop ]
        [ ] tri
    ] with-destructors ;

! "192.168.88.255" 7777 start-broadcast-server
! "USE: math 2 2 + ." over send-broadcast-command

