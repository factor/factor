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

IN: stdio
USE: arithmetic
USE: stack
USE: streams
USE: strings

: read-little-endian-32 ( -- word )
    read1
    read1 8  shift< bitor
    read1 16 shift< bitor
    read1 24 shift< bitor ;

: read-big-endian-32 ( -- word )
    read1 24 shift<
    read1 16 shift< bitor
    read1 8  shift< bitor
    read1           bitor ;

: byte3 ( num -- byte ) 24 shift> HEX: ff bitand ;
: byte2 ( num -- byte ) 16 shift> HEX: ff bitand ;
: byte1 ( num -- byte )  8 shift> HEX: ff bitand ;
: byte0 ( num -- byte )           HEX: ff bitand ;

: write-little-endian-32 ( word -- )
    dup byte0 >char write
    dup byte1 >char write
    dup byte2 >char write
        byte3 >char write ;

: write-big-endian-32 ( word -- )
    dup byte3 >char write
    dup byte2 >char write
    dup byte1 >char write
        byte0 >char write ;

: write-little-endian-16 ( char -- )
    dup byte0 >char write
        byte1 >char write ;

: write-big-endian-16 ( char -- )
    dup byte1 >char write
        byte0 >char write ;
