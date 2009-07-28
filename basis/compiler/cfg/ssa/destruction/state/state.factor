! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces sets kernel assocs ;
IN: compiler.cfg.ssa.destruction.state

SYMBOLS: processed-names waiting used-by-another renaming-sets ;

: init-coalescing ( -- )
    H{ } clone renaming-sets set
    H{ } clone processed-names set
    H{ } clone waiting set
    V{ } clone used-by-another set ;

: processed-name ( vreg -- ) processed-names get conjoin ;

: waiting-for ( bb -- assoc ) waiting get [ drop H{ } clone ] cache ;
