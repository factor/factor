! Copyright (C) 2009, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays assocs classes.algebra compiler.units definitions
graphs grouping kernel namespaces sequences words fry
stack-checker.dependencies ;
IN: compiler.crossref

SYMBOL: compiled-crossref

compiled-crossref [ H{ } clone ] initialize

SYMBOL: compiled-generic-crossref

compiled-generic-crossref [ H{ } clone ] initialize

: compiled-usage ( word -- assoc )
    compiled-crossref get at ;

: (compiled-usages) ( word -- assoc )
    compiled-usage [ nip inlined-dependency dependency>= ] assoc-filter ;

: compiled-usages ( assoc -- assocs )
    [ drop word? ] assoc-filter
    [ [ drop (compiled-usages) ] { } assoc>map ] keep suffix ;

: dependencies-satisfied? ( word cache -- ? )
    [ "dependency-checks" word-prop ] dip
    '[ _ [ satisfied? ] cache ] all? ;

: outdated-conditional-usages ( assoc -- assocs )
    H{ } clone '[
        drop
        compiled-usage
        [ nip conditional-dependency dependency>= ] assoc-filter
        [ drop _ dependencies-satisfied? not ] assoc-filter
    ] { } assoc>map ;

: compiled-generic-usage ( word -- assoc )
    compiled-generic-crossref get at ;

: (compiled-xref) ( word dependencies word-prop variable -- )
    [ [ concat ] dip set-word-prop ] [ get add-vertex* ] bi-curry* 2bi ;

: compiled-xref ( word dependencies generic-dependencies -- )
    [ [ drop crossref? ] { } assoc-filter-as ] bi@
    [ "compiled-uses" compiled-crossref (compiled-xref) ]
    [ "compiled-generic-uses" compiled-generic-crossref (compiled-xref) ]
    bi-curry* bi ;

: (compiled-unxref) ( word word-prop variable -- )
    [ '[ dup _ word-prop 2 <groups> _ get remove-vertex* ] ]
    [ drop '[ _ remove-word-prop ] ]
    2bi bi ;

: compiled-unxref ( word -- )
    [ "compiled-uses" compiled-crossref (compiled-unxref) ]
    [ "compiled-generic-uses" compiled-generic-crossref (compiled-unxref) ]
    [ f "dependency-checks" set-word-prop ]
    tri ;

: delete-compiled-xref ( word -- )
    [ compiled-unxref ]
    [ compiled-crossref get delete-at ]
    [ compiled-generic-crossref get delete-at ]
    tri ;

: save-conditional-dependencies ( word deps -- )
    >array f like "dependency-checks" set-word-prop ;
