! Copyright (C) 2007, 2009 Daniel Ehrenberg, Bruno Deferrari,
! Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs hashtables kernel namespaces sequences
sets strings vocabs sorting accessors arrays compiler.units ;
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

: (add-use) ( vocab -- )
    vocab-words use get push ;

: add-use ( vocab -- )
    load-vocab (add-use) ;

: set-use ( seq -- )
    [ vocab-words ] V{ } map-as sift use set ;

: add-qualified ( vocab prefix -- )
    [ load-vocab vocab-words ] [ CHAR: : suffix ] bi*
    [ swap [ prepend ] dip ] curry assoc-map
    use get push ;

: words-named-in ( words assoc -- assoc' )
    [ dupd at [ no-word-error ] unless* ] curry { } map>assoc ;

: partial-vocab-including ( words vocab -- assoc )
    load-vocab vocab-words words-named-in ;

: add-words-from ( words vocab -- )
    partial-vocab-including use get push ;

: partial-vocab-excluding ( words vocab -- assoc )
    load-vocab vocab-words [ nip ] [ words-named-in ] 2bi assoc-diff ;

: add-words-excluding ( words vocab -- )
    partial-vocab-excluding use get push ;

: add-renamed-word ( word vocab new-name -- )
    [ load-vocab vocab-words dupd at [ ] [ no-word-error ] ?if ] dip
    associate use get push ;

: check-vocab-string ( name -- name )
    dup string? [ "Vocabulary name must be a string" throw ] unless ;

: set-in ( name -- )
    check-vocab-string dup in set create-vocab (add-use) ;

: check-forward ( str word -- word/f )
    dup forward-reference? [
        drop
        use get
        [ at ] with map sift
        [ forward-reference? not ] find-last nip
    ] [
        nip
    ] if ;

: search ( str -- word/f )
    dup use get assoc-stack check-forward ;