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
USE: vectors

SYMBOL: line-text
SYMBOL: caret

! History stuff
SYMBOL: history
SYMBOL: history-index

: history-length ( -- n )
    #! Call this in the line editor scope.
    history get vector-length ;

: reset-history ( -- )
    #! Call this in the line editor scope. After user input,
    #! resets the history index.
    history-length history-index set ;

: commit-history ( -- )
    #! Call this in the line editor scope. Adds the currently
    #! entered text to the history.
    line-text get dup "" = [
        drop
    ] [
        history-index get history get set-vector-nth
        reset-history
    ] ifte ;

: set-line-text ( text -- )
    #! Call this in the line editor scope.
    dup line-text set string-length caret set ;

: goto-history ( n -- )
    #! Call this in the line editor scope.
    dup history-index set
    history get vector-nth set-line-text ;

: history-prev ( -- )
    #! Call this in the line editor scope.
    history-index get dup 0 = [
        drop
    ] [
        dup history-length = [ commit-history ] when
        1 - goto-history
    ] ifte ;

: history-next ( -- )
    #! Call this in the line editor scope.
    history-index get dup 1 + history-length >= [
        drop
    ] [
        1 + goto-history
    ] ifte ;

: line-clear ( -- )
    #! Call this in the line editor scope.
    0 caret set
    "" line-text set ;

: <line-editor> ( -- editor )
    <namespace> [
        line-clear
        100 <vector> history set
        0 history-index set
    ] extend ;

: caret-insert ( str offset -- )
    #! Call this in the line editor scope.
    caret get <= [
        string-length caret [ + ] change
    ] [
        drop
    ] ifte ;

: line-insert ( str offset -- )
    #! Call this in the line editor scope.
    reset-history
    2dup caret-insert
    line-text get swap string/
    swapd cat3 line-text set ;

: insert-char ( ch -- )
    #! Call this in the line editor scope.
    ch>string caret get line-insert ;

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
    reset-history
    2dup caret-remove
    dupd + line-text get string-tail
    >r line-text get string-head r> cat2
    line-text set ;

: backspace ( -- )
    #! Call this in the line editor scope.
    caret get dup 0 = [ drop ] [ 1 - 1 line-remove ] ifte ;

: left ( -- )
    #! Call this in the line editor scope.
    caret [ 1 - 0 max ] change ;

: right ( -- )
    #! Call this in the line editor scope.
    caret [ 1 + line-text get string-length min ] change ;
