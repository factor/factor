! (c)2010 Joe Groff bsd license
USING: accessors arrays assocs combinators combinators.short-circuit
continuations effects fry kernel locals math namespaces
quotations sequences splitting stack-checker
stack-checker.backend
stack-checker.errors
stack-checker.known-words
stack-checker.values ;
IN: stack-checker.row-polymorphism

<PRIVATE
SYMBOLS: current-effect-variables current-effect current-meta-d ;

: quotation-effect? ( in -- ? )
    dup pair? [ second effect? ] [ drop f ] if ;

SYMBOL: (unknown)

GENERIC: >error-quot ( known -- quot )

M: object >error-quot drop (unknown) ;
M: literal >error-quot value>> ;
M: composed >error-quot
    [ quot1>> known >error-quot ] [ quot2>> known >error-quot ] bi
    \ compose [ ] 3sequence ;
M: curried >error-quot
    [ obj>> known >error-quot ] [ quot>> known >error-quot ] bi
    \ curry [ ] 3sequence ;

: >error-branches-and-quots ( branch/values -- branches quots )
    [ [ second ] [ known >error-quot ] bi* ] assoc-map unzip ;

: abandon-check ( -- * )
    current-word get
    current-effect get in>> current-meta-d get zip
    [ first quotation-effect? ] filter
    >error-branches-and-quots
    invalid-quotation-input ;

:: check-variable ( actual-count declared-count variable -- difference )
    actual-count declared-count -
    variable [
        variable current-effect-variables get at* nip
        [ variable current-effect-variables get at -     ]
        [ variable current-effect-variables get set-at 0 ] if
    ] [
        dup [ abandon-check ] unless-zero
    ] if ;

: adjust-variable ( diff var -- )
    over 0 >=
    [ current-effect-variables get at+ ]
    [ 2drop ] if ; inline

:: (check-input) ( declared actual -- )
    actual in>>  length  declared in-var>>  [ check-variable ] keep :> ( in-diff in-var ) 
    actual out>> length  declared out-var>> [ check-variable ] keep :> ( out-diff out-var )
    { [ in-var not ] [ out-var not ] [ in-diff out-diff = ] } 0||
    [
        in-var  [ in-diff  swap adjust-variable ] when*
        out-var [ out-diff swap adjust-variable ] when*
    ] [
        abandon-check
    ] if ;

GENERIC: (infer-known) ( known -- effect )

M: object (infer-known)
    current-word get bad-macro-input ;
M: literal (infer-known)
    value>> dup callable? [ infer ] [ abandon-check ] if ;
M: composed (infer-known)
    [ quot1>> known (infer-known) ] [ quot2>> known (infer-known) ] bi compose-effects ;
M: curried (infer-known)
    (( -- x )) swap quot>> known (infer-known) compose-effects ;

: infer-known ( value -- effect )
    (infer-known) ; inline

: check-input ( in value -- )
    over quotation-effect? [
        [ second ] dip known infer-known (check-input)
    ] [ 2drop ] if ;

: normalize-variables ( -- variables' )
    current-effect-variables get dup values [
        infimum dup 0 <
        [ '[ _ - ] assoc-map ] [ drop ] if
    ] unless-empty ;

PRIVATE>

: infer-polymorphic-vars ( effect -- variables )
    H{ } clone current-effect-variables set
    dup current-effect set
    in>> dup length ensure-d dup current-meta-d set
    [ check-input ] 2each
    normalize-variables ;

: check-polymorphic-effect ( word -- )
    current-word get [
        dup current-word set stack-effect infer-polymorphic-vars drop
    ] dip current-word set ;

SYMBOL: infer-polymorphic?
