! Copyright (C) 2009, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays assocs classes.algebra compiler.units definitions
graphs grouping kernel namespaces sequences words fry
stack-checker.dependencies combinators sets ;
IN: compiler.crossref

SYMBOL: compiled-crossref

compiled-crossref [ H{ } clone ] initialize

SYMBOL: generic-call-site-crossref

generic-call-site-crossref [ H{ } clone ] initialize

: effect-dependencies-of ( word -- assoc )
    compiled-crossref get at ;

: definition-dependencies-of ( word -- assoc )
    effect-dependencies-of [ nip definition-dependency dependency>= ] assoc-filter ;

: conditional-dependencies-of ( word -- assoc )
    effect-dependencies-of [ nip conditional-dependency dependency>= ] assoc-filter ;

: outdated-definition-usages ( set -- assocs )
    members [ word? ] filter [ definition-dependencies-of ] map ;

: outdated-effect-usages ( set -- assocs )
    members [ word? ] filter [ effect-dependencies-of ] map ;

: dependencies-satisfied? ( word cache -- ? )
    [ "dependency-checks" word-prop ] dip
    '[ _ [ satisfied? ] cache ] all? ;

: outdated-conditional-usages ( set -- assocs )
    members H{ } clone '[
        conditional-dependencies-of
        [ drop _ dependencies-satisfied? not ] assoc-filter
    ] map ;

: generic-call-sites-of ( word -- assoc )
    generic-call-site-crossref get at ;

: only-xref ( assoc -- assoc' )
    [ drop crossref? ] { } assoc-filter-as ;

: set-generic-call-sites ( word alist -- )
    concat f like "generic-call-sites" set-word-prop ;

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
    compiled-crossref generic-call-site-crossref
    [ get add-vertex* ] bi-curry@ bi-curry* bi ;

: compiled-xref ( word dependencies generic-dependencies -- )
    [ only-xref ] bi@
    [ nip set-generic-call-sites ]
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

: generic-call-sites ( word -- alist )
    "generic-call-sites" word-prop 2 <groups> ;

: compiled-unxref ( word -- )
    {
        [ dup load-dependencies compiled-crossref (compiled-unxref) ]
        [ dup generic-call-sites generic-call-site-crossref (compiled-unxref) ]
        [ "effect-dependencies" remove-word-prop ]
        [ "conditional-dependencies" remove-word-prop ]
        [ "definition-dependencies" remove-word-prop ]
        [ "generic-call-sites" remove-word-prop ]
    } cleave ;

: delete-compiled-xref ( word -- )
    [ compiled-unxref ]
    [ compiled-crossref get delete-at ]
    [ generic-call-site-crossref get delete-at ]
    tri ;

: set-dependency-checks ( word deps -- )
    members f like "dependency-checks" set-word-prop ;
