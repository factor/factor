!:folding=indent:collapseFolds=1:

! $Id$
!
! Copyright (C) 2003, 2004 Slava Pestov.
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

IN: stack
USE: kernel
USE: vectors

~<< drop              A --             >>~
~<< 2drop           A B --             >>~
~<< 2dup            A B -- A B A B     >>~
~<< dupd            A B -- A A B       >>~
~<< 2dupd       A B C D -- A B A B C D >>~
~<< nip             A B -- B           >>~
~<< 2nip        A B C D -- C D         >>~
~<< nop                 --             >>~ ! Does nothing!
~<< over            A B -- A B A       >>~
~<< 2over       A B C D -- A B C D A B >>~
~<< pick          A B C -- A B C A     >>~ ! Not the Forth pick!
~<< rot           A B C -- B C A       >>~
~<< 2rot    A B C D E F -- C D E F A B >>~
~<< -rot          A B C -- C A B       >>~
~<< 2-rot   A B C D E F -- E F A B C D >>~
~<< 2swap       A B C D -- C D A B     >>~
~<< swapd         A B C -- B A C       >>~
~<< 2swapd  A B C D E F -- C D A B E F >>~
~<< transp        A B C -- C B A       >>~
~<< 2transp A B C D E F -- E F C D A B >>~
~<< tuck            A B -- B A B       >>~
~<< 2tuck       A B C D -- C D A B C D >>~

~<< 3drop         A B C --             >>~
~<< 3dup          A B C -- A B C A B C >>~

~<< >r        A -- r:A             >>~
~<< r>      r:A -- A               >>~

: apply-shuffle ( ds cs shuffle -- )
    interpreter swap
    [
        "factor.FactorInterpreter"
        "factor.FactorArray"
        "factor.FactorArray"
    ]
    "factor.FactorShuffleDefinition" "eval" jinvoke ;
