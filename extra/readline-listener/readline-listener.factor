! Copyright (C) 2011 Erik Charlebois.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.data fry io io.encodings.utf8 kernel
listener namespaces readline sequences threads vocabs
command-line ;
QUALIFIED: readline.ffi
IN: readline-listener

<PRIVATE
SYMBOL: completions

: prefixed-words ( prefix -- words )
    '[ name>> _ head? ] all-words swap filter [ name>> ] map ;

: clear-completions ( -- )
    f completions tset ;

: get-completions ( prefix -- completions )
    completions tget dup [ nip ] [ drop
        prefixed-words dup completions tset
    ] if ;

TUPLE: readline-reader { prompt initial: f } ;
M: readline-reader stream-readln
    flush [ prompt>> dup [ " " append ] [ ] if readline ]
    keep f >>prompt drop ;

M: readline-reader prompt.
    >>prompt drop ;
PRIVATE>

: readline-listener ( -- )
    [
      swap get-completions ?nth
      [ clear-completions f ] unless*
    ] set-completion
    readline-reader new [ listener ] with-input-stream* ;

MAIN: readline-listener
