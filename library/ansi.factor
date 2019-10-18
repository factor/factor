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

IN: ansi
USE: combinators
USE: lists
USE: kernel
USE: format
USE: namespaces
USE: stack
USE: stdio
USE: streams
USE: strings

! Some words for outputting ANSI colors.

: black   0 ; inline
: red     1 ; inline
: green   2 ; inline
: yellow  3 ; inline
: blue    4 ; inline
: magenta 5 ; inline
: cyan    6 ; inline
: white   7 ; inline

: clear ( -- code )
    #! Clear screen
    "\e[2J\e[H" ; inline

: reset ( -- code )
    #! Reset ANSI color codes.
    "\e[0m" ; inline

: bold ( -- code )
    #! Switch on boldface.
    "\e[1m" ; inline

: fg ( color -- code )
    #! Set foreground color.
    "\e[3" swap "m" cat3 ; inline

: bg ( color -- code )
    #! Set foreground color.
    "\e[4" swap "m" cat3 ; inline

: ansi-attrs ( style -- )
    "bold"    over assoc [ bold % ] when
    "ansi-fg" over assoc [ fg % ] when*
    "ansi-bg" over assoc [ bg % ] when*
    drop ;

: ansi-attr-string ( string style -- string )
    <% ansi-attrs % reset % %> ;

: <ansi-stream> ( stream -- stream )
    #! Wraps the given stream in an ANSI stream. ANSI streams
    #! support the following character attributes:
    #! bold    - if not f, text is boldface.
    #! ansi-fg - foreground color
    #! ansi-bg - background color
    <extend-stream> [
        ( string style -- )
        [ ansi-attr-string write ] "fwrite-attr" set
    ] extend ;
