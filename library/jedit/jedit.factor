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

IN: jedit
USE: arithmetic
USE: combinators
USE: errors
USE: kernel
USE: namespaces
USE: stack
USE: strings
USE: words

! Doesn't exist in native Factor.
: local-jedit-line/file "Not supported" throw ;

: jedit-local? ( -- ? )
    java? [ global [ "jedit" get ] bind ] [ f ] ifte ;

: jedit-line/file ( line dir file -- )
    jedit-local? [
        local-jedit-line/file
    ] [
        remote-jedit-line/file
    ] ifte ;

: resource-path ( -- path )
    global [ "resource-path" get ] bind [ "." ] unless* ;

: word-file ( path -- dir file )
    dup "resource:/" str-head? dup [
        nip resource-path swap
    ] [
        swap ( f file )
    ] ifte ;

: word-line/file ( word -- line dir file )
    #! Note that line numbers here start from 1
    "line" over word-property swap
    "file" swap word-property word-file ;

: jedit ( word -- )
    intern word-line/file jedit-line/file ;
