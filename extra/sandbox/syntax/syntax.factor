! Copyright (C) 2009 Maxim Savchenko.
! See http://factorcode.org/license.txt for BSD license.

USING: kernel sequences assocs namespaces lexer vocabs.parser sandbox ;
IN: sandbox.syntax

<PRIVATE

ERROR: sandbox-error vocab ;

: sandbox-use+ ( alias -- )
    dup whitelist get at [ use+ ] [ sandbox-error ] ?if ;

PRIVATE>

SYNTAX: APPLY: scan sandbox-use+ ;

SYNTAX: APPLYING: ";" parse-tokens [ sandbox-use+ ] each ;

REVEALING:
    ! #!
    HEX: OCT: BIN: f t CHAR: "
    [ { T{
    ] } ;

REVEAL: ;
