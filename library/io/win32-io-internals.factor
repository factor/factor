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
USE: errors
USE: kernel
USE: kernel-internals
USE: lists
USE: math
USE: namespaces
USE: prettyprint
USE: vectors
USE: win32-api

SYMBOL: completion-port
SYMBOL: io-queue
SYMBOL: free-list
SYMBOL: callbacks

: handle-io-error ( -- )
    #! If a write or read call fails unexpectedly, throw an error.
    GetLastError [ 
        ERROR_IO_PENDING ERROR_HANDLE_EOF ERROR_SUCCESS 
    ] contains? [ 
        win32-throw-error 
    ] unless ;

: win32-init-stdio ( -- )
    INVALID_HANDLE_VALUE NULL NULL 1 CreateIoCompletionPort
    completion-port set 
    
    <namespace> [
        32 <vector> callbacks set
        f free-list set
    ] extend io-queue set ;

: get-access ( -- file-mode )
    "file-mode" get uncons 
    GENERIC_WRITE 0 ? >r
    GENERIC_READ 0 ? r> bitor ;

: get-sharemode ( -- share-mode )
     FILE_SHARE_READ FILE_SHARE_WRITE bitor ;

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
        dup completion-port get NULL 1 CreateIoCompletionPort drop
    ] with-scope ;

BEGIN-STRUCT: indirect-pointer
    FIELD: int value
END-STRUCT

: num-callbacks ( -- len )
    #! Returns the length of the callback vector.
    io-queue get [ callbacks get vector-length ] bind ;

: set-callback-quot ( quot index -- )
    io-queue get [
        dup >r callbacks get vector-nth car swap cons
        r> callbacks get set-vector-nth
    ] bind ;

: new-overlapped ( -- index )
    #! Allocates and returns a new entry for the io queue.
    #! The new index in the callback vector is returned.
    io-queue get [
        "overlapped-ext" c-type [ "width" get ] bind imalloc <alien>
        dup num-callbacks swap
        set-overlapped-ext-user-data
        unit num-callbacks dup >r callbacks get set-vector-nth r>
    ] bind ;

: alloc-io-task ( quot -- overlapped )
    io-queue get [
        free-list get [
            uncons free-list set
        ] [ new-overlapped ] ifte*
        [ set-callback-quot ] keep 
        callbacks get vector-nth car
    ] bind ;

: get-io-callback ( index -- callback )
    #! Returns and frees the io queue entry at index.
    io-queue get [
        dup free-list [ cons ] change
        callbacks get vector-nth cdr
    ] bind ;

: win32-next-io-task ( -- quot )
    completion-port get <indirect-pointer> dup >r <indirect-pointer> 
    <indirect-pointer> dup >r INFINITE GetQueuedCompletionStatus
    [ handle-io-error ] unless
    r> r> indirect-pointer-value swap indirect-pointer-value <alien> 
    overlapped-ext-user-data get-io-callback call ;

