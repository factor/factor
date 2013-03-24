! Copyright (C) 2009, 2010 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: words kernel locals accessors compiler.tree.propagation.info
sequences kernel.private assocs fry parser math quotations
effects arrays definitions compiler.units namespaces
compiler.tree.debugger generalizations stack-checker ;
IN: specialized

: in-compilation-unit? ( -- ? )
    changed-definitions get >boolean ;

: define-temp-in-unit ( quot effect -- word )
    in-compilation-unit?
    [ [ define-temp ] with-nested-compilation-unit ]
    [ [ define-temp ] with-compilation-unit ]
    if ;

: final-info-quot ( word -- quot )
    [ stack-effect in>> length '[ _ ndrop ] ]
    [ def>> [ final-info ] with-scope >quotation ] bi
    compose ;

ERROR: bad-outputs word quot ;

: define-outputs ( word quot -- )
    2dup [ stack-effect ] [ infer ] bi* effect<=
    [ "outputs" set-word-prop ] [ bad-outputs ] if ;

: record-final-info ( word -- )
    dup final-info-quot define-outputs ;

:: lookup-specialized ( #call word n -- special-word/f )
    #call in-d>> n tail* >array [ value-info class>> ] map
    dup [ object = ] all? [ drop f ] [
        word "specialized-defs" word-prop [
            [ declare ] curry word def>> compose
            word stack-effect define-temp-in-unit
            dup record-final-info
            1quotation
        ] cache
    ] if ;

: specialized-quot ( word n -- quot )
    '[ _ _ lookup-specialized ] ;

: make-specialized ( word n -- )
    [ drop H{ } clone "specialized-defs" set-word-prop ]
    [ dupd specialized-quot "custom-inlining" set-word-prop ] 2bi ;

SYNTAX: specialized
    last-word dup stack-effect in>> length make-specialized ;

PREDICATE: specialized-word < word
   "specialized-defs" word-prop >boolean ;

