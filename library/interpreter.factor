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

IN: interpreter
USE: arithmetic
USE: combinators
USE: continuations
USE: kernel
USE: lists
USE: logic
USE: namespaces
USE: parser
USE: stack
USE: stdio
USE: strings
USE: styles
USE: words
USE: unparser
USE: vectors

: exit ( -- )
    t "quit-flag" set ;

: print-banner ( -- )
    "Factor " version cat2 print
    "Copyright (C) 2003, 2004 Slava Pestov" print
    "Enter ``exit'' to exit." print ;

: history+ ( cmd -- )
    "history" get vector-push ;

: print-numbered-entry ( index vector -- )
    dupd vector-nth ": " swap cat3 print ;

: print-numbered-vector ( list -- )
    dup vector-length [ over print-numbered-entry ] times* drop ;

: history ( -- )
    "X redo    -- evaluate the expression with number X." print
    "X re-edit -- edit the expression with number X." print
    "history" get print-numbered-vector ;

: get-history ( index -- )
    "history" get vector-nth ;

: redo ( index -- )
    get-history dup "  ( " write write " )" print eval ;

: re-edit ( index -- )
    get-history edit ;

: history# ( -- number )
    "history" get vector-length ;

: print-prompt ( -- )
    <% "  ( " % history# fixnum>str % " ) " % %>
    [ "prompt" ] get-style
    [ write-attr ] bind
    flush ;

: interpret ( -- )
    print-prompt read dup [
        dup history+ eval
    ] [
        drop "quit-flag" on
    ] ifte ;

: interpreter-loop ( -- )
    64 <vector> "history" set
    [ "quit-flag" get not ] [ interpret ] while
    "quit-flag" off ;
