! Copyright (C) 2008 James Cash
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences fry words assocs linked-assocs tools.annotations
coroutines lexer parser quotations arrays namespaces continuations
summary ;
IN: advice

SYMBOLS: before after around advised in-advice? ;

: advised? ( word -- ? )
    advised word-prop ;

DEFER: make-advised

<PRIVATE
: init-around-co ( quot -- coroutine )
    \ coreset suffix cocreate ;
PRIVATE>

: advise ( quot name word loc --  )
    dup around eq? [ [ init-around-co ] 3dip ] when
    over advised? [ over make-advised ] unless
    word-prop set-at ;
    
: advise-before ( quot name word --  ) before advise ;
    
: advise-after ( quot name word --  ) after advise ;

: advise-around ( quot name word --  ) around advise ;

: get-advice ( word type -- seq )
    word-prop values ;

: call-before ( word --  )
    before get-advice [ call ] each ;

: call-after ( word --  )
    after get-advice [ call ] each ;

: call-around ( main word --  )
    t in-advice? [
        around get-advice tuck 
        [ [ coresume ] each ] [ call ] [ <reversed> [ coresume ] each ] tri*
    ] with-variable ;

: remove-advice ( name word loc --  )
    word-prop delete-at ;

ERROR: ad-do-it-error ;

M: ad-do-it-error summary
    drop "ad-do-it should only be called inside 'around' advice" ;

: ad-do-it ( input -- result )
    in-advice? get [ ad-do-it-error ] unless coyield ;
    
: make-advised ( word -- )
    [ dup '[ [ _ ] dip over dup '[ _ call-before _ _ call-around _ call-after ] ] annotate ]
    [ { before after around } [ <linked-hash> swap set-word-prop ] with each ] 
    [ t advised set-word-prop ] tri ;

: unadvise ( word --  )
    [ reset ] [ { before after around advised } [ f swap set-word-prop ] with each ] bi ;

SYNTAX: ADVISE: ! word adname location => word adname quot loc
    scan-word scan scan-word parse-definition swap [ spin ] dip advise ;
    
SYNTAX: UNADVISE:    
    scan-word parsed \ unadvise parsed ;
