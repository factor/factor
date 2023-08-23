! Copyright (C) 2012 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors arrays environment kernel math math.parser
sequences system vocabs ;

IN: terminal

HOOK: (terminal-size) os ( -- columns lines )

"terminal." os name>> append require

: terminal-size ( -- dim )
    "COLUMNS" "LINES"
    [ os-env [ string>number ] [ 0 ] if* ] bi@
    2dup [ 0 <= ] either? [
        (terminal-size)
        [ over 0 <= [ nip ] [ drop ] if ] bi-curry@ bi*
    ] when 2array ;

: terminal-width ( -- width ) terminal-size first ;

: terminal-height ( -- height ) terminal-size second ;
