! Copyright (C) 2006, 2011 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors continuations debugger io io.streams.string
kernel namespaces prettyprint ui ui.gadgets.worlds ;
IN: ui.debugger

: error-alert ( error -- )
    [ dup error. flush ] with-global
    ! A modal event loop can re-enter the failing native callback. Cocoa
    ! also prohibits runModal during drawing and transaction commits.
    in-callback? [ drop ] [
        [ "Error" ] dip [ print-error ] with-string-writer
        system-alert
    ] if ;

! ( error -- )
[ error-alert ] ui-error-hook set-global

! ( error -- * )
[
    ui-running? [ dup error-alert ] [ dup print-error flush ] if
    die rethrow
] callback-error-hook set-global

M: world-error error.
    "An error occurred while drawing the world " write
    dup world>> pprint-short "." print
    "This world has been deactivated to prevent cascading errors." print
    error>> error. ;
