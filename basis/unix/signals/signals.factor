! Copyright (C) 2011 Joe Groff.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs io.backend.unix kernel namespaces sequences
threads ;
IN: unix.signals

<PRIVATE

SYMBOL: signal-handlers

signal-handlers [ H{ } ] initialize

: dispatch-signal ( sig -- )
    signal-handlers get-global at [ in-thread ] each ;

PRIVATE>

: add-signal-handler ( handler: ( -- ) sig -- )
    signal-handlers get-global push-at ;

: remove-signal-handler ( handler sig -- )
    signal-handlers get-global at [ remove! drop ] [ drop ] if* ;

[ dispatch-signal ] dispatch-signal-hook set-global
