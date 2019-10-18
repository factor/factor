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

IN: win32-stream
USING: alien continuations generic kernel kernel-internals lists math
       namespaces prettyprint stdio streams strings threads win32-api
       win32-io-internals ;

TUPLE: win32-stream this ; ! FIXME: rewrite using tuples
GENERIC: win32-stream-handle
GENERIC: do-write

SYMBOL: handle
SYMBOL: in-buffer
SYMBOL: out-buffer
SYMBOL: fileptr
SYMBOL: file-size

: pending-error ( len/status -- len/status )
    dup [ win32-throw-error ] unless ;

: init-overlapped ( overlapped -- overlapped )
    0 over set-overlapped-ext-internal
    0 over set-overlapped-ext-internal-high
    fileptr get dup 0 ? over set-overlapped-ext-offset
    0 over set-overlapped-ext-offset-high
    0 over set-overlapped-ext-event ;

: update-file-pointer ( whence -- )
    file-size get [ fileptr [ + ] change ] [ drop ] ifte ;

: flush-output ( -- ) 
    [
        alloc-io-task init-overlapped >r
        handle get out-buffer get [ buffer-pos+ptr ] keep buffer-length
        NULL r> WriteFile [ handle-io-error ] unless (yield)
    ] callcc1 pending-error

    dup update-file-pointer
    out-buffer get [ buffer-consume ] keep 
    buffer-length 0 > [ flush-output ] when ;

: maybe-flush-output ( -- )
    out-buffer get buffer-length 0 > [ flush-output ] when ;

M: integer do-write ( int -- )
    out-buffer get [ buffer-capacity 0 = [ flush-output ] when ] keep
    buffer-append-char ;

M: string do-write ( str -- )
    dup str-length out-buffer get buffer-capacity <= [
        out-buffer get buffer-append
    ] [
        dup str-length out-buffer get buffer-size > [
            dup str-length out-buffer get buffer-extend do-write
        ] [ flush-output do-write ] ifte
    ] ifte ;

: fill-input ( -- ) 
    [
        alloc-io-task init-overlapped >r
        handle get in-buffer get [ buffer-pos+ptr ] keep 
        buffer-capacity file-size get [ fileptr get - min ] when*
        NULL r>
        ReadFile [ handle-io-error ] unless (yield)
    ] callcc1 pending-error

    dup in-buffer get buffer-inc-fill update-file-pointer ;

: consume-input ( count -- str ) 
    in-buffer get buffer-length 0 = [ fill-input ] when
    in-buffer get buffer-size min
    dup in-buffer get buffer-first-n
    swap in-buffer get buffer-consume ;

: sbuf>str-or-f ( sbuf -- str-or-? )
    dup sbuf-length 0 > [ sbuf>str ] [ drop f ] ifte ;

: do-read-count ( sbuf count -- str )
    dup 0 = [ 
        drop sbuf>str 
    ] [
        dup consume-input
        dup str-length dup 0 = [
            3drop sbuf>str-or-f
        ] [
            >r swap r> - >r swap [ sbuf-append ] keep r> do-read-count
        ] ifte
    ] ifte ;

: peek-input ( -- str )
    1 in-buffer get buffer-first-n ;

: do-read-line ( sbuf -- str )
    1 consume-input dup str-length 0 = [ drop sbuf>str-or-f ] [
        dup "\r" = [
            peek-input "\n" = [ 1 consume-input drop ] when 
            drop sbuf>str
        ] [ 
            dup "\n" = [
                peek-input "\r" = [ 1 consume-input drop ] when 
                drop sbuf>str
            ] [
                over sbuf-append do-read-line 
            ] ifte
        ] ifte
    ] ifte ;

M: win32-stream stream-write-attr ( str style stream -- )
    win32-stream-this nip [ do-write ] bind ;

M: win32-stream stream-readln ( stream -- str )
    win32-stream-this [ 80 <sbuf> do-read-line ] bind ;

M: win32-stream stream-read ( count stream -- str )
    win32-stream-this [ dup <sbuf> swap do-read-count ] bind ;

M: win32-stream stream-flush ( stream -- )
    win32-stream-this [ maybe-flush-output ] bind ;

M: win32-stream stream-auto-flush ( stream -- )
    drop ;

M: win32-stream stream-close ( stream -- )
    win32-stream-this [
        maybe-flush-output
        handle get CloseHandle drop 
        in-buffer get buffer-free 
        out-buffer get buffer-free
    ] bind ;

M: win32-stream win32-stream-handle ( stream -- handle )
    win32-stream-this [ handle get ] bind ;

C: win32-stream ( handle -- stream )
    swap <namespace> [
        dup NULL GetFileSize dup -1 = not [
            file-size set
        ] [ drop f file-size set ] ifte
        handle set 
        4096 <buffer> in-buffer set 
        4096 <buffer> out-buffer set
        0 fileptr set 
    ] extend over set-win32-stream-this ;

: <win32-file-reader> ( path -- stream )
    t f win32-open-file <win32-stream> ;

: <win32-file-writer> ( path -- stream )
    f t win32-open-file <win32-stream> ;


