! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel prettyprint io io.styles colors.constants compiler.units
fry debugger sequences locals.rewrite.closures smalltalk.ast
smalltalk.parser smalltalk.compiler smalltalk.printer ;
IN: smalltalk.listener

: eval-smalltalk ( string -- )
    [
        parse-smalltalk-statement compile-statement rewrite-closures first
    ] with-compilation-unit call( -- result )
    dup nil? [ drop ] [ "Result: " write smalltalk>string print ] if ;

: smalltalk-listener ( -- )
    "Smalltalk>" { { background COLOR: light-blue } } format bl flush readln
    [ '[ _ eval-smalltalk ] try smalltalk-listener ] when* ;

MAIN: smalltalk-listener