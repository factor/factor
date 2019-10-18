! :folding=indent:collapseFolds=1:

! $Id$
!
! Copyright (C) 2004, 2005 Slava Pestov.
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

IN: assembler
USING: alien math memory kernel hashtables namespaces ;

SYMBOL: interned-literals

: cell 4 ; inline
: compiled-header HEX: 01c3babe ; inline

: set-compiled-byte ( n addr -- )
    <alien> 0 set-alien-1 ; inline

: set-compiled-cell ( n addr -- )
    <alien> 0 set-alien-cell ; inline

: compile-aligned ( n -- )
    compiled-offset cell 2 * align set-compiled-offset ; inline

: intern-literal ( obj -- lit# )
    dup interned-literals get hash [
        [
            address
            literal-top set-compiled-cell
            literal-top dup cell + set-literal-top
            dup
        ] keep interned-literals get set-hash
    ] ?unless ;

: compile-byte ( n -- )
    compiled-offset set-compiled-byte
    compiled-offset 1 + set-compiled-offset ; inline

: compile-cell ( n -- )
    compiled-offset set-compiled-cell
    compiled-offset cell + set-compiled-offset ; inline

: begin-assembly ( -- code-len-fixup reloc-len-fixup )
    compiled-header compile-cell
    compiled-offset 0 compile-cell
    compiled-offset 0 compile-cell ;

: init-assembler ( -- )
    global [ <namespace> interned-literals set ] bind ;
