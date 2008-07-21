! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: fry kernel sequences assocs accessors namespaces
math.intervals arrays classes.algebra
compiler.tree
compiler.tree.propagation.simple
compiler.tree.propagation.constraints ;
IN: compiler.tree.propagation.branches

! For conditionals, an assoc of child node # --> constraint
GENERIC: child-constraints ( node -- seq )

M: #if child-constraints
    [
        \ f class-not 0 `input class,
        f 0 `input literal,
    ] make-constraints ;

M: #dispatch child-constraints
    dup [
        children>> length [ 0 `input literal, ] each
    ] make-constraints ;

DEFER: (propagate)

: infer-children ( node -- assocs )
    [ children>> ] [ child-constraints ] bi [
        [
            value-classes [ clone ] change
            value-literals [ clone ] change
            value-intervals [ clone ] change
            constraints [ clone ] change
            apply-constraint
            (propagate)
        ] H{ } make-assoc
    ] 2map ;

: merge-classes ( inputs outputs results -- )
    '[
        , null
        [ [ value-class ] bind class-or ] 2reduce
        _ set-value-class
    ] 2each ;

: merge-intervals ( inputs outputs results -- )
    '[
        , [ [ value-interval ] bind ] 2map
        dup first [ interval-union ] reduce
        _ set-value-interval
    ] 2each ;

: merge-literals ( inputs outputs results -- )
    '[
        , [ [ value-literal 2array ] bind ] 2map
        dup all-eq? [ first first2 ] [ drop f f ] if
        _ swap [ set-value-literal ] [ 2drop ] if
    ] 2each ;

: merge-stuff ( inputs outputs results -- )
    [ merge-classes ] [ merge-intervals ] [ merge-literals ] 3tri ;

: merge-children ( results node -- )
    successor>> dup #phi? [
        [ [ phi-in-d>> ] [ out-d>> ] bi rot merge-stuff ]
        [ [ phi-in-r>> ] [ out-r>> ] bi rot merge-stuff ]
        2bi
    ] [ 2drop ] if ;

M: #branch propagate-around
    [ infer-children ] [ merge-children ] [ annotate-node ] tri ;
