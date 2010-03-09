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

:: with-inner-d ( quot -- inner-d )
    inner-d-index get :> old-inner-d-index
    meta-d length inner-d-index set
    quot call
    inner-d-index get :> new-inner-d-index
    old-inner-d-index new-inner-d-index min inner-d-index set
    new-inner-d-index ; inline

:: with-effect-here ( quot -- effect )
    input-count get :> old-input-count
    meta-d length :> old-meta-d-length

    quot with-inner-d :> inner-d
        
    input-count get :> new-input-count
    old-meta-d-length inner-d -
    new-input-count old-input-count - + :> in
    meta-d length inner-d - :> out
    in "x" <array> out "x" <array> terminated? get <terminated-effect> ; inline

:: check-variable ( actual-count declared-count variable vars -- difference ? )
    actual-count declared-count -
    variable [
        variable vars at* nip
        [ variable vars at -     ]
        [ variable vars set-at 0 ] if
        t
    ] [ dup zero? ] if ;

: adjust-variable ( diff var vars -- )
    pick 0 >=
    [ at+ ]
    [ 3drop ] if ; inline

:: check-variables ( vars declared actual -- ? )
    actual terminated?>> [ t ] [
        actual declared [ in>>  length ] bi@ declared in-var>>
            [ vars check-variable ] keep :> ( in-diff in-ok? in-var ) 
        actual declared [ out>> length ] bi@ declared out-var>>
            [ vars check-variable ] keep :> ( out-diff out-ok? out-var )
        { [ in-ok? ] [ out-ok? ] [ in-diff out-diff = ] } 0&&
        dup [
            in-var  [ in-diff  swap vars adjust-variable ] when*
            out-var [ out-diff swap vars adjust-variable ] when*
        ] when
    ] if ;

: complex-unbalanced-branches-error ( known -- * )
    [ word>> ] [
        branches>> <reversed>
        [ [ known>callable ] { } map-as ]
        [ [ effect>> ] { } map-as ]
        [ [ actual>> ] { } map-as ] tri
    ] bi unbalanced-branches-error ;

: check-declared-effect ( known effect -- )
    [ >>actual ] keep
    2dup [ [ variables>> ] [ effect>> ] bi ] dip check-variables
    [ 2drop ] [ drop complex-unbalanced-branches-error ] if ;

