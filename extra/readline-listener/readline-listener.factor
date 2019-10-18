! Copyright (C) 2011 Erik Charlebois.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs colors.constants combinators fry io kernel
listener readline sequences splitting threads tools.completion
unicode.data vocabs vocabs.hierarchy ;
IN: readline-listener

<PRIVATE

SYMBOL: completions

TUPLE: readline-reader { prompt initial: f } ;
INSTANCE: readline-reader input-stream

M: readline-reader stream-readln
    flush
    [ dup [ " " append ] when readline f ] change-prompt
    drop ;

M: readline-reader prompt.
    >>prompt drop ;

: clear-completions ( -- )
    f completions tset ;

: prefixed ( prefix seq -- seq' )
    swap '[ _ head? ] filter ;

: prefixed-words ( prefix -- words )
    all-words [ name>> ] map! prefixed ;

: prefixed-vocabs ( prefix -- vocabs )
    all-disk-vocabs-recursive filter-vocabs [ name>> ] map! prefixed ;

: prefixed-vocab-words ( prefix vocab-name -- words )
    vocab-words [ name>> ] map! prefixed ;

: prefixed-colors ( prefix -- colors )
    named-colors prefixed ;

: prefixed-chars ( prefix -- chars )
    name-map keys prefixed ;

: get-completions ( prefix -- completions )
    completions tget [ nip ] [
        completion-line " \r\n" split {
            { [ dup complete-vocab? ] [ drop prefixed-vocabs ] }
            { [ dup complete-char? ] [ drop prefixed-chars ] }
            { [ dup complete-color? ] [ drop prefixed-colors ] }
            { [ dup complete-vocab-words? ] [ harvest second prefixed-vocab-words ] }
            [ drop prefixed-words ]
        } cond dup completions tset
    ] if* ;

PRIVATE>

: readline-listener ( -- )
    [
        swap get-completions ?nth
        [ clear-completions f ] unless*
    ] set-completion
    readline-reader new [ listener-main ] with-input-stream* ;

MAIN: readline-listener
