! Copyright (C) 2008, 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors combinators compiler.tree continuations effects
hints kernel locals namespaces quotations sequences
stack-checker.backend stack-checker.errors
stack-checker.recursive-state stack-checker.row-polymorphism
stack-checker.state stack-checker.visitor vectors words ;
IN: compiler.tree.builder

<PRIVATE

GENERIC: (build-tree) ( quot -- )

M: callable (build-tree) infer-quot-here ;

: check-no-compile ( word -- )
    dup "no-compile" word-prop [ do-not-compile ] [ drop ] if ;

: word-body ( word -- quot )
    dup inline-recursive? [ 1quotation ] [ specialized-def ] if ;

:: check-word-effect ( word -- )
    word required-stack-effect :> effect
    word inline? effect variable-effect? and effect terminated?>> not and [
        ! An inline word can consume values in its row even when static calls
        ! let us infer its body without knowing its quotation arguments.
        H{ } clone effect current-effect check-variables
        [ ] [ current-effect effect effect-error ] if
    ] [ effect check-effect ] if ;

M: word (build-tree)
    [ check-no-compile ]
    [ word-body infer-quot-here ]
    [ check-word-effect ] tri ;

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
            [ in-d' out-d [ 2length assert= ] [ <#copy> suffix ] 2bi ]
        } cond
    ] [ inference-error? ] ignore-error/f ;
