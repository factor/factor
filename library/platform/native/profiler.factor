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

IN: profiler
USE: kernel
USE: lists
USE: math
USE: prettyprint
USE: stack
USE: words
USE: vectors

: reset-call-counts ( -- )
    vocabs [ words [ 0 swap set-call-count ] each ] each ;

: sort-call-counts ( alist -- alist )
    [ swap cdr swap cdr > ] sort ;

: call-count, ( word -- )
    #! Add to constructing list if call count is non-zero.
    dup call-count dup 0 = [
        2drop
    ] [
        cons ,
    ] ifte ;

: call-counts ( -- alist )
    #! Push an alist of all word/call count pairs.
    [, [ call-count, ] each-word ,] sort-call-counts ;

: profile ( quot -- )
    #! Execute a quotation with the profiler enabled.
    reset-call-counts
    callstack vector-length profiling
    call
    f profiling
    call-counts [ . ] each ;
