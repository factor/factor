! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: fry vectors sequences assocs math accessors kernel
combinators quotations namespaces stack-checker.state
stack-checker.backend stack-checker.errors stack-checker.visitor
;
IN: stack-checker.branches

: balanced? ( pairs -- ? )
    [ second ] filter [ first2 length - ] map all-equal? ;

: unify-inputs ( max-d-in d-in meta-d -- new-meta-d )
    dup [ [ - f <repetition> ] dip append ] [ 3drop f ] if ;

: pad-with-f ( seq -- newseq )
    dup [ length ] map supremum '[ , f pad-left ] map ;

: phi-inputs ( max-d-in pairs -- newseq )
    dup empty? [ nip ] [
        swap '[ , _ first2 unify-inputs ] map
        pad-with-f
        flip
    ] if ;

: unify-values ( values -- phi-out )
    sift dup empty? [ drop <value> ] [
        [ known ] map dup all-eq?
        [ first make-known ] [ drop <value> ] if
    ] if ;

: phi-outputs ( phi-in -- stack )
    [ unify-values ] map ;

SYMBOL: quotations

: unify-branches ( ins stacks -- in phi-in phi-out )
    zip dup empty? [ drop 0 { } { } ] [
        [ keys supremum ] [ ] [ balanced? ] tri
        [ dupd phi-inputs dup phi-outputs ]
        [ quotations get unbalanced-branches-error ]
        if
    ] if ;

: branch-variable ( seq symbol -- seq )
    '[ , _ at ] map ;

: active-variable ( seq symbol -- seq )
    [ [ terminated? over at [ drop f ] when ] map ] dip
    branch-variable ;

: datastack-phi ( seq -- phi-in phi-out )
    [ d-in branch-variable ] [ meta-d active-variable ] bi
    unify-branches
    [ d-in set ] [ ] [ dup >vector meta-d set ] tri* ;

: retainstack-phi ( seq -- phi-in phi-out )
    [ length 0 <repetition> ] [ meta-r active-variable ] bi
    unify-branches
    [ drop ] [ ] [ dup >vector meta-r set ] tri* ;

: compute-phi-function ( seq -- )
    [ quotation active-variable sift quotations set ]
    [ [ datastack-phi ] [ retainstack-phi ] bi #phi, ]
    [ [ terminated? swap at ] all? terminated? set ]
    tri ;

: infer-branch ( literal -- namespace )
    [
        copy-inference
        nest-visitor
        [ value>> quotation set ] [ infer-literal-quot ] bi
    ] H{ } make-assoc ; inline

: infer-branches ( branches -- input children data )
    [ pop-d ] dip
    [ infer-branch ] map
    [ stack-visitor branch-variable ] keep ;

: (infer-if) ( branches -- )
    infer-branches [ first2 #if, ] dip compute-phi-function ;

: infer-if ( -- )
    2 consume-d
    dup [ known [ curried? ] [ composed? ] bi or ] contains? [
        output-d
        [ rot [ drop call ] [ nip call ] if ]
        recursive-state get infer-quot
    ] [
        [ #drop, ] [ [ literal ] map (infer-if) ] bi
    ] if ;

: infer-dispatch ( -- )
    pop-literal nip [ <literal> ] map
    infer-branches [ #dispatch, ] dip compute-phi-function ;
