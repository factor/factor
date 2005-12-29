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
USING: alien generic io-internals kernel
kernel-internals lists math namespaces prettyprint sequences
io strings threads win32-api win32-io-internals ;

TUPLE: win32-stream this ; ! FIXME: rewrite using tuples
GENERIC: win32-stream-handle
GENERIC: do-write

SYMBOL: handle
SYMBOL: in-buffer
SYMBOL: out-buffer
SYMBOL: fileptr
SYMBOL: file-size
SYMBOL: stream
SYMBOL: timeout
SYMBOL: cutoff

: pending-error ( len/status -- len/status )
    dup [ win32-throw-error ] unless ;

: init-overlapped ( overlapped -- overlapped )
    0 over set-overlapped-ext-internal
    0 over set-overlapped-ext-internal-high
    fileptr get dup 0 ? over set-overlapped-ext-offset
    0 over set-overlapped-ext-offset-high
    f over set-overlapped-ext-event ;

: update-file-pointer ( whence -- )
    file-size get [ fileptr [ + ] change ] [ drop ] if ;

: update-timeout ( -- )
    timeout get [ millis + cutoff set ] when* ;

: flush-output ( -- ) 
    update-timeout [
        stream get alloc-io-callback init-overlapped >r
        handle get out-buffer get [ buffer@ ] keep buffer-length
        f r> WriteFile [ handle-io-error ] unless stop
    ] callcc1 pending-error

    dup update-file-pointer
    out-buffer get [ buffer-consume ] keep 
    buffer-length 0 > [ flush-output ] when ;

: maybe-flush-output ( -- )
    out-buffer get buffer-length 0 > [ flush-output ] when ;

M: integer do-write ( int -- )
    out-buffer get [ buffer-capacity 0 = [ flush-output ] when ] keep
    >r ch>string r> >buffer ;

M: string do-write ( str -- )
    dup length out-buffer get buffer-capacity <= [
        out-buffer get >buffer
    ] [
        dup length out-buffer get buffer-size > [
            dup length out-buffer get buffer-extend do-write
        ] [ flush-output do-write ] if
    ] if ;

: fill-input ( -- ) 
    update-timeout [
        stream get alloc-io-callback init-overlapped >r
        handle get in-buffer get [ buffer@ ] keep 
        buffer-capacity file-size get [ fileptr get - min ] when*
        f r>
        ReadFile [ handle-io-error ] unless stop
    ] callcc1 pending-error

    dup in-buffer get n>buffer update-file-pointer ;

: consume-input ( count -- str ) 
    in-buffer get buffer-length 0 = [ fill-input ] when
    in-buffer get buffer-size min
    dup in-buffer get buffer-first-n
    swap in-buffer get buffer-consume ;

: >string-or-f ( sbuf -- str-or-? )
    dup length 0 > [ >string ] [ drop f ] if ;

: do-read-count ( sbuf count -- str )
    dup 0 = [ 
        drop >string 
    ] [
        dup consume-input
        dup length dup 0 = [
            3drop >string-or-f
        ] [
            >r swap r> - >r swap [ swap nappend ] keep r> do-read-count
        ] if
    ] if ;

: peek-input ( -- str )
    1 in-buffer get buffer-first-n ;

M: win32-stream stream-write ( str stream -- )
    win32-stream-this [ do-write ] bind ;

M: win32-stream stream-write1 ( char stream -- )
    win32-stream-this [ >fixnum do-write ] bind ;

M: win32-stream stream-read ( count stream -- str )
    win32-stream-this [ dup <sbuf> swap do-read-count ] bind ;

M: win32-stream stream-read1 ( stream -- str )
    win32-stream-this [
        1 consume-input dup length 0 = [ drop f ] when first 
    ] bind ;

M: win32-stream stream-readln ( stream -- str )
    win32-stream-this [ readln ] bind ;

M: win32-stream stream-terpri
    win32-stream-this [ CHAR: \n do-write ] bind ;

M: win32-stream stream-terpri*
    win32-stream-this stream-terpri ;

M: win32-stream stream-flush ( stream -- )
    win32-stream-this [ maybe-flush-output ] bind ;

M: win32-stream stream-close ( stream -- )
    win32-stream-this [
        maybe-flush-output
        handle get CloseHandle drop 
        in-buffer get buffer-free 
        out-buffer get buffer-free
    ] bind ;

M: win32-stream stream-format ( string style stream -- )
    win32-stream-this [ drop do-write ] bind ;

M: win32-stream win32-stream-handle ( stream -- handle )
    win32-stream-this [ handle get ] bind ;

M: win32-stream set-timeout ( timeout stream -- )
    win32-stream-this [ timeout set ] bind ;

M: win32-stream expire ( stream -- )
    win32-stream-this [
        timeout get [ millis cutoff get > [ handle get CancelIo ] when ] when
    ] bind ;

USE: inspector
M: win32-stream with-nested-stream ( quot style stream -- )
    win32-stream-this [ drop stream get swap with-stream* ] bind ;

C: win32-stream ( handle -- stream )
    swap [
        dup f GetFileSize dup -1 = not [
            file-size set
        ] [ drop f file-size set ] if
        handle set 
        4096 <buffer> in-buffer set 
        4096 <buffer> out-buffer set
        0 fileptr set 
        dup stream set
    ] make-hash over set-win32-stream-this ;

: <win32-file-reader> ( path -- stream )
    t f win32-open-file <win32-stream> <line-reader> ;

: <win32-file-writer> ( path -- stream )
    f t win32-open-file <win32-stream> ;

