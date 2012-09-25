! Copyright (C) 2011 Erik Charlebois.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs combinators io kernel listener readline
sequences splitting threads tools.completion ;
IN: readline-listener

<PRIVATE

SYMBOL: completions

TUPLE: readline-reader { prompt initial: f } ;
INSTANCE: readline-reader input-stream

M: readline-reader stream-readln
    flush [ prompt>> dup [ " " append ] [ ] if readline ]
    keep f >>prompt drop ;

M: readline-reader prompt.
    >>prompt drop ;

: clear-completions ( -- )
    f completions tset ;

: get-completions ( prefix -- completions )
    completions tget [ nip ] [
        current-line " \r\n" split {
            { [ dup complete-vocab? ] [ drop vocabs-matching ] }
            { [ dup complete-CHAR:? ] [ drop chars-matching ] }
            { [ dup complete-COLOR:? ] [ drop colors-matching ] }
            [ drop words-matching ]
        } cond values dup completions tset
    ] if* ;

PRIVATE>

: readline-listener ( -- )
    [
        swap get-completions ?nth
        [ clear-completions f ] unless*
    ] set-completion
    readline-reader new [ listener ] with-input-stream* ;

MAIN: readline-listener
