! Copyright (C) 2011 Erik Charlebois.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.data fry io io.encodings.utf8 kernel
listener namespaces readline sequences threads vocabs
command-line vocabs.hierarchy sequences.deep locals
splitting math ;
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

: word-names ( -- strs )
    all-words [ name>> ] map! ;

: vocab-names ( -- strs )
    all-vocabs-recursive filter-vocabs [ name>> ] map! ;

: prefixed-words ( prefix -- words )
    '[ _ head? ] word-names swap filter ;

: prefixed-vocabs ( prefix -- words )
    '[ _ head? ] vocab-names swap filter ;

: clear-completions ( -- )
    f completions tset ;

: get-completions ( prefix -- completions )
    completions tget dup [ nip ] [
        drop current-line " " split1 drop
        "USING:" = [
            prefixed-vocabs
        ] [
            prefixed-words
        ] if dup completions tset
    ] if ;
PRIVATE>

: readline-listener ( -- )
    [
        swap get-completions ?nth
        [ clear-completions f ] unless*
    ] set-completion
    readline-reader new [ listener ] with-input-stream* ;

MAIN: readline-listener
