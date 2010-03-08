! (c)2010 Joe Groff bsd license
USING: accessors arrays assocs combinators combinators.short-circuit
continuations effects fry kernel locals math math.order namespaces
quotations sequences splitting
stack-checker.backend
stack-checker.errors
stack-checker.known-words
stack-checker.state
stack-checker.values
stack-checker.visitor ;
IN: stack-checker.row-polymorphism

: ?quotation-effect ( in -- effect/f )
    dup pair? [ second dup effect? [ drop f ] unless ] [ drop f ] if ;

:: declare-effect-d ( word effect variables n -- )
    meta-d length :> d-length
    n d-length < [
        d-length 1 - n - :> n'
        n' meta-d nth :> value
        value known :> known
        known word effect variables <declared-effect> :> known'
        known' value set-known
    ] [ word unknown-macro-input ] if ;

:: declare-input-effects ( word -- )
    H{ } clone :> variables
    word stack-effect in>> <reversed> [| in n |
        in ?quotation-effect [| effect |
            word effect variables n declare-effect-d
        ] when*
    ] each-index ;

:: with-effect-here ( quot -- effect )
    inner-d-index get :> old-inner-d-index
    input-count get :> old-input-count
    meta-d length :> old-meta-d-length

    old-meta-d-length inner-d-index set
    quot call
        
    inner-d-index get :> new-inner-d-index
    input-count get :> new-input-count

    old-meta-d-length new-inner-d-index -
    new-input-count old-input-count - + :> in

    meta-d length new-inner-d-index - :> out

    new-inner-d-index old-inner-d-index min inner-d-index set

    in "x" <array> out "x" <array> terminated? get <terminated-effect> ; inline

:: check-variable ( actual-count declared-count variable vars -- difference )
    actual-count declared-count -
    variable [
        variable vars at* nip
        [ variable vars at -     ]
        [ variable vars set-at 0 ] if
    ] [ drop 0 ] if ;

: adjust-variable ( diff var vars -- )
    pick 0 >=
    [ at+ ]
    [ 3drop ] if ; inline

:: check-variables ( vars declared actual -- ? )
    actual terminated?>> [ t ] [
        actual declared [ in>>  length ] bi@ declared in-var>>
            [ vars check-variable ] keep :> ( in-diff in-var ) 
        actual declared [ out>> length ] bi@ declared out-var>>
            [ vars check-variable ] keep :> ( out-diff out-var )
        { [ in-var not ] [ out-var not ] [ in-diff out-diff = ] } 0||
        dup [
            in-var  [ in-diff  swap vars adjust-variable ] when*
            out-var [ out-diff swap vars adjust-variable ] when*
        ] when
    ] if ;

: check-declared-effect ( known effect -- )
    2dup [ [ variables>> ] [ effect>> ] bi ] dip check-variables
    [ 2drop ] [
        [ { [ word>> ] [ known>callable ] [ variables>> ] [ effect>> ] } cleave ]
        dip invalid-quotation-input
    ] if ;

