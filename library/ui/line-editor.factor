! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: line-editor
USING: kernel math namespaces sequences strings vectors ;

SYMBOL: line-text
SYMBOL: caret

! History stuff
SYMBOL: history
SYMBOL: history-index

: history-length ( -- n )
    #! Call this in the line editor scope.
    history get length ;

: reset-history ( -- )
    #! Call this in the line editor scope. After user input,
    #! resets the history index.
    history-length history-index set ;

: commit-history ( -- )
    #! Call this in the line editor scope. Adds the currently
    #! entered text to the history.
    line-text get dup empty? [
        drop
    ] [
        history-index get history get set-nth
        reset-history
    ] if ;

: set-line-text ( text -- )
    #! Call this in the line editor scope.
    dup line-text set length caret set ;

: goto-history ( n -- )
    #! Call this in the line editor scope.
    dup history-index set
    history get nth set-line-text ;

: history-prev ( -- )
    #! Call this in the line editor scope.
    history-index get dup 0 = [
        drop
    ] [
        dup history-length = [ commit-history ] when
        1 - goto-history
    ] if ;

: history-next ( -- )
    #! Call this in the line editor scope.
    history-index get dup 1+ history-length >= [
        drop
    ] [
        1+ goto-history
    ] if ;

: line-clear ( -- )
    #! Call this in the line editor scope.
    0 caret set
    "" line-text set ;

: <line-editor> ( -- editor )
    [
        line-clear
        { } clone history set
        0 history-index set
    ] make-hash ;

: caret-insert ( str offset -- )
    #! Call this in the line editor scope.
    caret get <= [
        length caret [ + ] change
    ] [
        drop
    ] if ;

: line-insert ( str offset -- )
    #! Call this in the line editor scope.
    reset-history
    2dup caret-insert
    line-text get [ head ] 2keep tail
    swapd append3 line-text set ;

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
        ] if
    ] if ;

: line-remove ( offset length -- )
    #! Call this in the line editor scope.
    reset-history
    2dup caret-remove
    dupd + line-text get tail
    >r line-text get head r> append
    line-text set ;

: backspace ( -- )
    #! Call this in the line editor scope.
    caret get dup 0 = [ drop ] [ 1- 1 line-remove ] if ;

: left ( -- )
    #! Call this in the line editor scope.
    caret [ 1- 0 max ] change ;

: right ( -- )
    #! Call this in the line editor scope.
    caret [ 1+ line-text get length min ] change ;

: home ( -- )
    #! Call this in the line editor scope.
    0 caret set ;

: end ( -- )
    #! Call this in the line editor scope.
    line-text get length caret set ;
