! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: fry accessors quotations kernel sequences namespaces
assocs words arrays vectors hints combinators compiler.tree
stack-checker
stack-checker.state
stack-checker.errors
stack-checker.visitor
stack-checker.backend
stack-checker.recursive-state ;
IN: compiler.tree.builder

: with-tree-builder ( quot -- nodes )
    '[ V{ } clone stack-visitor set @ ]
    with-infer nip ; inline

: build-tree ( quot -- nodes )
    #! Not safe to call from inference transforms.
    [ f initial-recursive-state infer-quot ] with-tree-builder ;

: build-tree-with ( in-stack quot -- nodes out-stack )
    #! Not safe to call from inference transforms.
    [
        [ >vector \ meta-d set ]
        [ f initial-recursive-state infer-quot ] bi*
    ] with-tree-builder
    unclip-last in-d>> ;

: build-sub-tree ( #call quot -- nodes )
    [ [ out-d>> ] [ in-d>> ] bi ] dip build-tree-with
    over ends-with-terminate?
    [ drop swap [ f swap #push ] map append ]
    [ rot #copy suffix ]
    if ;

: (build-tree-from-word) ( word -- )
    dup initial-recursive-state recursive-state set
    dup [ "inline" word-prop ] [ "recursive" word-prop ] bi and
    [ 1quotation ] [ specialized-def ] if
    infer-quot-here ;

: check-cannot-infer ( word -- )
    dup "cannot-infer" word-prop [ cannot-infer-effect ] [ drop ] if ;

TUPLE: do-not-compile word ;

: check-no-compile ( word -- )
    dup "no-compile" word-prop [ do-not-compile inference-warning ] [ drop ] if ;

: build-tree-from-word ( word -- nodes )
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

: contains-breakpoints? ( word -- ? )
    def>> [ word? ] filter [ "break?" word-prop ] any? ;
