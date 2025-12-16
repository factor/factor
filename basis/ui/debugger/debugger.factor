! Copyright (C) 2006, 2011 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors continuations debugger io io.streams.string
kernel namespaces prettyprint ui ui.gadgets.worlds ;
IN: ui.debugger

: error-alert ( error -- )
    [ dup error. ] with-global
    [ "Error" ] dip [ print-error ] with-string-writer
    system-alert ;

! ( error -- )
[ error-alert ] ui-error-hook set-global

! ( error -- * )
[
    ui-running? [ dup error-alert ] [ dup print-error ] if die
] callback-error-hook set-global

M: world-error error.
    "An error occurred while drawing the world " write
    dup world>> pprint-short "." print
    "This world has been deactivated to prevent cascading errors." print
    error>> error. ;
