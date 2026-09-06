! Copyright (C) 2010 Joe Groff
! See https://factorcode.org/license.txt for BSD license
USING: accessors arrays assocs combinators
combinators.short-circuit effects kernel math
math.order namespaces sequences stack-checker.errors
stack-checker.state stack-checker.values ;
IN: stack-checker.row-polymorphism

SYMBOL: effect-scope

: with-inner-d ( quot -- inner-d )
    inner-d-index get
    [ meta-d length inner-d-index set call ] dip
    inner-d-index get [ min inner-d-index set ] keep ; inline

:: (effect-here) ( inner-d old-meta-d-length old-input-count -- effect )
    old-meta-d-length inner-d - input-count get old-input-count - +
    terminated? get [ [ 0 ] [ meta-d length inner-d - ] if [ "x" <array> ] bi@ ] keep
    <terminated-effect> ; inline

: with-effect-here ( quot -- effect )
    effect-scope get [
        V{ } clone effect-scope set
        meta-d length input-count get
        [ with-inner-d ] 2dip (effect-here)
    ] dip effect-scope set ; inline

<PRIVATE

TUPLE: row-group < identity-tuple ;
TUPLE: row-variable group height ;

: get-row ( name vars -- row )
    [ drop row-group new 0 row-variable boa ] cache ;

:: raise-row ( row amount vars -- ? )
    amount 0 <= [ t ] [
        row group>> :> group
        f vars get-row group>> group eq? [ f ] [
            vars values [| other |
                other group>> group eq? [
                    other [ amount + ] change-height drop
                ] when
            ] each t
        ] if
    ] if ;

:: bound-row ( row minimum vars -- ? )
    row minimum row height>> - vars raise-row ;

:: join-rows ( left right vars -- )
    left group>> :> group
    right group>> :> old-group
    vars values [| row |
        row group>> old-group eq? [ row group >>group drop ] when
    ] each ;

:: equate-rows ( left right difference vars -- ? )
    difference left height>> right height>> - - :> adjustment
    left group>> right group>> eq? [ adjustment zero? ] [
        adjustment 0 >= [
            left adjustment vars raise-row
        ] [
            right adjustment neg vars raise-row
        ] if dup [ left right vars join-rows ] when
    ] if ;

:: (check-variables) ( vars declared actual -- ? )
    declared in-var>> vars get-row :> left
    declared out-var>> vars get-row :> right
    actual in>> length declared in>> length - :> inputs
    actual out>> length declared out>> length - :> outputs
    ! Each effect may be lifted by an untouched stack prefix. Related rows
    ! must grow together so earlier quotation constraints remain satisfied.
    left inputs vars bound-row
    right outputs vars bound-row and [
        left right inputs outputs - vars equate-rows
    ] [ f ] if ;

PRIVATE>

: check-variables ( vars declared actual -- ? )
    dup terminated?>> [ 3drop t ] [
        over terminated?>> [ 3drop f ] [ (check-variables) ] if
    ] if ;

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
