! :folding=indent:collapseFolds=1:

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

: datastack* ( -- datastack )
    interpreter "factor.FactorInterpreter" "datastack" jvar-get ;

: datastack ( -- datastack )
    datastack* clone ; interpret-only

: set-datastack* ( datastack -- ... )
    interpreter "factor.FactorInterpreter" "datastack" jvar-set ;

: set-datastack ( datastack -- ... )
    clone set-datastack* ; interpret-only

: callstack* ( -- callstack )
    interpreter "factor.FactorInterpreter" "callstack" jvar-get ;

: callstack ( -- callstack )
    callstack*
    ! When 'clone' is interpreted, 'call' pushes a call frame
    ! which is replaced by 'clone' due to tail call optimization.
    ! When 'clone' is compiled, 'call' pushes a call frame, which
    ! is not affected by 'clone'.
    ! In both cases, the call stack has a frame from 'call' and
    ! a frame from 'callstack', and we pop both off so that
    ! callstack pushes the callstack as it was in the calling
    ! word.
    [ clone ] call
    dup vector-pop drop
    dup vector-pop drop ; interpret-only

: set-callstack* ( callstack -- ... )
    interpreter "factor.FactorInterpreter" "callstack" jvar-set ;

: set-callstack ( callstack -- ... )
    clone set-callstack* ; interpret-only

: clear ( -- )
    #! Clear the datastack. For interactive use only; invoking this from a
    #! word definition will clobber any values left on the data stack by the
    #! caller.
    datastack* vector-clear ;
