! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: fry locals accessors quotations kernel sequences namespaces
assocs words arrays vectors hints combinators continuations
effects compiler.tree
stack-checker
stack-checker.state
stack-checker.errors
stack-checker.visitor
stack-checker.backend
stack-checker.recursive-state ;
IN: compiler.tree.builder

<PRIVATE

GENERIC: (build-tree) ( quot -- )

M: callable (build-tree) infer-quot-here ;

: check-no-compile ( word -- )
    dup "no-compile" word-prop [ do-not-compile ] [ drop ] if ;

: check-effect ( word effect -- )
    swap required-stack-effect 2dup effect<=
    [ 2drop ] [ effect-error ] if ;

: inline-recursive? ( word -- ? )
    [ "inline" word-prop ] [ "recursive" word-prop ] bi and ;

: word-body ( word -- quot )
    dup inline-recursive? [ 1quotation ] [ specialized-def ] if ;

M: word (build-tree)
    [ check-no-compile ]
    [ word-body infer-quot-here ]
    [ current-effect check-effect ] tri ;

: build-tree-with ( in-stack word/quot -- nodes )
    [
        <recursive-state> recursive-state set
        V{ } clone stack-visitor set
        [ [ >vector \ meta-d set ] [ length d-in set ] bi ]
        [ (build-tree) ]
        bi*
    ] with-infer nip ;

PRIVATE>

: build-tree ( word/quot -- nodes )
    [ f ] dip build-tree-with ;

:: build-sub-tree ( #call word/quot -- nodes/f )
    #! We don't want methods on mixins to have a declaration for that mixin.
    #! This slows down compiler.tree.propagation.inlining since then every
    #! inlined usage of a method has an inline-dependency on the mixin, and
    #! not the more specific type at the call site.
    f specialize-method? [
        [
            #call in-d>> word/quot build-tree-with unclip-last in-d>> :> in-d
            {
                { [ dup not ] [ ] }
                { [ dup ends-with-terminate? ] [ #call out-d>> [ f swap #push ] map append ] }
                [ in-d #call out-d>> #copy suffix ]
            } cond
        ] [ dup inference-error? [ drop f ] [ rethrow ] if ] recover
    ] with-variable ;

: contains-breakpoints? ( word -- ? )
    def>> [ word? ] filter [ "break?" word-prop ] any? ;
