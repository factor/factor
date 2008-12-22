! Copyright (C) 2008 Jose Antonio Ortega Ruiz.
! See http://factorcode.org/license.txt for BSD license.

USING: accessors arrays assocs classes classes.tuple
combinators compiler.units continuations debugger definitions
eval help io io.files io.pathnames io.streams.string kernel
lexer listener listener.private make math math.order memoize
namespaces parser prettyprint prettyprint.config quotations
sequences sets sorting source-files strings summary tools.vocabs
vectors vocabs vocabs.loader vocabs.parser words ;

IN: fuel

! Evaluation status:

TUPLE: fuel-status in use restarts ;

SYMBOL: fuel-status-stack
V{ } clone fuel-status-stack set-global

SYMBOL: fuel-eval-result
f clone fuel-eval-result set-global

SYMBOL: fuel-eval-output
f clone fuel-eval-result set-global

SYMBOL: fuel-eval-res-flag
t clone fuel-eval-res-flag set-global

: fuel-eval-restartable? ( -- ? )
    fuel-eval-res-flag get-global ; inline

: fuel-eval-restartable ( -- )
    t fuel-eval-res-flag set-global ; inline

: fuel-eval-non-restartable ( -- )
    f fuel-eval-res-flag set-global ; inline

: push-fuel-status ( -- )
    in get use get clone restarts get-global clone
    fuel-status boa
    fuel-status-stack get push ;

: pop-fuel-status ( -- )
    fuel-status-stack get empty? [
        fuel-status-stack get pop
        [ in>> in set ]
        [ use>> clone use set ]
        [
            restarts>> fuel-eval-restartable? [ drop ] [
                clone restarts set-global
            ] if
        ] tri
    ] unless ;


! Lispy pretty printing

GENERIC: fuel-pprint ( obj -- )

M: object fuel-pprint pprint ; inline

M: f fuel-pprint drop "nil" write ; inline

M: integer fuel-pprint pprint ; inline

M: string fuel-pprint pprint ; inline

M: sequence fuel-pprint
    dup empty? [ drop f fuel-pprint ] [
        "(" write
        [ " " write ] [ fuel-pprint ] interleave
        ")" write
    ] if ;

M: tuple fuel-pprint tuple>array fuel-pprint ; inline

M: continuation fuel-pprint drop ":continuation" write ; inline

M: restart fuel-pprint name>> fuel-pprint ; inline

SYMBOL: :restarts

: fuel-restarts ( obj -- seq )
    compute-restarts :restarts prefix ; inline

M: condition fuel-pprint
    [ error>> ] [ fuel-restarts ] bi 2array condition prefix fuel-pprint ;

M: lexer-error fuel-pprint
    {
        [ line>> ]
        [ column>> ]
        [ line-text>> ]
        [ fuel-restarts ]
    } cleave 4array lexer-error prefix fuel-pprint ;

M: source-file-error fuel-pprint
    [ file>> ] [ error>> ] bi 2array source-file-error prefix
    fuel-pprint ;

M: source-file fuel-pprint path>> fuel-pprint ;

! Evaluation vocabulary

: fuel-eval-set-result ( obj -- )
    clone fuel-eval-result set-global ; inline

: fuel-retort ( -- )
    error get
    fuel-eval-result get-global
    fuel-eval-output get-global
    3array fuel-pprint flush nl "<~FUEL~>" write nl flush ;

: fuel-forget-error ( -- ) f error set-global ; inline
: fuel-forget-result ( -- ) f fuel-eval-result set-global ; inline
: fuel-forget-output ( -- ) f fuel-eval-output set-global ; inline

: (fuel-begin-eval) ( -- )
    push-fuel-status
    fuel-forget-error
    fuel-forget-result
    fuel-forget-output ;

: (fuel-end-eval) ( result -- )
    fuel-eval-output set-global fuel-retort
    pop-fuel-status ; inline

: (fuel-eval) ( lines -- )
    [ [ parse-lines ] with-compilation-unit call ] curry
    [ print-error ] recover ; inline

: (fuel-eval-each) ( lines -- )
    [ 1vector (fuel-eval) ] each ; inline

: (fuel-eval-usings) ( usings -- )
    [ "USING: " prepend " ;" append ] map
    (fuel-eval-each) fuel-forget-error fuel-forget-output ;

: (fuel-eval-in) ( in -- )
    [ dup "IN: " prepend 1vector (fuel-eval) in set ] when* ; inline

: fuel-eval-in-context ( lines in usings -- )
    (fuel-begin-eval)
    [ (fuel-eval-usings) (fuel-eval-in) (fuel-eval) ] with-string-writer
    (fuel-end-eval) ;

: fuel-run-file ( path -- ) run-file ; inline

! Edit locations

: fuel-normalize-loc ( seq -- path line )
    dup length 1 > [ first2 [ (normalize-path) ] dip ] [ f ] if ; inline

: fuel-get-edit-location ( defspec -- )
    where fuel-normalize-loc 2array fuel-eval-set-result ; inline

: fuel-get-doc-location ( defspec -- )
    props>> "help-loc" swap at
    fuel-normalize-loc 2array fuel-eval-set-result ;

: fuel-format-xrefs ( seq -- seq )
    [ word? ] filter [
        [ name>> ]
        [ vocabulary>> ]
        [ where fuel-normalize-loc ] tri 4array
    ] map [ [ first ] dip first <=> ] sort ; inline

: fuel-callers-xref ( word -- )
    usage fuel-format-xrefs fuel-eval-set-result ; inline

: fuel-callees-xref ( word -- )
    uses fuel-format-xrefs fuel-eval-set-result ; inline

: fuel-get-vocab-location ( vocab -- )
    >vocab-link fuel-get-edit-location ; inline

! Completion support

: fuel-filter-prefix ( seq prefix -- seq )
    [ drop-prefix nip length 0 = ] curry filter prune ; inline

: (fuel-get-vocabs) ( -- seq )
    all-vocabs-seq [ vocab-name ] map ; inline

: fuel-get-vocabs ( -- )
    (fuel-get-vocabs) fuel-eval-set-result ; inline

: fuel-get-vocabs/prefix ( prefix -- )
    (fuel-get-vocabs) swap fuel-filter-prefix fuel-eval-set-result ; inline

: fuel-vocab-summary ( name -- )
    >vocab-link summary fuel-eval-set-result ; inline

MEMO: (fuel-vocab-words) ( name -- seq )
    >vocab-link words [ name>> ] map ;

: fuel-current-words ( -- seq )
    use get [ keys ] map concat ; inline

: fuel-vocabs-words ( names -- seq )
    prune [ (fuel-vocab-words) ] map concat ; inline

: (fuel-get-words) ( prefix names/f -- seq )
    [ fuel-vocabs-words ] [ fuel-current-words ] if* natural-sort
    swap fuel-filter-prefix ;

: fuel-get-words ( prefix names -- )
    (fuel-get-words) fuel-eval-set-result ; inline


! -run=fuel support

: fuel-startup ( -- ) "listener" run-file ; inline

MAIN: fuel-startup
