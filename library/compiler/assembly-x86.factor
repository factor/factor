! :folding=indent:collapseFolds=1:

! $Id$
!
! Copyright (C) 2004 Slava Pestov.
! 
! Redistribution and use in source and binary forms, with or without
! modification, are permitted provided that the following conditions are met:
! 
! 1. Redistributions of source code must retain the above copyright notice,
!    this list of conditions and the following disclaimer.
! 
! 2. Redistributions in binary form must reproduce the above copyright notice,
!    this list of conditions and the following disclaimer in the documentation
!    and/or other materials provided with the distribution.
! 
! THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
! INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
! FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
! DEVELOPERS AND CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
! SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
! PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
! OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
! WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
! OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
! ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

IN: compiler
USE: kernel
USE: compiler
USE: math
USE: stack

: EAX 0 ;
: ECX 1 ;
: EDX 2 ;
: EBX 3 ;
: ESP 4 ;
: EBP 5 ;
: ESI 6 ;
: EDI 7 ;

: PUSH ( reg -- )
    HEX: 50 + compile-byte ;

: POP ( reg -- )
    HEX: 58 + compile-byte ;

: I>R ( imm reg -- )
    #! MOV <imm> TO <reg>
    HEX: b8 + compile-byte  compile-cell ;

: [I]>R ( imm reg -- )
    #! MOV INDIRECT <imm> TO <reg>
    HEX: a1 + compile-byte  compile-cell ;

: I>[R] ( imm reg -- )
    #! MOV <imm> TO INDIRECT <reg>
    HEX: c7 compile-byte  compile-byte  compile-cell ;

: [R]>R ( reg reg -- )
    #! MOV INDIRECT <reg> TO <reg>.
    HEX: 8b compile-byte  swap 3 shift bitor compile-byte ;

: R>[R] ( reg reg -- )
    #! MOV <reg> TO INDIRECT <reg>.
    HEX: 89 compile-byte  swap 3 shift bitor compile-byte ;

: I+[I] ( imm addr -- )
    #! ADD <imm> TO ADDRESS <addr>
    HEX: 81 compile-byte
    HEX: 05 compile-byte
    compile-cell
    compile-cell ;

: LITERAL ( cell -- )
    #! Push literal on data stack.
    #! Assume that it is ok to clobber EAX without saving.
    DATASTACK EAX [I]>R
    EAX I>[R]
    4 DATASTACK I+[I] ;

: [LITERAL] ( cell -- )
    #! Push literal on data stack by following an indirect
    #! pointer.
    ECX PUSH
    ( cell -- ) ECX I>R
    ECX ECX [R]>R
    DATASTACK EAX [I]>R
    ECX EAX R>[R]
    4 DATASTACK I+[I]
    ECX POP ;

: (JMP) ( xt opcode -- )
    #! JMP, CALL insn is 5 bytes long
    #! addr is relative to *after* insn
    compile-byte  compiled-offset 4 + - compile-cell ;

: JMP ( -- )
    HEX: e9 (JMP) ;

: CALL ( -- )
    HEX: e8 (JMP) ;

: RET ( -- )
    HEX: c3 compile-byte ;
