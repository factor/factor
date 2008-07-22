! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: fry kernel sequences assocs accessors namespaces
math.intervals arrays classes.algebra
compiler.tree
compiler.tree.def-use
compiler.tree.propagation.info
compiler.tree.propagation.nodes
compiler.tree.propagation.simple
compiler.tree.propagation.constraints ;
IN: compiler.tree.propagation.branches

! For conditionals, an assoc of child node # --> constraint
GENERIC: child-constraints ( node -- seq )

M: #if child-constraints
    in-d>> first
    [ <true-constraint> ] [ <false-constraint> ] bi
    2array ;

M: #dispatch child-constraints drop f ;

: infer-children ( node -- assocs )
    [ children>> ] [ child-constraints ] bi [
        [
            value-infos [ clone ] change
            constraints [ clone ] change
            assume
            (propagate)
        ] H{ } make-assoc
    ] 2map ;

: (merge-value-infos) ( inputs results -- infos )
    '[ , [ [ value-info ] bind ] 2map value-infos-union ] map ;

: merge-value-infos ( results inputs outputs -- )
    [ swap (merge-value-infos) ] dip set-value-infos ;

: propagate-branch-phi ( results #phi -- )
    [ nip node-defs-values [ introduce-value ] each ]
    [ [ phi-in-d>> ] [ out-d>> ] bi merge-value-infos ]
    [ [ phi-in-r>> ] [ out-r>> ] bi merge-value-infos ]
    2tri ;

: merge-children ( results node -- )
    successor>> propagate-branch-phi ;

M: #branch propagate-around
    [ infer-children ] [ merge-children ] [ annotate-node ] tri ;
