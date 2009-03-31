! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators effects generic generic.standard
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
        { unary [ drop 0 ] }
        { binary [ drop 1 ] }
        { keyword [ [ CHAR: : = ] count ] }
    } case "receiver" suffix { "result" } <effect> ;

: selector>generic ( selector -- generic )
    [ "selector-" prepend "smalltalk.selectors" create dup ]
    [ selector>effect ]
    bi define-simple-generic ;

SYNTAX: SELECTOR: scan selector>generic drop ;