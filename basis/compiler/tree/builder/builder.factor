! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: fry accessors quotations kernel sequences namespaces
assocs words arrays vectors hints combinators stack-checker
stack-checker.state stack-checker.visitor stack-checker.errors
stack-checker.backend compiler.tree ;
IN: compiler.tree.builder

: with-tree-builder ( quot -- nodes )
    '[ V{ } clone stack-visitor set @ ]
    with-infer ; inline

: build-tree ( quot -- nodes )
    #! Not safe to call from inference transforms.
    [ f infer-quot ] with-tree-builder nip ;

: build-tree-with ( in-stack quot -- nodes out-stack )
    #! Not safe to call from inference transforms.
    [
        [ >vector meta-d set ] [ f infer-quot ] bi*
    ] with-tree-builder nip
    unclip-last in-d>> ;

: build-sub-tree ( #call quot -- nodes )
    [ [ out-d>> ] [ in-d>> ] bi ] dip build-tree-with
    over ends-with-terminate?
    [ drop swap [ f swap #push ] map append ]
    [ rot #copy suffix ]
    if ;

: (build-tree-from-word) ( word -- )
    dup
    [ "inline" word-prop ]
    [ "recursive" word-prop ] bi and [
        1quotation f infer-quot
    ] [
        [ specialized-def ]
        [ dup 2array 1array ] bi infer-quot
    ] if ;

: check-cannot-infer ( word -- )
    dup "cannot-infer" word-prop [ cannot-infer-effect ] [ drop ] if ;

: check-no-compile ( word -- )
    dup "no-compile" word-prop [ cannot-infer-effect ] [ drop ] if ;

: build-tree-from-word ( word -- effect nodes )
    [
        [
            {
                [ check-cannot-infer ]
                [ check-no-compile ]
                [ (build-tree-from-word) ]
                [ finish-word ]
            } cleave
        ] maybe-cannot-infer
    ] with-tree-builder ;
