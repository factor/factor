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
USE: combinators
USE: kernel
USE: lists
USE: math
USE: namespaces
USE: prettyprint
USE: stack
USE: words
USE: vectors

! The variable "profile-top-only" toggles between
! culminative counts, and top of call stack counts.

: reset-counts ( -- )
    [ 0 over set-call-count 0 swap set-allot-count ] each-word ;

: sort-counts ( alist -- alist )
    [ swap cdr swap cdr > ] sort ;

: call-count, ( word -- )
    #! Add to constructing list if call count is non-zero.
    dup call-count dup 0 = [
        2drop
    ] [
        cons ,
    ] ifte ;

: counts. ( alist -- )
    sort-counts [ . ] each ;

: call-counts. ( -- )
    #! Print word/call count pairs.
    [, [ call-count, ] each-word ,] counts. ;

: profile-depth ( -- n )
    "profile-top-only" get [
        -1
    ] [
        callstack vector-length
    ] ifte ;

: call-profile ( quot -- )
    #! Execute a quotation with the CPU profiler enabled.
    reset-counts
    profile-depth call-profiling
    call
    f call-profiling
    call-counts. ;

: allot-count, ( word -- )
    #! Add to constructing list if allot count is non-zero.
    dup allot-count dup 0 = [
        2drop
    ] [
        cons ,
    ] ifte ;

: allot-counts. ( -- alist )
    #! Print word/allot count pairs.
    [, [ allot-count, ] each-word ,] counts. ;

: allot-profile ( quot -- )
    #! Execute a quotation with the memory profiler enabled.
    reset-counts
    profile-depth allot-profiling
    call
    f allot-profiling
    allot-counts. ;
