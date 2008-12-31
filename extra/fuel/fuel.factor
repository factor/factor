! Copyright (C) 2008 Jose Antonio Ortega Ruiz.
! See http://factorcode.org/license.txt for BSD license.

USING: accessors arrays assocs classes.tuple combinators
compiler.units continuations debugger definitions io io.pathnames
io.streams.string kernel lexer math math.order memoize namespaces
parser prettyprint sequences sets sorting source-files strings summary
tools.vocabs vectors vocabs vocabs.parser words ;

IN: fuel

! Evaluation status:

TUPLE: fuel-status in use restarts ;

SYMBOL: fuel-status-stack
V{ } clone fuel-status-stack set-global

SYMBOL: fuel-eval-result
f fuel-eval-result set-global

SYMBOL: fuel-eval-output
f fuel-eval-result set-global

SYMBOL: fuel-eval-res-flag
t fuel-eval-res-flag set-global

: fuel-eval-restartable? ( -- ? )
    fuel-eval-res-flag get-global ; inline

: fuel-eval-restartable ( -- )
    t fuel-eval-res-flag set-global ; inline

: fuel-eval-non-restartable ( -- )
    f fuel-eval-res-flag set-global ; inline

: fuel-push-status ( -- )
    in get use get clone restarts get-global clone
    fuel-status boa
    fuel-status-stack get push ;

: fuel-pop-restarts ( restarts -- )
    fuel-eval-restartable? [ drop ] [ clone restarts set-global ] if ; inline

: fuel-pop-status ( -- )
    fuel-status-stack get empty? [
        fuel-status-stack get pop
        [ in>> in set ]
        [ use>> clone use set ]
        [ restarts>> fuel-pop-restarts ] tri
    ] unless ;

! Lispy pretty printing

GENERIC: fuel-pprint ( obj -- )

M: object fuel-pprint pprint ; inline

M: f fuel-pprint drop "nil" write ; inline

M: integer fuel-pprint pprint ; inline

M: string fuel-pprint pprint ; inline

M: sequence fuel-pprint
    "(" write [ " " write ] [ fuel-pprint ] interleave ")" write ; inline

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
    error get fuel-eval-result get-global fuel-eval-output get-global
    3array fuel-pprint flush nl "<~FUEL~>" write nl flush ;

: fuel-forget-error ( -- ) f error set-global ; inline
: fuel-forget-result ( -- ) f fuel-eval-result set-global ; inline
: fuel-forget-output ( -- ) f fuel-eval-output set-global ; inline
: fuel-forget-status ( -- )
    fuel-forget-error fuel-forget-result fuel-forget-output ; inline

: (fuel-begin-eval) ( -- )
    fuel-push-status fuel-forget-status ; inline

: (fuel-end-eval) ( output -- )
    fuel-eval-output set-global fuel-retort fuel-pop-status ; inline

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

! Loading files

SYMBOL: :uses

: fuel-set-use-hook ( -- )
    [ amended-use get clone :uses prefix fuel-eval-set-result ]
    print-use-hook set ;

: fuel-run-file ( path -- )
    [ fuel-set-use-hook run-file ] curry with-scope ; inline

: fuel-with-autouse ( quot -- )
    [ auto-use? on fuel-set-use-hook call ] curry with-scope ;

: (fuel-get-uses) ( lines -- )
    [ parse-fresh drop ] curry with-compilation-unit ; inline

: fuel-get-uses ( lines -- )
    [ (fuel-get-uses) ] curry fuel-with-autouse ;

! Edit locations

: fuel-normalize-loc ( seq -- path line )
    dup length 1 > [ first2 [ (normalize-path) ] dip ] [ f ] if ; inline

: fuel-get-edit-location ( defspec -- )
    where fuel-normalize-loc 2array fuel-eval-set-result ; inline

: fuel-get-vocab-location ( vocab -- )
    >vocab-link fuel-get-edit-location ; inline

: fuel-get-doc-location ( defspec -- )
    props>> "help-loc" swap at
    fuel-normalize-loc 2array fuel-eval-set-result ;

! Cross-references

: fuel-word>xref ( word -- xref )
    [ name>> ] [ vocabulary>> ] [ where fuel-normalize-loc ] tri 4array ;

: fuel-sort-xrefs ( seq -- seq' )
    [ [ first ] dip first <=> ] sort ; inline

: fuel-format-xrefs ( seq -- seq' )
    [ word? ] filter [ fuel-word>xref ] map fuel-sort-xrefs ;

: fuel-callers-xref ( word -- )
    usage fuel-format-xrefs fuel-eval-set-result ; inline

: fuel-callees-xref ( word -- )
    uses fuel-format-xrefs fuel-eval-set-result ; inline

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
