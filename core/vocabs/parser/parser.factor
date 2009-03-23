! Copyright (C) 2007, 2009 Daniel Ehrenberg, Bruno Deferrari,
! Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs hashtables kernel namespaces sequences
sets strings vocabs sorting accessors arrays ;
IN: vocabs.parser

ERROR: no-word-error name ;

: word-restarts ( name possibilities -- restarts )
    natural-sort
    [ [ vocabulary>> "Use the " " vocabulary" surround ] keep ] { } map>assoc
    swap "Defer word in current vocabulary" swap 2array
    suffix ;

: <no-word-error> ( name possibilities -- error restarts )
    [ drop \ no-word-error boa ] [ word-restarts ] 2bi ;

SYMBOL: use
SYMBOL: in

: (use+) ( vocab -- )
    vocab-words use get push ;

: use+ ( vocab -- )
    load-vocab (use+) ;

: add-use ( seq -- ) [ use+ ] each ;

: set-use ( seq -- )
    [ vocab-words ] V{ } map-as sift use set ;

: add-qualified ( vocab prefix -- )
    [ load-vocab vocab-words ] [ CHAR: : suffix ] bi*
    [ swap [ prepend ] dip ] curry assoc-map
    use get push ;

: partial-vocab ( words vocab -- assoc )
    load-vocab vocab-words
    [ dupd at [ no-word-error ] unless* ] curry { } map>assoc ;

: add-words-from ( words vocab -- )
    partial-vocab use get push ;

: partial-vocab-excluding ( words vocab -- assoc )
    load-vocab [ vocab-words keys swap diff ] keep partial-vocab ;

: add-words-excluding ( words vocab -- )
    partial-vocab-excluding use get push ;

: add-renamed-word ( word vocab new-name -- )
    [ load-vocab vocab-words dupd at [ ] [ no-word-error ] ?if ] dip
    associate use get push ;

: check-vocab-string ( name -- name )
    dup string? [ "Vocabulary name must be a string" throw ] unless ;

: set-in ( name -- )
    check-vocab-string dup in set create-vocab (use+) ;