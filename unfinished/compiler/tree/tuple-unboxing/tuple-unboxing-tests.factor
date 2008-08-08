IN: compiler.tree.tuple-unboxing.tests
USING: tools.test compiler.tree.tuple-unboxing
compiler.tree compiler.tree.builder compiler.tree.normalization
compiler.tree.propagation compiler.tree.cleanup
compiler.tree.escape-analysis compiler.tree.tuple-unboxing
compiler.tree.def-use kernel accessors sequences math ;

\ unbox-tuples must-infer

: test-unboxing ( quot -- )
    #! Just make sure it doesn't throw errors; compute def use
    #! for kicks.
    build-tree
    normalize
    propagate
    cleanup
    escape-analysis
    unbox-tuples
    compute-def-use
    drop ;

TUPLE: cons { car read-only } { cdr read-only } ;

TUPLE: empty-tuple ;

{
    [ empty-tuple boa drop ]
    [ cons boa [ car>> ] [ cdr>> ] bi ]
    [ [ 1 cons boa ] [ 2 cons boa ] if car>> ]
    [ dup cons boa 10 [ nip dup cons boa ] each-integer car>> ]
} [ [ ] swap [ test-unboxing ] curry unit-test ] each
