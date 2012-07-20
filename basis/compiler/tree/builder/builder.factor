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

: inline-recursive? ( word -- ? )
    [ "inline" word-prop ] [ "recursive" word-prop ] bi and ;

: word-body ( word -- quot )
    dup inline-recursive? [ 1quotation ] [ specialized-def ] if ;

M: word (build-tree)
    [ check-no-compile ]
    [ word-body infer-quot-here ]
    [ required-stack-effect check-effect ] tri ;

: build-tree-with ( in-stack word/quot -- nodes )
    [
        <recursive-state> recursive-state set
        V{ } clone stack-visitor set
        [ [ >vector (meta-d) set ] [ length input-count set ] bi ]
        [ (build-tree) ]
        bi*
    ] with-infer nip ;

PRIVATE>

: build-tree ( word/quot -- nodes )
    [ f ] dip build-tree-with ;

:: build-sub-tree ( in-d out-d word/quot -- nodes/f )
    [
        in-d word/quot build-tree-with unclip-last in-d>> :> in-d'
        {
            { [ dup not ] [ ] }
            { [ dup ends-with-terminate? ] [ out-d [ f swap <#push> ] map append ] }
            [ in-d' out-d [ [ length ] bi@ assert= ] [ <#copy> suffix ] 2bi ]
        } cond
    ] [ dup inference-error? [ drop f ] [ rethrow ] if ] recover ;
