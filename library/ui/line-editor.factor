! :folding=indent:collapseFolds=1:

! $Id$
!
! Copyright (C) 2005 Slava Pestov.
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

IN: line-editor
USE: namespaces
USE: strings
USE: kernel
USE: math

SYMBOL: line-text
SYMBOL: caret

: line-clear ( -- )
    #! Call this in the line editor scope.
    0 caret set "" line-text set ;

: <line-editor> ( -- editor )
    <namespace> [ line-clear ] extend ;

: caret-insert ( str offset -- )
    #! Call this in the line editor scope.
    caret get <= [
        str-length caret [ + ] change
    ] [
        drop
    ] ifte ;

: line-insert ( str offset -- )
    #! Call this in the line editor scope.
    2dup caret-insert
    line-text get swap str/
    swapd cat3 line-text set ;

: insert-char ( ch -- )
    #! Call this in the line editor scope.
    ch>str caret get line-insert ;

: caret-remove ( offset length -- )
    #! Call this in the line editor scope.
    2dup + caret get <= [
        nip caret [ swap - ] change
    ] [
        caret get pick pick dupd + between? [
            drop caret set
        ] [
            2drop
        ] ifte
    ] ifte ;

: line-remove ( offset length -- )
    #! Call this in the line editor scope.
    2dup caret-remove
    dupd + line-text get str-tail
    >r line-text get str-head r> cat2
    line-text set ;

: backspace ( -- )
    #! Call this in the line editor scope.
    caret get dup 0 = [ drop ] [ 1 - 1 line-remove ] ifte ;

: left ( -- )
    #! Call this in the line editor scope.
    caret [ 1 - 0 max ] change ;

: right ( -- )
    #! Call this in the line editor scope.
    caret [ 1 + line-text str-length min ] change ;
