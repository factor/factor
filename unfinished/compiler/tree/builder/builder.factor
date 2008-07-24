! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: fry accessors quotations kernel sequences namespaces assocs
words generic generic.standard generic.standard.engines arrays
kernel.private combinators vectors stack-checker
stack-checker.state stack-checker.visitor stack-checker.errors
stack-checker.backend compiler.tree ;
IN: compiler.tree.builder

: with-tree-builder ( quot -- dataflow )
    [ node-list new stack-visitor set ] prepose
    with-infer first>> ; inline

GENERIC# build-tree-with 1 ( quot stack -- dataflow )

M: callable build-tree-with
    #! Not safe to call from inference transforms.
    [
        >vector meta-d set
        f infer-quot
    ] with-tree-builder nip ;

: build-tree ( quot -- dataflow ) f build-tree-with ;

: (make-specializer) ( class picker -- quot )
    swap "predicate" word-prop append ;

: make-specializer ( classes -- quot )
    dup length <reversed>
    [ (picker) 2array ] 2map
    [ drop object eq? not ] assoc-filter
    dup empty? [ drop [ t ] ] [
        [ (make-specializer) ] { } assoc>map
        unclip [ swap [ f ] \ if 3array append [ ] like ] reduce
    ] if ;

: specializer-cases ( quot word -- default alist )
    dup [ array? ] all? [ 1array ] unless [
        [ make-specializer ] keep
        '[ , declare ] pick append
    ] { } map>assoc ;

: method-declaration ( method -- quot )
    dup "method-generic" word-prop dispatch# object <array>
    swap "method-class" word-prop prefix ;

: specialize-method ( quot method -- quot' )
    method-declaration '[ , declare ] prepend ;

: specialize-quot ( quot specializer -- quot' )
    specializer-cases alist>quot ;

: standard-method? ( method -- ? )
    dup method-body? [
        "method-generic" word-prop standard-generic?
    ] [ drop f ] if ;

: specialized-def ( word -- quot )
    dup def>> swap {
        { [ dup standard-method? ] [ specialize-method ] }
        {
            [ dup "specializer" word-prop ]
            [ "specializer" word-prop specialize-quot ]
        }
        [ drop ]
    } cond ;

: build-tree-from-word ( word -- effect dataflow )
    [
        [
            dup +cannot-infer+ word-prop [ cannot-infer-effect ] when
            dup "no-compile" word-prop [ cannot-infer-effect ] when
            dup specialized-def over dup 2array 1array infer-quot
            finish-word
        ] maybe-cannot-infer
    ] with-tree-builder ;

: specialized-length ( specializer -- n )
    dup [ array? ] all? [ first ] when length ;
