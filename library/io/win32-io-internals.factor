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

IN: win32-io-internals
USE: alien
USE: kernel
USE: lists
USE: math
USE: namespaces
USE: win32-api

: win32-init-stdio ( -- )
    INVALID_HANDLE_VALUE NULL NULL 1 CreateIoCompletionPort
    "completion-port" set ;

: get-access ( -- file-mode )
    0 "file-mode" get uncons >r 
    [ GENERIC_WRITE ] [ 0 ] ifte bitor r>
    [ GENERIC_READ ] [ 0 ] ifte bitor ;

: get-sharemode ( -- share-mode )
    FILE_SHARE_READ FILE_SHARE_WRITE bitor FILE_SHARE_DELETE bitor ;

: get-create ( -- creation-disposition )
    "file-mode" get uncons [
      [ OPEN_ALWAYS ] [ CREATE_ALWAYS ] ifte  
    ] [
      [ OPEN_EXISTING ] [ 0 ] ifte
    ] ifte ;

: win32-open-file ( file r w -- handle )
    [ 
        cons "file-mode" set
        get-access get-sharemode NULL get-create FILE_FLAG_OVERLAPPED NULL 
        CreateFile dup INVALID_HANDLE_VALUE = [ win32-throw-error ] when
        dup "completion-port" get NULL 1 CreateIoCompletionPort drop
    ] with-scope ;

