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

IN: kernel-internals
USING: alien errors generic kernel kernel-internals math namespaces strings
       win32-api ;

TUPLE: buffer size ptr fill pos ;

: imalloc ( size -- address )
    "int" "libc" "malloc" [ "int" ] alien-invoke ;

: ifree ( address -- )
    "void" "libc" "free" [ "int" ] alien-invoke ;

: irealloc ( address size -- address )
    "int" "libc" "realloc" [ "int" "int" ] alien-invoke ;

C: buffer ( size -- buffer )
    2dup set-buffer-size
    swap imalloc swap [ set-buffer-ptr ] keep
    0 swap [ set-buffer-fill ] keep
    0 swap [ set-buffer-pos ] keep ;

: buffer-free ( buffer -- )
    #! Frees the C memory associated with the buffer.
    buffer-ptr ifree ;

: buffer-contents ( buffer -- string )
    #! Returns the current contents of the buffer.
    dup buffer-ptr over buffer-pos +
    over buffer-fill pick buffer-pos -
    memory>string nip ;

: buffer-first-n ( count buffer -- string )
    [ dup buffer-fill swap buffer-pos - min ] keep
    dup buffer-ptr swap buffer-pos + swap memory>string ;

: buffer-reset ( count buffer -- )
    #! Reset the position to 0 and the fill pointer to count.
    [ set-buffer-fill ] keep 0 swap set-buffer-pos ;

: buffer-consume ( count buffer -- )
    #! Consume count characters from the beginning of the buffer.
    [ buffer-pos + ] keep [ buffer-fill min ] keep [ set-buffer-pos ] keep
    dup buffer-pos over buffer-fill = [
        [ 0 swap set-buffer-pos ] keep [ 0 swap set-buffer-fill ] keep
    ] when drop ;

: buffer-length ( buffer -- length )
    #! Returns the amount of unconsumed input in the buffer.
    dup buffer-fill swap buffer-pos - 0 max ;

: buffer-capacity ( buffer -- int )
    #! Returns the amount of data that may be added to the buffer.
    dup buffer-size swap buffer-fill - ;

: buffer-set ( string buffer -- )
    2dup buffer-ptr string>memory >r string-length r> buffer-reset ;

: (check-overflow) ( string buffer -- )
    buffer-capacity swap string-length < [ "Buffer overflow" throw ] when ;

: buffer-append ( string buffer -- )
    2dup (check-overflow)
    [ dup buffer-ptr swap buffer-fill + string>memory ] 2keep
    [ buffer-fill swap string-length + ] keep set-buffer-fill ;

: buffer-append-char ( int buffer -- )
    #! Append a single character to a buffer
    [ dup buffer-ptr swap buffer-fill + <alien> 0 set-alien-1 ] keep
    [ buffer-fill 1 + ] keep set-buffer-fill ;

: buffer-extend ( length buffer -- )
    #! Increases the size of the buffer by length.
    [ buffer-size + dup ] keep [ buffer-ptr swap ] keep >r irealloc r>
    [ set-buffer-ptr ] keep set-buffer-size ;

: buffer-inc-fill ( count buffer -- )
    #! Increases the fill pointer by count.
    [ buffer-fill + ] keep set-buffer-fill ;

: buffer-pos+ptr ( buffer -- int )
    [ buffer-ptr ] keep buffer-pos + ;
