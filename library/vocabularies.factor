! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: words
USING: hashtables kernel lists namespaces strings sequences ;

SYMBOL: vocabularies

: word ( -- word ) "last-word" global hash ;
: set-word ( word -- ) "last-word" global set-hash ;

: vocabs ( -- list )
    #! Push a list of vocabularies.
    vocabularies get hash-keys [ lexi ] sort ;

: vocab ( name -- vocab )
    #! Get a vocabulary.
    vocabularies get hash ;

: words ( vocab -- list )
    #! Push a list of all words in a vocabulary.
    #! Filter empty slots.
    vocab dup [ hash-values [ ] subset word-sort ] when ;

: all-words ( -- list )
    vocabs [ words ] map concat ;

: each-word ( quot -- )
    #! Apply a quotation to each word in the image.
    all-words swap each ; inline

: word-subset ( pred -- list | pred: word -- ? )
    #! A list of words matching the predicate.
    all-words swap subset word-sort ; inline

: word-subset-with ( obj pred -- list | pred: obj word -- ? )
    all-words swap subset-with word-sort ; inline

: recrossref ( -- )
    #! Update word cross referencing information.
    global [ <namespace> crossref set ] bind
    [ add-crossref ] each-word ;

: search ( name vocabs -- word )
    [ vocab ?hash ] map-with [ ] find nip ;

: <props> ( name vocab -- plist )
    <namespace> [ "vocabulary" set "name" set ] extend ;

: (create) ( name vocab -- word )
    #! Create an undefined word without adding to a vocabulary.
    <props> <word> [ set-word-props ] keep ;

: reveal ( word -- )
    #! Add a new word to its vocabulary.
    vocabularies get [
        dup word-name over word-vocabulary nest set-hash
    ] bind ;

: create ( name vocab -- word )
    #! Create a new word in a vocabulary. If the vocabulary
    #! already contains the word, the existing instance is
    #! returned.
    2dup vocab ?hash [
        nip
        dup f "documentation" set-word-prop
        dup f "stack-effect" set-word-prop
    ] [
        (create) dup reveal
    ] ?ifte ;

: constructor-word ( string vocab -- word )
    >r "<" swap ">" append3 r> create ;

: forget ( word -- )
    #! Remove a word definition.
    dup uncrossref
    dup word-vocabulary vocab [ word-name off ] bind ;

: interned? ( word -- ? )
    #! Test if the word is a member of its vocabulary.
    dup word-name over word-vocabulary vocab ?hash eq? ;

: init-search-path ( -- )
    "scratchpad" "in" set
    [
        "compiler" "errors" "gadgets" "generic"
        "hashtables" "help" "inference" "inspector" "interpreter"
        "jedit" "kernel" "listener" "lists" "math" "matrices"
        "memory" "namespaces" "parser" "prettyprint"
        "sequences" "io" "strings" "styles" "syntax" "test"
        "threads" "vectors" "words" "scratchpad"
    ] "use" set ;
