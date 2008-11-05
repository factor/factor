! Copyright (C) 2008 James Cash
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences symbols fry words assocs tools.annotations ;
IN: advice

SYMBOLS: before after around ;

: get-advice ( word type -- seq )
    word-prop values ;

: call-before ( word --  )
    before get-advice [ call ] each ;

: call-after ( word --  )
    after get-advice [ call ] each ;
    
: advise-before ( quot name word --  )
    before word-prop set-at ;
    
: advise-after ( quot name word --  )
    after word-prop set-at ;

: remove-advice ( name word loc --  )
    word-prop delete-at ;
    
: make-advised ( word -- )
    [ dup [ over '[ _ call-before @  _ call-after ] ] annotate ]
    [ { before after around } [ H{ } clone swap set-word-prop ] with each ] bi ;
    