! Copyright (C) 2008 James Cash
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences symbols fry words assocs tools.annotations coroutines ;
IN: advice

SYMBOLS: before after around advised ;

<PRIVATE
: advise ( quot name word loc --  )
    word-prop set-at ;
PRIVATE>
    
: advise-before ( quot name word --  )
    before advise ;
    
: advise-after ( quot name word --  )
    after advise ;

: advise-around ( quot name word --  )
    [ \ coterminate suffix ] 2dip
    around advise ;

: get-advice ( word type -- seq )
    word-prop values ;

: call-before ( word --  )
    before get-advice [ call ] each ;

: call-after ( word --  )
    after get-advice [ call ] each ;

: call-around ( main word --  )
    around get-advice [ cocreate ] map tuck 
    [ [ coresume ] each ] [ call ] [ reverse [ coresume ] each ] tri* ;

: remove-advice ( name word loc --  )
    word-prop delete-at ;

: ad-do-it ( input -- result )
    coyield ;

: advised? ( word -- ? )
    advised word-prop ;
    
: make-advised ( word -- )
    [ dup [ over dup '[ _ call-before _ _ call-around _ call-after ] ] annotate ]
    [ { before after around } [ H{ } clone swap set-word-prop ] with each ] 
    [ t advised set-word-prop ] tri ;
    