USING: kernel sequences assocs parser vocabs namespaces ;
IN: qualified

: define-qualified ( vocab-name -- )
    dup vocab-words swap CHAR: : add
    [ -rot >r append r> ] curry assoc-map
    use get push ;


: QUALIFIED:
    scan define-qualified ; parsing
