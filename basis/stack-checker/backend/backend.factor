! Copyright (C) 2004, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: fry arrays generic io io.streams.string kernel math namespaces
parser sequences strings vectors words quotations effects classes
continuations assocs combinators compiler.errors accessors math.order
definitions locals sets hints macros stack-checker.state
stack-checker.visitor stack-checker.errors stack-checker.values
stack-checker.recursive-state stack-checker.dependencies summary ;
FROM: sequences.private => from-end ;
FROM: namespaces => set ;
IN: stack-checker.backend

: push-d ( obj -- ) meta-d push ;

: introduce-values ( values -- )
    [ [ [ input-parameter ] dip set-known ] each ]
    [ length input-count +@ ]
    [ #introduce, ]
    tri ;

: update-inner-d ( new -- )
    inner-d-index get min inner-d-index set ;

: pop-d  ( -- obj )
    meta-d
    [ <value> dup 1array introduce-values ]
    [ pop meta-d length update-inner-d ] if-empty ;

: peek-d ( -- obj ) pop-d dup push-d ;

: make-values ( n -- values )
    [ <value> ] replicate ;

: ensure-d ( n -- values )
    meta-d 2dup length > [
        2dup
        [ nip >array ] [ length - make-values ] [ nip delete-all ] 2tri
        [ introduce-values ] [ meta-d push-all ] bi
        meta-d push-all
    ] when
    swap from-end [ tail ] [ update-inner-d ] bi ;

: shorten-by ( n seq -- )
    [ length swap - ] keep shorten ; inline

: shorten-d ( n -- )
    meta-d shorten-by meta-d length update-inner-d ;

: consume-d ( n -- seq )
    [ ensure-d ] [ shorten-d ] bi ;

: output-d ( values -- ) meta-d push-all ;

: produce-d ( n -- values )
    make-values dup meta-d push-all ;

: push-r ( obj -- ) meta-r push ;

: pop-r ( -- obj )
    meta-r dup empty?
    [ too-many-r> ] [ pop ] if ;

: consume-r ( n -- seq )
    meta-r 2dup length >
    [ too-many-r> ] when
    [ swap tail* ] [ shorten-by ] 2bi ;

: output-r ( seq -- ) meta-r push-all ;

: push-literal ( obj -- )
    literals get push ;

: pop-literal ( -- rstate obj )
    literals get [
        pop-d
        [ 1array #drop, ]
        [ literal [ recursion>> ] [ value>> ] bi ] bi
    ] [ pop recursive-state get swap ] if-empty ;

: literals-available? ( n -- literals ? )
    literals get 2dup length <=
    [ [ swap tail* ] [ shorten-by ] 2bi t ] [ 2drop f f ] if ;

GENERIC: apply-object ( obj -- )

M: wrapper apply-object
    wrapped>>
    [ dup word? [ add-depends-on-effect ] [ drop ] if ]
    [ push-literal ]
    bi ;

M: object apply-object push-literal ;

: terminate ( -- )
    terminated? on meta-d clone meta-r clone #terminate, ;

: check->r ( -- )
    meta-r empty? [ too-many->r ] unless ;

: infer-quot-here ( quot -- )
    meta-r [
        V{ } clone (meta-r) set
        [ apply-object terminated? get not ] all?
        [ commit-literals check->r ] [ literals get delete-all ] if
    ] dip (meta-r) set ;

: infer-quot ( quot rstate -- )
    recursive-state get [
        recursive-state set
        infer-quot-here
    ] dip recursive-state set ;

: time-bomb-quot ( obj generic -- quot )
    [ literalize ] [ "default-method" word-prop ] bi* [ ] 2sequence ;

: time-bomb ( obj generic -- )
    time-bomb-quot infer-quot-here ;

: infer-literal-quot ( literal -- )
    dup recursive-quotation? [
        value>> recursive-quotation-error
    ] [
        dup value>> callable? [
            [ value>> ]
            [ [ recursion>> ] keep add-local-quotation ]
            bi infer-quot
        ] [
            value>> \ call time-bomb
        ] if
    ] if ;

: infer->r ( n -- )
    consume-d dup copy-values [ nip output-r ] [ #>r, ] 2bi ;

: infer-r> ( n -- )
    consume-r dup copy-values [ nip output-d ] [ #r>, ] 2bi ;

: consume/produce ( ..a effect quot: ( ..a inputs outputs -- ..b ) -- ..b )
    '[ [ in>> length consume-d ] [ out>> length produce-d ] bi @ ]
    [ terminated?>> [ terminate ] when ]
    bi ; inline

: apply-word/effect ( word effect -- )
    swap '[ _ #call, ] consume/produce ;

: end-infer ( -- )
    meta-d clone #return, ;

: required-stack-effect ( word -- effect )
    dup stack-effect [ ] [ missing-effect ] ?if ;

: with-infer ( quot -- effect visitor )
    [
        init-inference
        init-known-values
        stack-visitor off
        call
        end-infer
        current-effect
        stack-visitor get
    ] with-scope ; inline

: (infer) ( quot -- effect )
    [ infer-quot-here ] with-infer drop ;

: ?quotation-effect ( in -- effect/f )
    dup pair? [ second dup effect? [ drop f ] unless ] [ drop f ] if ;

:: declare-effect-d ( word effect variables branches n -- )
    meta-d length :> d-length
    n d-length < [
        d-length 1 - n - :> n'
        n' meta-d nth :> value
        value known :> known
        known word effect variables branches <declared-effect> :> known'
        known' value set-known
        known' branches push
    ] [ word unknown-macro-input ] if ;

:: declare-input-effects ( word -- )
    H{ } clone :> variables
    V{ } clone :> branches
    word stack-effect in>> <reversed> [| in n |
        in ?quotation-effect [| effect |
            word effect variables branches n declare-effect-d
        ] when*
    ] each-index ;

