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

IN: win32-console

USE: lists
USE: vectors
USE: math
USE: kernel
USE: namespaces
USE: stdio
USE: streams
USE: presentation
USE: generic
USE: parser
USE: compiler
USE: win32-api
USE: win32-stream

TRAITS: win32-console-stream
SYMBOL: handle

: reset ( -- )
  handle get 7 SetConsoleTextAttribute drop ;

: ansi>win32 ( ansi-attr -- win32-attr )
    #! Converts an ANSI color (0-based) to a combination of
    #! _RED, _BLUE, and _GREEN bit flags.
    { 0 4 2 6 1 5 3 7 } vector-nth ;

: set-bold ( attr ? -- attr )
    #! Set or unset the bold bit (bit 3).
    [ 8 bitor ] [ 8 bitnot bitand ] ifte ;

: set-fg ( attr n -- attr )
    #! Set the foreground field (bits 0..2).
    swap 7 bitnot bitand bitor ;

: set-bg ( attr n -- attr )
    #! Set the background field (bits 4..6).
    4 shift swap 112 bitnot bitand bitor ;

: char-attrs ( style -- attrs )
    #! Converts a style into a win32 text attribute bitfield.
    7 ! Default style is white FG, black BG, no extra bits
    "bold"    pick assoc [ set-bold ] when*
    "ansi-fg" pick assoc [ str>number ansi>win32 set-fg ] when*
    "ansi-bg" pick assoc [ str>number ansi>win32 set-bg ] when*
    nip ;

: set-attrs ( style -- )
    char-attrs handle get swap SetConsoleTextAttribute drop ;

M: win32-console-stream fwrite-attr ( string style stream -- )
    [
        [ default-style ] unless* set-attrs
        delegate get fwrite
        reset
    ] bind ;

C: win32-console-stream ( stream -- stream )
    [ -11 GetStdHandle handle set delegate set ] extend ;

global [ [ <win32-console-stream> ] smart-term-hook set ] bind

