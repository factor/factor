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

IN: kernel-internals

USE: alien
USE: errors
USE: kernel
USE: kernel-internals
USE: math
USE: namespaces
USE: strings
USE: win32-api

SYMBOL: buf-size
SYMBOL: buf-ptr
SYMBOL: buf-fill
SYMBOL: buf-pos

: imalloc ( size -- address )
    "int" "libc" "malloc" [ "int" ] alien-invoke ;

: ifree ( address -- )
    "void" "libc" "free" [ "int" ] alien-invoke ;

: irealloc ( address size -- address )
    "int" "libc" "realloc" [ "int" "int" ] alien-invoke ;

: <buffer> ( size -- buffer )
    #! Allocates and returns a new buffer.
    <namespace> [
        dup buf-size set
        imalloc buf-ptr set
        0 buf-fill set
        0 buf-pos set
    ] extend ;

: buffer-free ( buffer -- )
    #! Frees the C memory associated with the buffer.
    [ buf-ptr get ifree ] bind ;

: buffer-contents ( buffer -- string )
    #! Returns the current contents of the buffer.
    [
        buf-ptr get buf-pos get + 
        buf-fill get buf-pos get - 
        memory>string 
    ] bind ;

: buffer-first-n ( count buffer -- string )
    [
        buf-fill get buf-pos get - min
        buf-ptr get buf-pos get +
        swap memory>string
    ] bind ;

: buffer-reset ( count buffer -- )
    #! Reset the position to 0 and the fill pointer to count.
    [ 0 buf-pos set buf-fill set ] bind ;

: buffer-consume ( count buffer -- )
    #! Consume count characters from the beginning of the buffer.
    [
        buf-pos [ + buf-fill get min ] change 
        buf-pos get buf-fill get = [ 
            0 buf-pos set 0 buf-fill set 
        ] when
    ] bind ;

: buffer-length ( buffer -- length )
    #! Returns the amount of unconsumed input in the buffer.
    [ buf-fill get buf-pos get - 0 max ] bind ;

: buffer-size ( buffer -- size )
    [ buf-size get ] bind ;

: buffer-capacity ( buffer -- int )
    #! Returns the amount of data that may be added to the buffer.
    [ buf-size get buf-fill get - ] bind ;

: buffer-set ( string buffer -- )
    #! Set the contents of a buffer to string.
    [ 
        dup buf-ptr get string>memory
        str-length namespace buffer-reset
    ] bind ;

: buffer-append ( string buffer -- )
    #! Appends a string to the end of the buffer. If it doesn't fit,
    #! an error is thrown.
    [ 
        dup buf-size get buf-fill get - swap str-length < [
            "Buffer overflow" throw
        ] when
        dup buf-ptr get buf-fill get + string>memory
        buf-fill [ swap str-length + ] change
    ] bind ;

: buffer-extend ( length buffer -- )
    #! Increases the size of the buffer by length.
    [
        buf-size get + dup buf-ptr get swap irealloc 
        buf-ptr set buf-size set
    ] bind ;

: buffer-fill ( count buffer -- )
    #! Increases the fill pointer by count.
    [ buf-fill [ + ] change ] bind ;

: buffer-ptr ( buffer -- pointer )
    #! Returns the memory address of the buffer area.
    [ buf-ptr get ] bind ;

: buffer-pos ( buffer -- int )
    [ buf-ptr get buf-pos get + ] bind ;
