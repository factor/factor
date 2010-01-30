! Copyright (C) 2009, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays assocs classes.algebra compiler.units definitions
graphs grouping kernel namespaces sequences words fry
stack-checker.dependencies combinators ;
IN: compiler.crossref

SYMBOL: compiled-crossref

compiled-crossref [ H{ } clone ] initialize

SYMBOL: compiled-generic-crossref

compiled-generic-crossref [ H{ } clone ] initialize

: effect-dependencies-of ( word -- assoc )
    compiled-crossref get at ;

: definition-dependencies-of ( word -- assoc )
    effect-dependencies-of [ nip definition-dependency dependency>= ] assoc-filter ;

: conditional-dependencies-of ( word -- assoc )
    effect-dependencies-of [ nip conditional-dependency dependency>= ] assoc-filter ;

: compiled-usages ( assoc -- assocs )
    [ drop word? ] assoc-filter
    [ [ drop definition-dependencies-of ] { } assoc>map ] keep suffix ;

: dependencies-satisfied? ( word cache -- ? )
    [ "dependency-checks" word-prop ] dip
    '[ _ [ satisfied? ] cache ] all? ;

: outdated-conditional-usages ( assoc -- assocs )
    H{ } clone '[
        drop
        conditional-dependencies-of
        [ drop _ dependencies-satisfied? not ] assoc-filter
    ] { } assoc>map ;

: compiled-generic-usage ( word -- assoc )
    compiled-generic-crossref get at ;

: only-xref ( assoc -- assoc' )
    [ drop crossref? ] { } assoc-filter-as ;

: set-compiled-generic-uses ( word alist -- )
    concat f like "compiled-generic-uses" set-word-prop ;

: split-dependencies ( assoc -- effect-deps cond-deps def-deps )
    [ nip effect-dependency eq? ] assoc-partition
    [ nip conditional-dependency eq? ] assoc-partition ;

: (store-dependencies) ( word assoc prop -- )
    [ keys f like ] dip set-word-prop ;

: store-dependencies ( word assoc -- )
    split-dependencies
    "effect-dependencies" "conditional-dependencies" "definition-dependencies"
    [ (store-dependencies) ] tri-curry@ tri-curry* tri ;

: (compiled-xref) ( word dependencies generic-dependencies -- )
    compiled-crossref compiled-generic-crossref
    [ get add-vertex* ] bi-curry@ bi-curry* bi ;

: compiled-xref ( word dependencies generic-dependencies -- )
    [ only-xref ] bi@
    [ nip set-compiled-generic-uses ]
    [ drop store-dependencies ]
    [ (compiled-xref) ]
    3tri ;

: set-at-each ( keys assoc value -- )
    '[ _ [ _ ] 2dip set-at ] each ;

: join-dependencies ( effect-deps cond-deps def-deps -- assoc )
    H{ } clone [
        [ effect-dependency set-at-each ]
        [ conditional-dependency set-at-each ]
        [ definition-dependency set-at-each ] tri-curry tri*
    ] keep ;

: load-dependencies ( word -- assoc )
    [ "effect-dependencies" word-prop ]
    [ "conditional-dependencies" word-prop ]
    [ "definition-dependencies" word-prop ] tri
    join-dependencies ;

: (compiled-unxref) ( word dependencies variable -- )
    get remove-vertex* ;

: compiled-generic-uses ( word -- alist )
    "compiled-generic-uses" word-prop 2 <groups> ;

: compiled-unxref ( word -- )
    {
        [ dup load-dependencies compiled-crossref (compiled-unxref) ]
        [ dup compiled-generic-uses compiled-generic-crossref (compiled-unxref) ]
        [ "effect-dependencies" remove-word-prop ]
        [ "conditional-dependencies" remove-word-prop ]
        [ "definition-dependencies" remove-word-prop ]
        [ "compiled-generic-uses" remove-word-prop ]
    } cleave ;

: delete-compiled-xref ( word -- )
    [ compiled-unxref ]
    [ compiled-crossref get delete-at ]
    [ compiled-generic-crossref get delete-at ]
    tri ;

: set-dependency-checks ( word deps -- )
    keys f like "dependency-checks" set-word-prop ;
