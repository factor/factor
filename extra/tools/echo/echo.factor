! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: command-line io kernel namespaces sequences ;

IN: tools.echo

: -n? ( args -- ? args' )
    [ first "-n" = ] keep over [ rest ] when ;

: echo-args ( args -- )
    -n? " " join write [ nl ] unless ;

: run-echo ( -- )
    command-line get [ nl ] [ echo-args ] if-empty ;

MAIN: run-echo
