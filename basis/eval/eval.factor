! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: splitting parser compiler.units kernel namespaces
debugger io.streams.string ;
IN: eval

: eval ( str -- )
    [ string-lines parse-fresh ] with-compilation-unit call ;

: eval>string ( str -- output )
    [
        parser-notes off
        [ [ eval ] keep ] try drop
    ] with-string-writer ;
