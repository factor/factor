! $Id$
!
! Copyright (C) 2004, 2005 Mackenzie Straight.
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
USING: alien errors kernel kernel-internals lists math namespaces threads 
       vectors win32-api io generic io-internals sequences ;

SYMBOL: completion-port
SYMBOL: io-queue

TUPLE: io-queue free-list callbacks ;
TUPLE: io-callback overlapped quotation stream ;

GENERIC: expire

: expected-error? ( -- bool )
    [ 
        ERROR_IO_PENDING ERROR_HANDLE_EOF ERROR_SUCCESS WAIT_TIMEOUT 
    ] member? ;

: handle-io-error ( -- )
    GetLastError expected-error? [ win32-throw-error ] unless ;

: queue-error ( len/status -- len/status )
    GetLastError expected-error? [ drop f ] unless ;

: add-completion ( handle -- )
    completion-port get f 1 CreateIoCompletionPort drop ;

: get-access ( -- file-mode )
    "file-mode" get uncons 
    GENERIC_WRITE 0 ? >r
    GENERIC_READ 0 ? r> bitor ;

: get-sharemode ( -- share-mode )
     FILE_SHARE_READ FILE_SHARE_WRITE bitor ;

: get-create ( -- creation-disposition )
    "file-mode" get uncons [
      [ OPEN_ALWAYS ] [ CREATE_ALWAYS ] if  
    ] [
      [ OPEN_EXISTING ] [ 0 ] if
    ] if ;

: win32-open-file ( file r w -- handle )
    [ 
        cons "file-mode" set
        get-access get-sharemode f get-create FILE_FLAG_OVERLAPPED f 
        CreateFile dup INVALID_HANDLE_VALUE = [ win32-throw-error ] when
        dup add-completion
    ] with-scope ;

BEGIN-STRUCT: indirect-pointer
    FIELD: int value
END-STRUCT

: <overlapped> ( -- overlapped )
    "overlapped-ext" c-size malloc <alien> ;

C: io-queue ( -- queue )
    V{ } clone over set-io-queue-callbacks ;

C: io-callback ( -- callback )
    io-queue get io-queue-callbacks [ push ] 2keep
    length 1 - <overlapped> [ set-overlapped-ext-user-data ] keep
    swap [ set-io-callback-overlapped ] keep ;

: alloc-io-callback ( quot stream -- overlapped )
    io-queue get io-queue-free-list [ 
        uncons io-queue get [ set-io-queue-free-list ] keep
        io-queue-callbacks nth
    ] [ <io-callback> ] if*
    [ set-io-callback-stream ] keep
    [ set-io-callback-quotation ] keep
    io-callback-overlapped ;

: get-io-callback ( index -- callback )
    dup io-queue get io-queue-callbacks nth swap
    io-queue get [ io-queue-free-list cons ] keep set-io-queue-free-list 
    [ f swap set-io-callback-stream ] keep
    io-callback-quotation ;

: (wait-for-io) ( timeout -- error overlapped len )
    >r completion-port get 
    "indirect-pointer" <c-object> [ 0 swap set-indirect-pointer-value ] keep 
    "indirect-pointer" <c-object>
    "indirect-pointer" <c-object>
    pick over r> -rot >r >r GetQueuedCompletionStatus r> r> ;

: overlapped>callback ( overlapped -- callback )
    indirect-pointer-value dup zero? [
        drop f
    ] [
        <alien> overlapped-ext-user-data get-io-callback
    ] if ;

: cancel-timedout ( -- )
    io-queue get 
    io-queue-callbacks [ io-callback-stream [ expire ] when* ] each ;

: wait-for-io ( timeout -- callback len )
    (wait-for-io) overlapped>callback swap indirect-pointer-value 
    rot [ queue-error ] unless ;

: win32-init-stdio ( -- )
    INVALID_HANDLE_VALUE f f 1 CreateIoCompletionPort
    completion-port set 
    <io-queue> io-queue set ;

