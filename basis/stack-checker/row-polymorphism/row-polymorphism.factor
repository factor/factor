! (c)2010 Joe Groff bsd license
USING: accessors arrays assocs combinators combinators.short-circuit
continuations effects fry kernel locals math math.order namespaces
quotations sequences splitting
stack-checker.backend
stack-checker.errors
stack-checker.state
stack-checker.values
stack-checker.visitor ;
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

: (check-variables) ( vars declared actual -- ? )
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
