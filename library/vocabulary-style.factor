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

IN: words
USE: combinators
USE: lists
USE: kernel
USE: namespaces
USE: stack
USE: styles

: get-vocab-style ( vocab -- style )
    #! Each vocab has a style object specifying how words are
    #! to be printed.
    "vocabularies" 2rlist get-style ;

: set-vocab-style ( style vocab -- )
    swap default-style append swap
    [ "styles" "vocabularies" ] object-path set* ;

: word-style ( word -- style )
    word-vocabulary dup [
        get-vocab-style
    ] [
        drop default-style
    ] ifte ;

: init-vocab-styles ( -- )
    "styles" get [ <namespace> "vocabularies" set ] bind

    [
        [ "ansi-fg" | "1" ]
        [ "fg" | [ 255 0 0 ] ]
    ] "builtins" set-vocab-style
    [
        [ "ansi-fg" | "1" ]
        [ "fg" | [ 255 0 0 ] ]
    ] "kernel" set-vocab-style
    [
        [ "ansi-fg" | "1" ]
        [ "fg" | [ 255 0 0 ] ]
    ] "combinators" set-vocab-style
    [
        [ "ansi-fg" | "2" ]
        [ "fg" | [ 0 255 0 ] ]
    ] "stack" set-vocab-style
    [
        [ "ansi-fg" | "3" ]
        [ "fg" | [ 255 255 0 ] ]
    ] "arithmetic" set-vocab-style
    [
        [ "ansi-fg" | "3" ]
        [ "fg" | [ 255 255 0 ] ]
    ] "math" set-vocab-style
    [
        [ "ansi-fg" | "4" ]
        [ "fg" | [ 0 0 255 ] ]
    ] "namespaces" set-vocab-style
    [
        [ "ansi-fg" | "5" ]
        [ "fg" | [ 255 0 255 ] ]
    ] "lists" set-vocab-style ;
