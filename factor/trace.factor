!:folding=indent:collapseFolds=1:

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

! TODO: tracing non-compound words using a gensym.
! TODO: broken with doc comments.

: TRACED ( -- )
    ! Marker word. Words that are traced have this as their
    ! first factor.
    ;

: compound>list ( worddef -- list )
    worddef>list cdr cdr ;

: [trace+] ( word stack? -- def )
    [ #=TRACED swap "Trace: " swap cat2 #=print 3list ] dip
    [ .s ] [ ] ? append ;

: traced? ( word -- ? )
    worddef dup compound? [
        compound>list car #=TRACED =
    ] [
        drop f
    ] ifte ;

: trace+ ( word stack? -- )
    over traced? [
        "Already traced." print
        2drop
    ] [
        over worddef dup compound? [
            compound>list [ dupd [trace+] ] dip append define
        ] [
            "Cannot trace non-compound definition." print
        ] ifte
    ] ifte ;

: [trace-] ( def -- def )
    cdr cdr cdr ;

: trace- ( word -- )
    dup traced? [
        dup worddef compound>list [trace-] define
    ] [
        drop "Not traced." print
    ] ifte ;
