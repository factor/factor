! :folding=indent:collapseFolds=1:

! $Id$
!
! Copyright (C) 2004 Mackenzie Straight.
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

IN: win32-api
USE: buffer
USE: errors
USE: kernel
USE: kernel-internals
USE: lists
USE: math
USE: parser
USE: alien
USE: words

: CONSTANT: CREATE 
    [ [ [ swons ] each ] cons define-compound POSTPONE: parsing ] 
    [ ] ; parsing

CONSTANT: ERROR_SUCCESS 0 ;
CONSTANT: ERROR_HANDLE_EOF 38 ;
CONSTANT: ERROR_IO_PENDING 997 ;
CONSTANT: WAIT_TIMEOUT 258 ;

: FORMAT_MESSAGE_ALLOCATE_BUFFER HEX: 00000100 ;
: FORMAT_MESSAGE_IGNORE_INSERTS  HEX: 00000200 ;
: FORMAT_MESSAGE_FROM_STRING     HEX: 00000400 ;
: FORMAT_MESSAGE_FROM_HMODULE    HEX: 00000800 ;
: FORMAT_MESSAGE_FROM_SYSTEM     HEX: 00001000 ;
: FORMAT_MESSAGE_ARGUMENT_ARRAY  HEX: 00002000 ;
: FORMAT_MESSAGE_MAX_WIDTH_MASK  HEX: 000000FF ;

: MAKELANGID ( primary sub -- lang )
    10 shift bitor ;

: LANG_NEUTRAL 0 ;
: SUBLANG_DEFAULT 1 ;

: GetLastError ( -- int )
    "int" "kernel32" "GetLastError" [ ] alien-invoke ;

: FormatMessage ( flags source messageid langid buf size args -- int )
    "int" "kernel32" "FormatMessageA" 
    [ "int" "void*" "int" "int" "void*" "int" "void*" ]
    alien-invoke ;

: win32-error-message ( id -- string )
    4096 <buffer> dup >r >r >r
    FORMAT_MESSAGE_FROM_SYSTEM NULL r>
    LANG_NEUTRAL SUBLANG_DEFAULT MAKELANGID r> buffer-ptr <alien> 4096 NULL
    FormatMessage r> 2dup buffer-reset nip dup buffer-contents 
    swap buffer-free ;

: win32-throw-error ( -- )
    GetLastError win32-error-message throw ;

