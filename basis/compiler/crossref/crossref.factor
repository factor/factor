! Copyright (C) 2009, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: assocs combinators compiler.units grouping kernel
namespaces sequences sets stack-checker.dependencies words ;
IN: compiler.crossref

SYMBOL: compiled-crossref

compiled-crossref [ H{ } clone ] initialize

SYMBOL: generic-call-site-crossref

generic-call-site-crossref [ H{ } clone ] initialize

: all-dependencies-of ( word -- assoc )
    compiled-crossref get at ;

: dependencies-of ( word dep-type -- assoc )
    [ all-dependencies-of ] dip '[ _ dependency>= ] filter-values ;

: outdated-definition-usages ( set -- assocs )
    filter-word-defs [ +definition+ dependencies-of ] map ;

: outdated-effect-usages ( set -- assocs )
    filter-word-defs [ all-dependencies-of ] map ;

: dependencies-satisfied? ( word cache -- ? )
    [ "dependency-checks" word-prop ] dip
    '[ _ [ satisfied? ] cache ] all? ;

: outdated-conditional-usages ( set -- assocs )
    members H{ } clone '[
        +conditional+ dependencies-of
        [ _ dependencies-satisfied? ] reject-keys
    ] map ;

: generic-call-sites-of ( word -- assoc )
    generic-call-site-crossref get at ;

: only-xref ( assoc -- assoc' )
    [ drop crossref? ] { } assoc-filter-as ;

: set-generic-call-sites ( word alist -- )
    concat f like "generic-call-sites" set-word-prop ;

: store-dependencies-of-type ( word assoc symbol prop-name -- )
    [ rot '[ _ = ] filter-values keys ] dip set-word-prop ;

: store-dependencies ( word assoc -- )
    keys "dependencies" set-word-prop ;

: add-xref ( word dependencies crossref -- )
    rot '[
        swap _ [ drop H{ } clone ] cache _ swap set-at
    ] assoc-each ;

: remove-xref ( word dependencies crossref -- )
    '[ _ at delete-at ] with each ;

: (compiled-xref) ( word dependencies generic-dependencies -- )
    compiled-crossref generic-call-site-crossref
    [ get add-xref ] bi-curry@ bi-curry* bi ;

: compiled-xref ( word dependencies generic-dependencies -- )
    [ only-xref ] bi@
    [ nip set-generic-call-sites ]
    [ drop store-dependencies ]
    [ (compiled-xref) ]
    3tri ;

: load-dependencies ( word -- seq )
    "dependencies" word-prop ;

: (compiled-unxref) ( word dependencies variable -- )
    get remove-xref ;

: generic-call-sites ( word -- alist )
    "generic-call-sites" word-prop 2 group ;

: compiled-unxref ( word -- )
    {
        [ dup load-dependencies compiled-crossref (compiled-unxref) ]
        [ dup generic-call-sites generic-call-site-crossref (compiled-unxref) ]
        [ "dependencies" remove-word-prop ]
        [ "generic-call-sites" remove-word-prop ]
    } cleave ;

: delete-compiled-xref ( word -- )
    [ compiled-unxref ]
    [ compiled-crossref get delete-at ]
    [ generic-call-site-crossref get delete-at ]
    tri ;

: set-dependency-checks ( word deps -- )
    members f like "dependency-checks" set-word-prop ;
