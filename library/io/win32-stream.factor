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

IN: win32-stream
USE: alien
USE: buffer
USE: generic
USE: kernel
USE: lists
USE: math
USE: namespaces
USE: stdio
USE: streams
USE: win32-api
USE: win32-io-internals

TRAITS: win32-stream
GENERIC: update-file-pointer

M: win32-stream fwrite-attr ( str style stream -- )
    nip fwrite ;

M: win32-stream freadln ( stream -- str )
    drop f ;

M: win32-stream fread# ( count stream -- str )
    drop f ;

M: win32-stream fflush ( stream -- )
    drop ;

M: win32-stream fclose ( stream -- )
    [ "handle" get CloseHandle drop "buffer" get buffer-free ] bind ;

C: win32-stream ( handle -- stream )
    [ "handle" set 4096 <buffer> "buffer" set 0 "fp" set ] extend ;

: <win32-filecr> ( path -- stream )
    t f win32-open-file <win32-stream> ;

