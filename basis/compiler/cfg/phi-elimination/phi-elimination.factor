! Copyright (C) 2009 Slava Pestov, Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs fry kernel sequences namespaces
compiler.cfg compiler.cfg.instructions compiler.cfg.rpo
compiler.cfg.utilities compiler.cfg.hats make
locals ;
IN: compiler.cfg.phi-elimination

: insert-copy ( predecessor input output -- )
    '[ _ _ swap ##copy ] add-instructions ;

: eliminate-phi ( ##phi -- ##copy )
    i
    [ [ inputs>> ] dip '[ _ insert-copy ] assoc-each ]
    [ [ dst>> ] dip \ ##copy new-insn ]
    2bi ;

: eliminate-phi-step ( bb -- )
    H{ } clone added-instructions set
    [ instructions>> [ dup ##phi? [ eliminate-phi ] when ] change-each ]
    [ insert-basic-blocks ]
    bi ;

: eliminate-phis ( cfg -- cfg' )
    dup [ eliminate-phi-step ] each-basic-block
    cfg-changed ;
