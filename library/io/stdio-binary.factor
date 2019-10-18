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
USE: kernel
USE: math
USE: streams
USE: strings

: read-little-endian-32 ( -- word )
    read1
    read1 8  shift bitor
    read1 16 shift bitor
    read1 24 shift bitor ;

: read-big-endian-32 ( -- word )
    read1 24 shift
    read1 16 shift bitor
    read1 8  shift bitor
    read1          bitor ;

: byte7 ( num -- byte ) -56 shift HEX: ff bitand ;
: byte6 ( num -- byte ) -48 shift HEX: ff bitand ;
: byte5 ( num -- byte ) -40 shift HEX: ff bitand ;
: byte4 ( num -- byte ) -32 shift HEX: ff bitand ;
: byte3 ( num -- byte ) -24 shift HEX: ff bitand ;
: byte2 ( num -- byte ) -16 shift HEX: ff bitand ;
: byte1 ( num -- byte )  -8 shift HEX: ff bitand ;
: byte0 ( num -- byte )           HEX: ff bitand ;

: write-little-endian-64 ( word -- )
    dup byte0 write
    dup byte1 write
    dup byte2 write
    dup byte3 write
    dup byte4 write
    dup byte5 write
    dup byte6 write
        byte7 write ;

: write-big-endian-64 ( word -- )
    dup byte7 write
    dup byte6 write
    dup byte5 write
    dup byte4 write
    dup byte3 write
    dup byte2 write
    dup byte1 write
        byte0 write ;

: write-little-endian-32 ( word -- )
    dup byte0 write
    dup byte1 write
    dup byte2 write
        byte3 write ;

: write-big-endian-32 ( word -- )
    dup byte3 write
    dup byte2 write
    dup byte1 write
        byte0 write ;

: write-little-endian-16 ( char -- )
    dup byte0 write
        byte1 write ;

: write-big-endian-16 ( char -- )
    dup byte1 write
        byte0 write ;
