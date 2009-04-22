! Copyright (C) 2009 Maxim Savchenko.
! See http://factorcode.org/license.txt for BSD license.

USING: kernel sequences vectors assocs namespaces parser lexer vocabs
       combinators.short-circuit vocabs.parser ;

IN: sandbox

SYMBOL: whitelist

: with-sandbox-vocabs ( quot -- )
    "sandbox.syntax" load-vocab vocab-words 1vector
    use [ auto-use? off call ] with-variable ; inline

: parse-sandbox ( lines assoc -- quot )
    whitelist [ [ parse-lines ] with-sandbox-vocabs ] with-variable ;

: reveal-in ( name -- )
    [ { [ search ] [ no-word ] } 1|| ] keep current-vocab vocab-words set-at ;

SYNTAX: REVEAL: scan reveal-in ;

SYNTAX: REVEALING: ";" parse-tokens [ reveal-in ] each ;
