! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: tr arrays sequences io words generic system combinators
vocabs.loader ;
IN: tools.disassembler

GENERIC: disassemble ( obj -- )

SYMBOL: disassembler-backend

HOOK: disassemble* disassembler-backend ( from to -- lines )

TR: tabs>spaces "\t" "\s" ;

M: pair disassemble first2 disassemble* [ tabs>spaces print ] each ;

M: word disassemble word-xt 2array disassemble ;

M: method-spec disassemble first2 method disassemble ;

cpu {
    { x86.32 [ "tools.disassembler.udis" ] }
    { x86.64 [ "tools.disassembler.udis" ] }
    { ppc [ "tools.disassembler.gdb" ] }
} case require
