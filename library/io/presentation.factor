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

IN: presentation
USE: hashtables
USE: kernel
USE: lists
USE: namespaces
USE: strings
USE: unparser

: <actions> ( path alist -- alist )
    #! For each element of the alist, change the value to
    #! path " " value
    [ uncons >r over " " r> cat3 cons ] map nip ;

! A style is an alist whose key/value pairs hold
! significance to the 'fwrite-attr' word when applied to a
! stream that supports attributed string output.

: (style) ( name -- style ) "styles" get hash ;
: default-style ( -- style ) "default" (style) ;
: style ( name -- style ) (style) [ default-style ] unless* ;
: set-style ( style name -- ) "styles" get set-hash ;

<namespace> "styles" set

[
    [[ "font" "Monospaced" ]]
] "default" set-style

[
    [[ "bold" t ]]
] default-style append "prompt" set-style

[
    [[ "ansi-fg" "0" ]]
    [[ "ansi-bg" "2" ]]
    [[ "fg" [ 255 0 0 ] ]]
] default-style append "comments" set-style
