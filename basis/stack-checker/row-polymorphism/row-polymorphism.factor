! Copyright (C) 2010 Joe Groff
! See https://factorcode.org/license.txt for BSD license
USING: accessors arrays assocs combinators
combinators.short-circuit effects fry kernel locals math
math.order namespaces sequences stack-checker.errors
stack-checker.state stack-checker.values ;
IN: stack-checker.row-polymorphism

: with-inner-d ( quot -- inner-d )
    inner-d-index get
    [ meta-d length inner-d-index set call ] dip
    inner-d-index get [ min inner-d-index set ] keep ; inline

:: (effect-here) ( inner-d old-meta-d-length old-input-count -- effect )
    old-meta-d-length inner-d - input-count get old-input-count - +
    terminated? get [ [ 0 ] [ meta-d length inner-d - ] if [ "x" <array> ] bi@ ] keep
    <terminated-effect> ; inline

: with-effect-here ( quot -- effect )
    meta-d length input-count get
    [ with-inner-d ] 2dip (effect-here) ; inline

: (diff-variable) ( diff variable vars -- diff' )
    [ key? ] [ '[ _ _ at - ] ] [ '[ _ _ set-at 0 ] ] 2tri if ;

: (check-variable) ( actual-count declared-count variable vars -- diff ? )
    [ - ] 2dip dupd '[ _ _ (diff-variable) t ] [ dup 0 <= ] if ;

: adjust-variable ( diff var vars -- )
    pick 0 >= [ at+ ] [ 3drop ] if ; inline

:: check-variable ( vars declared actual slot var-slot -- diff ok? var )
    actual declared [ slot call length ] bi@ declared var-slot call
    [ vars (check-variable) ] keep ; inline

:: unify-variables ( in-diff in-ok? in-var out-diff out-ok? out-var vars -- ? )
    { [ in-ok? ] [ out-ok? ] [ in-diff out-diff = ] } 0&& dup [
        in-var  [ in-diff  swap vars adjust-variable ] when*
        out-var [ out-diff swap vars adjust-variable ] when*
    ] when ;

! A bit of a hack. If the declared effect is one-sided monomorphic and the actual effect is a
! shallow subtype of the root effect, adjust it here
:: (balance-actual-depth) ( declared actual -- depth/f )
    {
        { [ {
            [ declared in-var>> ]
            [ declared out-var>> not ]
            [ actual out>> length declared out>> length < ]
        } 0&& ] [ declared out>> length actual out>> length - ] }
        { [ {
            [ declared in-var>> not ]
            [ declared out-var>> ]
            [ actual in>> length declared in>> length < ]
        } 0&& ] [ declared in>> length actual in>> length - ] }
        [ f ]
    } cond ;

: (balance-by) ( effect n -- effect' )
    "x" <array> swap
    [ in>> append ]
    [ out>> append ]
    [ nip terminated?>> ] 2tri <terminated-effect> ;

: balance-actual ( declared actual -- declared actual' )
    2dup (balance-actual-depth) [ (balance-by) ] when* ;

: (check-variables) ( vars declared actual -- ? )
    balance-actual
    [ [ in>>  ] [ in-var>>  ] check-variable ]
    [ [ out>> ] [ out-var>> ] check-variable ]
    [ 2drop ] 3tri unify-variables ;

: check-variables ( vars declared actual -- ? )
    dup terminated?>> [ 3drop t ] [ (check-variables) ] if ;

: combinator-branches-effects ( branches -- quots declareds actuals )
    [ [ known>callable ] { } map-as ]
    [ [ effect>> ] { } map-as ]
    [ [ actual>> ] { } map-as ] tri ;

: combinator-unbalanced-branches-error ( known -- * )
    [ word>> ] [ branches>> <reversed> combinator-branches-effects ] bi
    unbalanced-branches-error ;

: check-declared-effect ( known effect -- )
    [ >>actual ] keep
    2dup [ [ variables>> ] [ effect>> ] bi ] dip check-variables
    [ 2drop ] [ drop combinator-unbalanced-branches-error ] if ;
