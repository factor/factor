! :folding=none:collapseFolds=1:

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

IN: io-internals
USE: combinators
USE: continuations
USE: kernel
USE: namespaces
USE: stack
USE: strings

: stdin 0 getenv ;
: stdout 1 getenv ;
: stderr 2 getenv ;

: yield ( -- )
    next-io-task dup [
        call
    ] [
        drop yield
    ] ifte ;

: flush-fd ( port -- )
    [ swap add-write-io-task yield ] callcc0 drop ;

: wait-to-write ( len port -- )
    tuck can-write? [ drop ] [ flush-fd ] ifte ;

: blocking-write ( str port -- )
    over
    dup string? [ str-length ] [ drop 1 ] ifte
    over wait-to-write write-fd-8 ;

: fill-fd ( port -- )
    [ swap add-read-line-io-task yield ] callcc0 drop ;

: wait-to-read-line ( port -- )
    dup can-read-line? [ drop ] [ fill-fd ] ifte ;

: blocking-read-line ( port -- line )
    dup wait-to-read-line read-line-fd-8 dup [ sbuf>str ] when ;

: fill-fd# ( count port -- )
    [ -rot add-read-count-io-task yield ] callcc0 2drop ;

: wait-to-read# ( count port -- )
    2dup can-read-count? [ 2drop ] [ fill-fd# ] ifte ;

: blocking-read# ( count port -- str )
    2dup wait-to-read# read-count-fd-8 dup [ sbuf>str ] when ;

: wait-to-accept ( socket -- )
    [ swap add-accept-io-task yield ] callcc0 drop ;

: blocking-accept ( socket -- host port in out )
    dup wait-to-accept accept-fd ;
