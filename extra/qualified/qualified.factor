USING: kernel sequences assocs parser vocabs namespaces
vocabs.loader ;
IN: qualified

: define-qualified ( vocab-name -- )
    dup require
    dup vocab-words swap CHAR: : add
    [ -rot >r append r> ] curry assoc-map
    use get push ;


: QUALIFIED:
    scan define-qualified ; parsing
