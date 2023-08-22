! Copyright (C) 2011 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: command-line io io.encodings.utf8 io.files kernel
namespaces sets sequences ;

IN: tools.uniq

: uniq-lines ( -- )
    f [
        2dup = [ dup print ] unless nip
    ] each-line drop ;

: uniq-file ( path/f -- )
    [
        utf8 [ uniq-lines ] with-file-reader
    ] [
        uniq-lines
    ] if* ;

: run-uniq ( -- )
    command-line get [ ?first ] [ ?second ] bi [
        utf8 [ uniq-file ] with-file-writer
    ] [
        uniq-file
    ] if* ;

MAIN: run-uniq
