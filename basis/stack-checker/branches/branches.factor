! Copyright (C) 2008, 2010 Slava Pestov, Joe Groff.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays effects fry vectors sequences assocs math math.order accessors kernel
combinators quotations namespaces grouping locals stack-checker.state
stack-checker.backend stack-checker.errors stack-checker.visitor
stack-checker.values stack-checker.recursive-state ;
FROM: sequences.private => dispatch ;
IN: stack-checker.branches

: balanced? ( pairs -- ? )
    [ second ] filter [ first2 length - ] map all-equal? ;

SYMBOLS: +bottom+ +top+ ;

: unify-inputs ( max-input-count input-count meta-d -- new-meta-d )
    ! Introduced values can be anything, and don't unify with
    ! literals.
    dup [ [ - +top+ <repetition> ] dip append ] [ 3drop f ] if ;

: pad-with-bottom ( seq -- newseq )
    ! Terminated branches are padded with bottom values which
    ! unify with literals.
    dup empty? [
        dup [ length ] [ max ] map-reduce
        '[ _ +bottom+ pad-head ] map
    ] unless ;

: phi-inputs ( max-input-count pairs -- newseq )
    dup empty? [ nip ] [
        swap '[ [ _ ] dip first2 unify-inputs ] map
        pad-with-bottom
    ] if ;

: remove-bottom ( seq -- seq' )
    +bottom+ swap remove ;

: unify-values ( values -- phi-out )
    remove-bottom
    [ <value> ] [
        [ known ] map dup all-eq?
        [ first make-known ] [ drop <value> ] if
    ] if-empty ;

: phi-outputs ( phi-in -- stack )
    flip [ unify-values ] map ;

SYMBOLS: combinator quotations ;

: simple-unbalanced-branches-error ( word quots branches -- * )
    [ length [ ( ..a -- ..b ) ] replicate ]
    [ [ length [ "x" <array> ] bi@ <effect> ] { } assoc>map ] bi
    unbalanced-branches-error ;

: unify-branches ( ins stacks -- in phi-in phi-out )
    zip [ 0 { } { } ] [
        [ keys supremum ] [ ] [ balanced? ] tri
        [ dupd phi-inputs dup phi-outputs ] [
            [ combinator get quotations get ] dip
            simple-unbalanced-branches-error
        ] if
    ] if-empty ;

: branch-variable ( seq symbol -- seq )
    '[ [ _ ] dip at ] map ;

: active-variable ( seq symbol -- seq )
    [ [ terminated? over at [ drop f ] when ] map ] dip
    branch-variable ;

: datastack-phi ( seq -- phi-in phi-out )
    [ input-count branch-variable ]
    [ inner-d-index branch-variable infimum inner-d-index set ]
    [ (meta-d) active-variable ] tri
    unify-branches
    [ input-count set ] [ ] [ dup >vector (meta-d) set ] tri* ;

: terminated-phi ( seq -- terminated )
    terminated? branch-variable ;

: terminate-branches ( seq -- )
    [ terminated? swap at ] all? [ terminate ] when ;

: compute-phi-function ( seq -- )
    [ quotation active-variable sift quotations set ]
    [ [ datastack-phi ] [ terminated-phi ] bi #phi, ]
    [ terminate-branches ]
    tri ;

: copy-inference ( -- )
    (meta-d) [ clone ] change
    literals [ clone ] change
    input-count [ ] change
    inner-d-index [ ] change ;

GENERIC: infer-branch ( literal -- namespace )

M: literal infer-branch
    [
        copy-inference
        nest-visitor
        [ value>> quotation set ] [ infer-literal-quot ] bi
    ] H{ } make-assoc ;

M: declared-effect infer-branch
    known>> infer-branch ;

M: callable infer-branch
    [
        copy-inference
        nest-visitor
        [ quotation set ] [ infer-quot-here ] bi
    ] H{ } make-assoc ;

: infer-branches ( branches -- input children data )
    [ pop-d ] dip
    [ infer-branch ] map
    [ stack-visitor branch-variable ] keep ; inline

: (infer-if) ( branches -- )
    infer-branches
    [ first2 #if, ] dip compute-phi-function ;

GENERIC: curried/composed? ( known -- ? )
M: object curried/composed? drop f ;
M: curried curried/composed? drop t ;
M: composed curried/composed? drop t ;
M: declared-effect curried/composed? known>> curried/composed? ;

: declare-if-effects ( -- )
    H{ } clone V{ } clone
    [ [ \ if ( ..a -- ..b ) ] 2dip 0 declare-effect-d ]
    [ [ \ if ( ..a -- ..b ) ] 2dip 1 declare-effect-d ] 2bi ;

: infer-if ( -- )
    \ if combinator set
    2 literals-available? [
        (infer-if)
    ] [
        drop 2 ensure-d
        declare-if-effects
        2 shorten-d
        dup [ known curried/composed? ] any? [
            output-d
            [ rot [ drop call ] [ nip call ] if ]
            infer-quot-here
        ] [
            [ #drop, ] [ [ literal ] map (infer-if) ] bi
        ] if
    ] if ;

: infer-dispatch ( -- )
    \ dispatch combinator set
    pop-literal nip infer-branches
    [ #dispatch, ] dip compute-phi-function ;
