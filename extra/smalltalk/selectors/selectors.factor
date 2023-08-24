! Copyright (C) 2009, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays combinators effects generic.standard
kernel sequences words lexer ;
IN: smalltalk.selectors

SYMBOLS: unary binary keyword ;

: selector-type ( selector -- type )
    {
        { [ dup [ "~!@%&*-+=|\\<>,?/" member? ] all? ] [ binary ] }
        { [ CHAR: : over member? ] [ keyword ] }
        [ unary ]
    } cond nip ;

: selector>effect ( selector -- effect )
    dup selector-type {
        { unary [ drop { } ] }
        { binary [ drop { "x" } ] }
        { keyword [ [ CHAR: : = ] count "x" <array> ] }
    } case "receiver" suffix { "result" } <effect> ;

: selector>generic ( selector -- generic )
    [ "selector-" prepend "smalltalk.selectors" create-word dup ]
    [ selector>effect ]
    bi define-simple-generic ;

SYNTAX: SELECTOR: scan-token selector>generic drop ;
