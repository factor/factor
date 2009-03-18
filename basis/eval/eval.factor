! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: splitting parser compiler.units kernel namespaces
debugger io.streams.string fry ;
IN: eval

: parse-string ( str -- quot )
    [ string-lines parse-lines ] with-compilation-unit ;

: (eval) ( str -- )
    parse-string call ;

: eval ( str -- )
    [ (eval) ] with-file-vocabs ;

: (eval>string) ( str -- output )
    [
        "quiet" on
        parser-notes off
        '[ _ (eval) ] try
    ] with-string-writer ;

: eval>string ( str -- output )
    [ (eval>string) ] with-file-vocabs ;