! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types arrays byte-arrays combinators
destructors generic io kernel libc math sequences system tr
vocabs.loader words alien.data ;
IN: tools.disassembler

GENERIC: disassemble ( obj -- )

SYMBOL: disassembler-backend

HOOK: disassemble* disassembler-backend ( from to -- lines )

TR: tabs>spaces "\t" "\s" ;

M: byte-array disassemble 
    [
        [ malloc-byte-array &free alien-address dup ]
        [ length + ] bi
        2array disassemble
    ] with-destructors ;

M: pair disassemble first2 disassemble* [ tabs>spaces print ] each ;

M: word disassemble word-xt 2array disassemble ;

cpu x86?
"tools.disassembler.udis"
"tools.disassembler.gdb" ?
require
