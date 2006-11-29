USING: splay-trees namespaces sequences kernel namespaces words ;

<splay-tree> "foo" set
all-words [ dup word-name "foo" get set-splay ] each
all-words [ word-name "foo" get get-splay drop ] each
