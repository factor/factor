! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs fry kernel sequences namespaces
compiler.cfg compiler.cfg.instructions compiler.cfg.rpo
compiler.cfg.utilities ;
IN: compiler.cfg.phi-elimination

: insert-copy ( predecessor input output -- )
    '[ _ _ swap ##copy ] add-instructions ;

: eliminate-phi ( ##phi -- )
    [ inputs>> ] [ dst>> ] bi '[ _ insert-copy ] assoc-each ;

: eliminate-phi-step ( bb -- )
    H{ } clone added-instructions set
    [ instructions>> [ dup ##phi? [ eliminate-phi f ] [ drop t ] if ] filter-here ]
    [ insert-basic-blocks ]
    bi ;

: eliminate-phis ( cfg -- cfg' )
    dup [ eliminate-phi-step ] each-basic-block
    cfg-changed ;