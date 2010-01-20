! Copyright (C) 2009, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs classes.algebra compiler.units definitions graphs
grouping kernel namespaces sequences words fry
stack-checker.dependencies ;
IN: compiler.crossref

SYMBOL: compiled-crossref

compiled-crossref [ H{ } clone ] initialize

SYMBOL: compiled-generic-crossref

compiled-generic-crossref [ H{ } clone ] initialize

: compiled-usage ( word -- assoc )
    compiled-crossref get at ;

: (compiled-usages) ( word -- assoc )
    #! If the word is not flushable anymore, we have to recompile
    #! all words which flushable away a call (presumably when the
    #! word was still flushable). If the word is flushable, we
    #! don't have to recompile words that folded this away.
    [ compiled-usage ]
    [ "flushable" word-prop inlined-dependency flushed-dependency ? ] bi
    '[ nip _ dependency>= ] assoc-filter ;

: compiled-usages ( seq -- assocs )
    [ drop word? ] assoc-filter
    [ [ drop (compiled-usages) ] { } assoc>map ] keep suffix ;

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
    bi ;

: delete-compiled-xref ( word -- )
    [ compiled-unxref ]
    [ compiled-crossref get delete-at ]
    [ compiled-generic-crossref get delete-at ]
    tri ;
