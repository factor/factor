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

IN: inference
USE: interpreter
USE: lists
USE: math
USE: namespaces
USE: stack
USE: words
USE: combinators
USE: vectors

! We build a dataflow graph for the compiler.
SYMBOL: dataflow-graph

SYMBOL: CALL ( non-tail call )
SYMBOL: JUMP ( tail-call )
SYMBOL: PUSH ( literal )

SYMBOL: IFTE
SYMBOL: GENERIC
SYMBOL: 2GENERIC

: get-dataflow ( -- IR )
    dataflow-graph get reverse ;

: inputs ( count -- vector )
    meta-d get [ vector-length swap - ] keep vector-tail ;

: dataflow, ( consume instruction parameters -- )
    #! Add a node to the dataflow IR. Each node is a list of
    #! three elements:
    #! - vector of elements consumed from stack
    #! - a symbol CALL, JUMP or PUSH
    #! - parameter(s) to insn
    unit cons cons  dataflow-graph cons@ ;

: dataflow-literal, ( lit -- )
    >r 0 inputs PUSH r> dataflow, ;

: dataflow-word, ( word -- )
    [
        "infer-effect" word-property car inputs CALL
    ] keep dataflow, ;
