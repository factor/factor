IN: gadgets-text
USING: arrays kernel math sequences strings ;

GENERIC: prev-elt ( loc document elt -- loc )
GENERIC: next-elt ( loc document elt -- loc )

TUPLE: char-elt ;

: (prev-char) ( loc document quot -- loc )
    -rot {
        { [ over { 0 0 } = ] [ drop ] }
        { [ over second zero? ] [ >r first 1- r> line-end ] }
        { [ t ] [ pick call ] }
    } cond nip ; inline

: (next-char) ( loc document quot -- loc )
    -rot {
        { [ 2dup doc-end = ] [ drop ] }
        { [ 2dup line-end? ] [ drop first 1+ 0 2array ] }
        { [ t ] [ pick call ] }
    } cond nip ; inline

M: char-elt prev-elt
    drop [ drop -1 +col ] (prev-char) ;

M: char-elt next-elt
    drop [ drop 1 +col ] (next-char) ;

TUPLE: word-elt ;

: (word-elt) ( loc document quot -- loc )
    pick >r
    >r >r first2 swap r> doc-line r> call
    r> =col ; inline

: ((word-elt)) [ ?nth blank? ] 2keep ;

: (prev-word) ( col str -- col )
    >r 1- r> ((word-elt))
    [ blank? xor ] find-last-with* drop 1+ ;

M: word-elt prev-elt
    drop [ [ (prev-word) ] (word-elt) ] (prev-char) ;

: (next-word) ( col str -- col )
    ((word-elt))
    [ [ blank? xor ] find-with* drop ] keep
    over -1 = [ nip length ] [ drop ] if ;

M: word-elt next-elt
    drop [ [ (next-word) ] (word-elt) ] (next-char) ;

TUPLE: one-line-elt ;

M: one-line-elt prev-elt
    2drop first 0 2array ;
M: one-line-elt next-elt
    drop >r first dup r> doc-line length 2array ;

TUPLE: line-elt ;

M: line-elt prev-elt 2drop -1 +line ;
M: line-elt next-elt 2drop 1 +line ;

TUPLE: doc-elt ;

M: doc-elt prev-elt 3drop { 0 0 } ;
M: doc-elt next-elt drop nip doc-end ;
