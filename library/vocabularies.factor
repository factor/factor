! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: words USING: hashtables kernel lists namespaces strings ;

SYMBOL: vocabularies

: word ( -- word ) global [ "last-word" get ] bind ;
: set-word ( word -- ) global [ "last-word" set ] bind ;

: vocabs ( -- list )
    #! Push a list of vocabularies.
    vocabularies get hash-keys [ string> ] sort ;

: vocab ( name -- vocab )
    #! Get a vocabulary.
    vocabularies get hash ;

: words ( vocab -- list )
    #! Push a list of all words in a vocabulary.
    #! Filter empty slots.
    vocab dup [ hash-values [ ] subset word-sort ] when ;

: all-words ( -- list )
    [ vocabs [ words append, ] each ] make-list ;

: each-word ( quot -- )
    #! Apply a quotation to each word in the image.
    all-words swap each ; inline

: word-subset ( pred -- list | pred: word -- ? )
    #! A list of words matching the predicate.
    all-words swap subset ; inline

: word-subset-with ( obj pred -- list | pred: obj word -- ? )
    all-words swap subset-with ; inline

: recrossref ( -- )
    #! Update word cross referencing information.
    [ f "usages" set-word-prop ] each-word
    [ add-crossref ] each-word ;

: (search) ( name vocab -- word )
    vocab dup [ hash ] [ 2drop f ] ifte ;

: search ( name list -- word )
    #! Search for a word in a list of vocabularies.
    dup [
        2dup car (search) [ nip ] [ cdr search ] ?ifte
    ] [
        2drop f
    ] ifte ;

: <props> ( name vocab -- plist )
    "vocabulary" swons swap "name" swons 2list alist>hash ;

: (create) ( name vocab -- word )
    #! Create an undefined word without adding to a vocabulary.
    <props> <word> [ set-word-props ] keep ;

: reveal ( word -- )
    #! Add a new word to its vocabulary.
    vocabularies get [
        dup word-vocabulary nest [
            dup word-name set
        ] bind
    ] bind ;

: create ( name vocab -- word )
    #! Create a new word in a vocabulary. If the vocabulary
    #! already contains the word, the existing instance is
    #! returned.
    2dup (search) [
        nip
        dup f "documentation" set-word-prop
        dup f "stack-effect" set-word-prop
    ] [
        (create) dup reveal
    ] ?ifte ;

: forget ( word -- )
    #! Remove a word definition.
    dup word-vocabulary vocab [ word-name off ] bind ;

: init-search-path ( -- )
    ! For files
    "scratchpad" "file-in" set
    [ "syntax" "scratchpad" ] "file-use" set
    ! For interactive
    "scratchpad" "in" set
    [
        "compiler" "debugger" "errors" "files" "generic"
        "hashtables" "inference" "interpreter" "jedit" "kernel"
        "listener" "lists" "math" "memory" "namespaces" "parser"
        "prettyprint" "processes" "profiler" "sequences"
        "streams" "stdio" "strings" "syntax" "test" "threads"
        "unparser" "vectors" "words" "scratchpad"
    ] "use" set ;
