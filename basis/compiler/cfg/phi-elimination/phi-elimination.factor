! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors compiler.cfg compiler.cfg.instructions
compiler.cfg.rpo fry kernel sequences ;
IN: compiler.cfg.phi-elimination

: insert-copy ( predecessor input output -- )
    '[ _ _ swap ##copy ] add-instructions ;

: eliminate-phi ( bb ##phi -- )
    [ predecessors>> ] [ [ inputs>> ] [ dst>> ] bi ] bi*
    '[ _ insert-copy ] 2each ;

: eliminate-phi-step ( bb -- )
    dup [
        [ ##phi? ] partition
        [ [ eliminate-phi ] with each ] dip
    ] change-instructions drop ;

: eliminate-phis ( cfg -- cfg' )
    dup [ eliminate-phi-step ] each-basic-block ;