! Copyright (C) 2008, 2009 Jose Antonio Ortega Ruiz.
! See http://factorcode.org/license.txt for BSD license.

USING: accessors arrays assocs classes.tuple combinators
compiler.units continuations debugger definitions help help.crossref
help.markup help.topics io io.pathnames io.streams.string kernel lexer
make math math.order memoize namespaces parser prettyprint sequences
sets sorting source-files strings summary tools.crossref tools.vocabs
vectors vocabs vocabs.parser words ;

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

: fuel-maybe-scape ( ch -- seq )
    dup "\"?#()[]'`" member? [ CHAR: \ swap 2array ] [ 1array ] if ;

M: word fuel-pprint
    name>> V{ } clone [ fuel-maybe-scape append ] reduce >string write ;

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

: fuel-with-autouse ( ... quot: ( ... -- ... ) -- ... )
    [ auto-use? on fuel-set-use-hook call ] curry with-scope ; inline

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
    [ word? ] filter [ fuel-word>xref ] map ; inline

: fuel-callers-xref ( word -- )
    usage fuel-format-xrefs fuel-sort-xrefs fuel-eval-set-result ; inline

: fuel-callees-xref ( word -- )
    uses fuel-format-xrefs fuel-sort-xrefs fuel-eval-set-result ; inline

: fuel-apropos-xref ( str -- )
    words-matching fuel-format-xrefs fuel-eval-set-result ; inline

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

! Help support

MEMO: fuel-articles-seq ( -- seq )
    articles get values ;

: fuel-find-articles ( title -- seq )
    [ [ article-title ] dip = ] curry fuel-articles-seq swap filter ;

MEMO: fuel-find-article ( title -- article/f )
    fuel-find-articles dup empty? [ drop f ] [ first ] if ;

MEMO: fuel-article-title ( name -- title/f )
    articles get at [ article-title ] [ f ] if* ;

: fuel-get-article ( name -- )
    article fuel-eval-set-result ;

: fuel-value-str ( word -- str )
    [ pprint-short ] with-string-writer ; inline

: fuel-definition-str ( word -- str )
    [ see ] with-string-writer ; inline

: fuel-methods-str ( word -- str )
    methods dup empty? not [
        [ [ see nl ] each ] with-string-writer
    ] [ drop f ] if ; inline

: fuel-related-words ( word -- seq )
    dup "related" word-prop remove ; inline

: fuel-parent-topics ( word -- seq )
    help-path [ dup article-title swap 2array ] map ; inline

: (fuel-word-help) ( word -- element )
    dup \ article swap article-title rot
    [
        {
            [ fuel-parent-topics [ \ $doc-path prefix , ] unless-empty ]
            [ \ $vocabulary swap vocabulary>> 2array , ]
            [ word-help % ]
            [ fuel-related-words [ \ $related swap 2array , ] unless-empty ]
            [ get-global [ \ $value swap fuel-value-str 2array , ] when* ]
            [ \ $definition swap fuel-definition-str 2array , ]
            [ fuel-methods-str [ \ $methods swap 2array , ] when* ]
        } cleave
    ] { } make 3array ;

MEMO: fuel-find-word ( name -- word/f )
    [ [ name>> ] dip = ] curry all-words swap filter
    dup empty? not [ first ] [ drop f ] if ;

: fuel-word-help ( name -- )
    fuel-find-word [ [ auto-use? on (fuel-word-help) ] with-scope ] [ f ] if*
    fuel-eval-set-result ; inline

: (fuel-word-see) ( word -- elem )
    [ name>> \ article swap ]
    [ [ see ] with-string-writer \ $code swap 2array ] bi 3array ; inline

: fuel-word-see ( name -- )
    fuel-find-word [ [ auto-use? on (fuel-word-see) ] with-scope ] [ f ] if*
    fuel-eval-set-result ; inline

: (fuel-vocab-help) ( name -- element )
    \ article swap dup >vocab-link
    [
        [ summary [ , ] [ "No summary available" , ] if* ]
        [ drop \ $nl , ]
        [ vocab-help article [ content>> % ] when* ] tri
    ] { } make 3array ;

: fuel-vocab-help ( name -- )
    (fuel-vocab-help) fuel-eval-set-result ; inline

: (fuel-index) ( seq -- seq )
    [ [ >link name>> ] [ article-title ] bi 2array \ $subsection prefix ] map ;

: fuel-index ( quot: ( -- seq ) -- )
    call (fuel-index) fuel-eval-set-result ; inline

! -run=fuel support

: fuel-startup ( -- ) "listener" run-file ; inline

MAIN: fuel-startup
