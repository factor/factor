USING: kernel sequences assocs hashtables parser vocabs words namespaces
vocabs.loader debugger ;
IN: qualified

: define-qualified ( vocab-name prefix-name -- )
    [ load-vocab vocab-words ] [ CHAR: : suffix ] bi*
    [ -rot >r append r> ] curry assoc-map
    use get push ;

: QUALIFIED:
    #! Syntax: QUALIFIED: vocab
    scan dup define-qualified ; parsing

: QUALIFIED-WITH:
    #! Syntax: QUALIFIED-WITH: vocab prefix
    scan scan define-qualified ; parsing

: expect=> scan "=>" assert= ;

: partial-vocab ( words name -- assoc )
    dupd [
        lookup [ "No such word: " swap append throw ] unless*
    ] curry map zip ;

: partial-vocab-ignoring ( words name -- assoc )
    [ vocab-words keys diff ] keep partial-vocab ;

: EXCLUDE:
    #! Syntax: EXCLUDE: vocab => words ... ;
    scan expect=>
    ";" parse-tokens swap partial-vocab-ignoring use get push ; parsing

: FROM:
    #! Syntax: FROM: vocab => words... ;
    scan expect=>
    ";" parse-tokens swap partial-vocab use get push ; parsing

: RENAME:
    #! Syntax: RENAME: word vocab => newname
    scan scan lookup [ "No such word" throw ] unless*
    expect=>
    scan associate use get push ; parsing

