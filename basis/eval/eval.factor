! Copyright (C) 2008, 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: combinators combinators.smart compiler.units
continuations debugger effects.parser io io.streams.string
kernel namespaces parser parser.notes prettyprint splitting ;
IN: eval

: parse-string ( str -- quot )
    [ split-lines parse-lines ] with-compilation-unit ;

: (eval) ( str effect -- )
    [ parse-string ] dip call-effect ; inline

: eval ( str effect -- )
    [ (eval) ] with-file-vocabs ; inline

SYNTAX: eval( \ eval parse-call-paren ;

: (eval>string) ( str -- output )
    [
        parser-quiet? on
        '[ _ ( -- ) (eval) ] [ print-error ] recover
    ] with-string-writer ;

: eval>string ( str -- output )
    [ (eval>string) ] with-file-vocabs ;

: (eval-with-stack) ( str -- )
    parse-string [
        output>array flush [ datastack. flush ] with-output>error
    ] call( quot -- ) ;

: eval-with-stack ( str -- )
    [ (eval-with-stack) ] with-file-vocabs ;

: (eval-with-stack>string) ( str -- output )
    [
        parser-quiet? on
        [ (eval-with-stack) ] [ nip print-error ] recover
    ] with-string-writer ;

: eval-with-stack>string ( str -- output )
    [ (eval-with-stack>string) ] with-file-vocabs ;
