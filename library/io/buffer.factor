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

IN: buffer

USE: alien
USE: errors
USE: kernel
USE: kernel-internals
USE: math
USE: namespaces
USE: strings
USE: win32-api

: imalloc ( size -- address )
    "int" "libc" "malloc" [ "int" ] alien-invoke ;

: ifree ( address -- )
    "void" "libc" "free" [ "int" ] alien-invoke ;

: <buffer> ( size -- buffer )
    #! Allocates and returns a new buffer.
    <namespace> [
        dup "size" set
        imalloc "buffer" set
        0 "fill" set
        0 "pos" set
    ] extend ;

: buffer-free ( buffer -- )
    #! Frees the C memory associated with the buffer.
    [ "buffer" get ifree ] bind ;

: buffer-contents ( buffer -- string )
    #! Returns the current contents of the buffer.
    [
        "buffer" get "pos" get + 
        "fill" get "pos" get - 
        memory>string 
    ] bind ;

: buffer-reset ( count buffer -- )
    #! Reset the position to 0 and the fill pointer to count.
    [ 0 "pos" set "fill" set ] bind ;

: buffer-consume ( count buffer -- )
    #! Consume count characters from the beginning of the buffer.
    [ "pos" [ + "fill" get min ] change ] bind ;

: buffer-length ( buffer -- length )
    #! Returns the amount of unconsumed input in the buffer.
    [ "fill" get "pos" get - max ] bind ;

: buffer-set ( string buffer -- )
    #! Set the contents of a buffer to string.
    [ 
        dup "buffer" get string>memory
        str-length namespace buffer-reset
    ] bind ;

: buffer-append ( string buffer -- )
    #! Appends a string to the end of the buffer. If it doesn't fit,
    #! an error is thrown.
    [ 
        dup "size" get "fill" get - swap str-length < [
            "Buffer overflow" throw
        ] when
        dup "buffer" get "fill" get + string>memory
        "fill" [ swap str-length + ] change
    ] bind ;

: buffer-fill ( buffer quot -- )
    #! Execute quot with buffer as its argument, passing its result to
    #! buffer-reset.
    swap dup >r swap call r> buffer-reset ; inline

: buffer-ptr ( buffer -- pointer )
    #! Returns the memory address of the buffer area.
    [ "buffer" get ] bind ;

