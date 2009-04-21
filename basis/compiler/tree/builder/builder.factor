! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: fry accessors quotations kernel sequences namespaces
assocs words arrays vectors hints combinators continuations
effects compiler.tree
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
    [ f initial-recursive-state infer-quot ] with-tree-builder ;

: build-tree-with ( in-stack quot -- nodes out-stack )
    [
        [
            [ >vector \ meta-d set ]
            [ f initial-recursive-state infer-quot ] bi*
        ] with-tree-builder
        unclip-last in-d>>
    ] [ 3drop f f ] recover ;

: build-sub-tree ( #call quot -- nodes/f )
    [ [ out-d>> ] [ in-d>> ] bi ] dip build-tree-with
    {
        { [ over not ] [ 3drop f ] }
        { [ over ends-with-terminate? ] [ drop swap [ f swap #push ] map append ] }
        [ rot #copy suffix ]
    } cond ;

: check-no-compile ( word -- )
    dup "no-compile" word-prop [ do-not-compile ] [ drop ] if ;

: (build-tree-from-word) ( word -- )
    dup initial-recursive-state recursive-state set
    dup [ "inline" word-prop ] [ "recursive" word-prop ] bi and
    [ 1quotation ] [ specialized-def ] if
    infer-quot-here ;

: check-effect ( word effect -- )
    swap required-stack-effect 2dup effect<=
    [ 2drop ] [ effect-error ] if ;

: finish-word ( word -- )
    current-effect check-effect ;

: build-tree-from-word ( word -- nodes )
    [
        [ check-no-compile ]
        [ (build-tree-from-word) ]
        [ finish-word ]
        tri
    ] with-tree-builder ;

: contains-breakpoints? ( word -- ? )
    def>> [ word? ] filter [ "break?" word-prop ] any? ;
