! Copyright (C) 2021 KUSUMOTO Norio.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs classes classes.algebra
classes.algebra.private classes.maybe classes.private
combinators combinators.private combinators.short-circuit
compiler.units debugger definitions effects effects.parser
generalizations hashtables io kernel kernel.private
layouts locals.parser make math math.order math.private
namespaces parser prettyprint prettyprint.backend
prettyprint.custom prettyprint.sections quotations see
sequences sequences.generalizations sets shuffle sorting
splitting stack-checker.dependencies stack-checker.transforms
summary tools.annotations tools.annotations.private typed
vectors vocabs words words.symbol ;
FROM: namespaces => set ;
QUALIFIED-WITH: generic.single.private gsp
QUALIFIED-WITH: generic g
IN: multi-generic

PREDICATE: multi-generic < word
    "multi-methods" word-prop >boolean ;

PREDICATE: multi-method < word
    "multi-generic" word-prop >boolean ;

TUPLE: dispatch ;

TUPLE: multi-dispatch < dispatch ;

TUPLE: non-multi-dispatch < dispatch methods ;

TUPLE: single-dispatch < non-multi-dispatch ;

TUPLE: single-standard-dispatch < single-dispatch # ;

TUPLE: single-hook-dispatch < single-dispatch var ;

TUPLE: math-dispatch < non-multi-dispatch ;

TUPLE: covariant-tuple-dispatch < non-multi-dispatch ;

PREDICATE: multi-dispatch-generic < multi-generic
    "dispatch-type" word-prop multi-dispatch? ;

PREDICATE: covariant-tuple-dispatch-generic < multi-generic
    "dispatch-type" word-prop covariant-tuple-dispatch? ;

C: <multi-dispatch> multi-dispatch

ERROR: bad-dispatch-position # ;

: <single-standard-dispatch> ( # -- single-standard-dispatch )
    dup integer? [ dup 0 < ] [ t ] if
    [ bad-dispatch-position ] when
    f swap single-standard-dispatch boa ;

: <single-hook-dispatch> ( var -- single-hook-dispatch )
    f swap single-hook-dispatch boa ;

: <math-dispatch> ( -- math-dispatch ) f math-dispatch boa ;

GENERIC: make-single-default-method ( generic dispatch -- method )

GENERIC: perform-dispatch ( word dispatch -- )

GENERIC#: check-dispatch-effect 1 ( dispatch effect -- )

GENERIC: effective-method ( generic -- method )

\ effective-method t "no-compile" set-word-prop

PREDICATE: math-class < class
    dup null bootstrap-word eq? [ drop f ] [
        number bootstrap-word class<=
    ] if ;

: methods ( word -- alist )
    "multi-methods" word-prop >alist ;

:: generic-stack-effect ( generic -- effect )
    generic
    [ stack-effect [ in>> ] [ out>> ] bi ]
    [ "hooks" word-prop ]
    bi :> ( in out hooks )
    hooks [ in ] [ { "|" } in 3append ] if-empty out <effect> ;

ERROR: separator-syntax-error effect ;

M: separator-syntax-error error.
    "Up to one separator “|” can be used before a stack effect."
    print
    effect>> pprint ;

: separator-error? ( effect -- ? )
    [ in>>  [ "|" = ] count 1 > ]
    [ out>> [ "|" = ] count 0 > ]
    bi or ;

: parse-variable-effect ( effect -- effect' hooks )
    dup separator-error? [ separator-syntax-error ] when
    [
        in>> { "|" } split1 [
            [
                [
                    dup array? [
                        first2 [ parse-word ] dip 2array
                    ] [ parse-word ] if
                ] map
            ] dip
        ] [ { } clone swap ] if*
    ]
    [ out>> ]
    bi <effect> swap ;

:: effect>specializer ( effect -- specializer )
    effect dup separator-error? [ separator-syntax-error ] when
    parse-variable-effect :> ( eff vars )
    eff in>> [
        dup array? [
            second dup effect? [ drop callable ] when
        ] [
            drop object bootstrap-word ! object
        ] if
    ] map
    vars append ;

: (picker) ( n -- quot )
    {
        { 0 [ [ dup ] ] }
        { 1 [ [ over ] ] }
        { 2 [ [ pick ] ] }
        [ 1 - (picker) [ dip swap ] curry ]
    } case ;


! PART I: Converting hook specializers
: canonicalize-specializer-0 ( specializer -- specializer' )
    [ \ f or ] map ;

SYMBOL: args

SYMBOL: hooks

SYMBOL: total

: canonicalize-specializer-1 ( specializer -- specializer' )
    [
        [ class? ] filter
        [ length <iota> <reversed> [ 1 + neg ] map ] keep zip
        [ length args [ max ] change ] keep
    ]
    [
        [ pair? ] filter
        [ keys [ hooks get adjoin ] each ] keep
    ] bi append ;

: canonicalize-specializer-2 ( specializer -- specializer' )
    [
        [
            {
                { [ dup integer? ] [ ] }
                { [ dup word? ] [ hooks get index ] }
            } cond args get +
        ] dip
    ] assoc-map ;

: canonicalize-specializer-3 ( specializer -- specializer' )
    [
        total get object bootstrap-word <array> <enumerated>
    ] dip assoc-union! seq>> ;

: canonicalize-specializers ( methods -- methods' hooks )
    [
        [ [ canonicalize-specializer-0 ] dip ] assoc-map
        0 args set
        V{ } clone hooks set
        [ [ canonicalize-specializer-1 ] dip ] assoc-map
        hooks [ natural-sort ] change
        [ [ canonicalize-specializer-2 ] dip ] assoc-map
        args get hooks get length + total set
        [ [ canonicalize-specializer-3 ] dip ] assoc-map
        hooks get
    ] with-scope ;


! Part II: Topologically sorting specializers
: maximal-element ( seq quot -- n elt )
    dupd [
        swapd [ call +lt+ = ] 2curry none?
    ] 2curry find [
        "Topological sort failed" throw
    ] unless* ; inline

: topological-sort ( seq quot -- newseq )
    [ >vector [ dup empty? not ] ] dip
    [ dupd maximal-element [ over remove-nth! drop ] dip ] curry
    produce nip ; inline

: classes< ( seq1 seq2 -- lt/eq/gt )
    [
        {
            { [ 2dup eq? ] [ +eq+ ] }
            { [ 2dup [ class<= ] [ swap class<= ] 2bi and ] [ +eq+ ] }
            { [ 2dup class<= ] [ +lt+ ] }
            { [ 2dup swap class<= ] [ +gt+ ] }
            [ +eq+ ]
        } cond 2nip
    ] 2map [ +eq+ eq? not ] find nip +eq+ or ;

: sort-methods ( alist -- alist' )
    [ [ first ] bi@ classes< ] topological-sort ;

! PART III: Creating dispatch quotation
: drop-n-quot ( n -- quot ) \ drop <repetition> >quotation ;

: prepare-method ( method n -- quot )
    [ 1quotation ] [ drop-n-quot ] bi* prepend ;

: prepare-methods ( methods -- methods' prologue )
    canonicalize-specializers
    [ length [ prepare-method ] curry assoc-map ] keep
    [ [ get ] curry ] map concat [ ] like ;

: (multi-predicate) ( class picker -- quot )
    swap predicate-def append ;

: multi-predicate ( classes -- quot )
    dup length <iota> <reversed>
    [ (picker) 2array ] 2map
    [ drop object bootstrap-word eq? ] assoc-reject
    [ [ t ] ] [
        [ (multi-predicate) ] { } assoc>map
        unclip [ swap [ f ] \ if 3array append [ ] like ] reduce
    ] if-empty ;

: argument-count ( methods -- n )
    keys 0 [ length max ] reduce ;

:: specializers ( methods -- stack-specs hook-specs )
    V{ } clone :> stack-specializers
    V{ } clone :> hook-specializers
    methods keys [
        dup length <iota> reverse swap [
            dup array? [
                ! hook-specializer
                nip first dup hook-specializers in? [ drop ] [
                    hook-specializers push
                ] if
            ] [
                ! stack-specializer
                dup object bootstrap-word = [ 2drop ] [
                    drop
                    dup stack-specializers in? [ drop ] [
                        stack-specializers push
                    ] if
                ] if
            ] if
        ] 2each
    ] each
    stack-specializers hook-specializers [ >array ] bi@ ;

ERROR: no-method arguments generic ;

: make-default-method ( methods generic -- quot )
    [ argument-count ] dip [ [ narray ] dip no-method ] 2curry ;

:: multi-dispatch-quot ( methods generic -- quot )
    methods generic make-default-method
    methods [ [ multi-predicate ] dip ] assoc-map reverse!
    alist>quot ;

: make-single-generic ( word -- )
    [ "unannotated-def" remove-word-prop ]
    [ dup "dispatch-type" word-prop perform-dispatch ]
    bi ;

: non-multi-generic? ( word -- ? )
    "dispatch-type" word-prop non-multi-dispatch? ; inline

ERROR: check-method-error class generic ;

: check-single-method ( classoid generic -- class generic )
    2dup [ classoid? ] [ non-multi-generic? ] bi* and [
        check-method-error
    ] unless ; inline

:: ?single-generic-spec ( generic -- n/var/f )
    generic methods specializers :> ( stack-specs hook-specs )
    hook-specs length 0 = [
        stack-specs length 1 = [ stack-specs first ] [ f ] if
    ] [
        hook-specs length 1 = [
            stack-specs length 0 = [ hook-specs first ] [ f ] if
        ] [ f ] if
    ] if ;

DEFER: define-single-default-method

DEFER: sort-generic-methods

SYMBOL: second-math-dispatch

M:: multi-generic g:make-generic ( generic -- )
    generic "mathematical" word-prop [
        ! math-dispatch
        <math-dispatch> dup
        generic swap "dispatch-type" set-word-prop
        generic "multi-methods" word-prop [
            drop {
                [ second math-class? ]
                [ [ first ] [ second ] bi = ]
            } 1&&
        ] assoc-filter [
            [ dup length 1 - swap nth ] dip
        ] assoc-map
        generic "dispatch-type" word-prop methods<<
        generic make-single-generic
        generic swap define-single-default-method
    ] [
        generic ?single-generic-spec dup [
            dup symbol? [
                ! hook-dispatch
                <single-hook-dispatch>
                generic swap "dispatch-type" set-word-prop
                generic "multi-methods" word-prop [
                    [ dup length 1 - swap nth second ] dip
                ] assoc-map
                generic "dispatch-type" word-prop methods<<
            ] [
                ! single-dispatch
                [
                    <single-standard-dispatch>
                    generic swap "dispatch-type" set-word-prop
                ]
                [| # |
                    generic "multi-methods" word-prop [
                        [ dup length 1 - # - swap nth ] dip
                    ] assoc-map
                 generic "dispatch-type" word-prop methods<<
                ] bi
            ] if
            generic dup "dispatch-type" word-prop
            define-single-default-method
            generic make-single-generic
        ] [
            ! multi-dispach
            drop
            generic {
                [ "cached-multi" word-prop ]
                [ "hooks" word-prop empty? ]
                [ "inline" word-prop not ]
                [ "partial-inline" word-prop not ]
            } 1&& [
                covariant-tuple-dispatch new
                generic swap "dispatch-type" set-word-prop
                generic "multi-methods" word-prop [
                    [
                        [ bootstrap-word ] map <covariant-tuple> 
                    ] dip
                ] assoc-map
                generic "dispatch-type" word-prop methods<<
                generic sort-generic-methods
                generic dup "dispatch-type" word-prop define-single-default-method
                generic make-single-generic
            ] [
                generic <multi-dispatch> "dispatch-type" set-word-prop
                generic [
                    [ methods prepare-methods % sort-methods ] keep
                    multi-dispatch-quot %
                ] [ ] make generic swap define
            ] if
        ] if
    ] if
    ! ! typed
    ! generic stack-effect :> effect
    ! effect [ in>> ] [ out>> ] bi [
    !     f [ array? or ] reduce
    ! ] bi@ or [
    !     generic generic def>> effect define-typed
    ! ] when

    generic methods dup empty? [ drop ] [
        values t [
            "multi-method-effect" word-prop
            out>> [
                dup array? [ second ] [ drop object bootstrap-word ] if
            ] map
            over t = [ nip ] [ dup swap = not [ drop f ] when ] if
        ] reduce [
            dup [ object bootstrap-word = ] all? [ drop ] [
                \ declare 2array >quotation generic def>> prepend generic def<<
            ] if
        ] when*
    ] if
 ;

: remake-multi-generic ( generic -- )
    outdated-generics get add-to-unit ;

: remake-multi-generics ( -- )
    outdated-generics get members [ multi-generic? ] filter
    [ g:make-generic ] each ;

M: multi-generic g:update-generic ( class/classes generic -- )
    [
        over array? [
            '[ _ changed-call-sites ] each
        ] [ changed-call-sites ] if
    ]
    [ remake-multi-generic drop ]
    [ changed-conditionally drop ]
    2tri ;

! Methods
M: multi-method stack-effect
    "multi-generic" word-prop stack-effect ;

M: multi-method crossref?
    "forgotten" word-prop not ;

M: multi-method parent-word
    "multi-generic" word-prop ;

: method-word-name ( specializer generic -- string )
    [ name>> % " " % unparse % ] "" make ;

: method-word-props ( multi-method-effect specializer generic -- assoc )
    [
        "multi-generic" ,,
        "method-specializer" ,,
        "multi-method-effect" ,,
    ] H{ } make ;

: <method> ( multi-method-effect specializer generic -- word )
    [ method-word-props ] 3keep nip
    method-word-name f <word>
    swap >>props ;

: with-methods ( classes generic quot -- )
    [ "multi-methods" word-prop ] prepose [ g:update-generic ] 2bi ;
    inline

GENERIC: implementor-classes ( obj -- class )

M: maybe implementor-classes class>> 1array ;

M: class implementor-classes 1array ;

M: anonymous-union implementor-classes members>> ;

M: anonymous-intersection implementor-classes participants>> ;

: with-implementors ( class generic quot -- )
    [
        swap implementor-classes [ implementors-map get at ] map
    ] dip call ; inline

: reveal-method ( method classes generic -- )
    [ set-at ] with-methods ;

: method ( classes word -- method )
    "multi-methods" word-prop at ;

:: create-method ( effect classes generic -- method )
    classes generic
    2dup method dup [
        2nip
    ] [
        drop [ effect -rot <method> dup ] 2keep reveal-method
        reset-caches
    ] if ;

:: ?lookup-multi-method ( classes generic  -- method/f )
    generic methods sort-methods [
        first classes swap t [ class<= and ] 2reduce
    ] find nip dup [ second ] when ;

:: ?lookup-next-multi-method ( classes generic  -- method/f )
    generic methods sort-methods
    [ drop classes classes< +gt+ = ] assoc-filter [
        first classes swap t [ class<= and ] 2reduce
    ] find nip dup [ second ] when ;

: niceify-method ( seq -- seq )
    [ dup \ f eq? [ drop f ] when ] map ;

M: no-method error.
    "Type check error" print
    nl
    "Generic word " write dup generic>> pprint
    " does not have a method applicable to inputs:" print
    dup arguments>> short.
    nl
    "Inputs have signature:" print
    dup arguments>> [ class-of ] map niceify-method .
    nl
    "Available methods: " print
    generic>> methods values stack. ;

: forget-method ( specializer generic -- )
    [ delete-at ] with-methods ;

: method>spec ( method -- spec )
    [ "method-specializer" word-prop ]
    [ "multi-generic" word-prop ] bi prefix ;

! M: multi-generic subwords
!    [
!        "multi-methods" word-prop values %
!    ] { } make ;

: reset-multi-generic ( word -- )
    {
        [ "multi-methods" word-prop values forget-all ]
        [ reset-word ]
        [
            f >>pic-def f >>pic-tail-def
            {
                "multi-methods"
                "hooks"
                "dispatch-type"
                "mathematical"
                "inline"
                "patial-inline"
                "cached-multi"
            } remove-word-props
        ]
        [ H{ } clone "multi-methods" set-word-prop ]
    } cleave ;

: define-generic ( word effect hooks -- )
    {
        [
            2drop dup "multi-methods" word-prop [ drop ] [
                reset-multi-generic
            ] if
        ]
        [ drop set-stack-effect ]
        [ nip "hooks" set-word-prop ]
        [ 2drop remake-multi-generic ]
    } 3cleave ;

! ! Syntax ! ! !
SYNTAX: MGENERIC: scan-new-word scan-effect
    parse-variable-effect
    define-generic ;

: make-mathematical ( word -- )
    dup multi-generic? [
        t "mathematical" set-word-prop
    ] [ drop ] if ;

SYNTAX: mathematical last-word make-mathematical ;

: make-partial-inline ( word -- )
    dup multi-generic? [
        t "partial-inline" set-word-prop
    ] [ drop ] if ;

SYNTAX: partial-inline last-word make-partial-inline ;

ERROR: parameter-composition-mismatch ;

M: parameter-composition-mismatch summary
    drop
    "The composition of the parameters must be the same as \
that of the multi-generic word." ;

ERROR: invalid-math-method-parameter ;

M: invalid-math-method-parameter summary
    drop
    "Mathematical multi-method's parameters are two stack parameters." ;

:: create-method-in ( effect specializer generic -- method )
    effect parse-variable-effect :> ( method-effect method-hooks )
    generic stack-effect method-effect [ in>> length ] bi@ =
    generic "hooks" word-prop method-hooks [ length ] bi@ = and
    generic stack-effect method-effect [ out>> length ] bi@ = and [
        parameter-composition-mismatch
    ] unless
    generic "mathematical" word-prop [
        specializer {
            [ t [ array? not and ] reduce ]
            [ length 2 = ]
        } 1&& [
            invalid-math-method-parameter
        ] unless
    ] when
    effect specializer generic create-method
    dup [ save-location ] [ set-last-word ] bi ;

: scan-new-method ( -- method )
    scan-word scan-effect
    dup effect>specializer rot create-method-in ;

SYMBOL: current-multi-method

: with-multi-method-definition ( method quot -- )
    over current-multi-method set call current-multi-method off ; inline

: (MM:) ( -- method def )
    [
        scan-new-method [
            parse-definition
        ] with-multi-method-definition
    ] with-definition ;

: extract-locals ( method -- effect vars assoc )
    "multi-method-effect" word-prop
    dup in>> [ dup pair? [ first ] when ] map
    make-locals ;

: extract-locals-definition ( word reader-quot -- word quot effect )
    dupd [ extract-locals ] dip (parse-locals-definition) ; inline

: (MM::) ( -- method def )
    [
        scan-new-method [
            [ parse-definition ] extract-locals-definition
            drop
        ] with-multi-method-definition
    ] with-definition ;

: define-typed-method ( method def -- )
    over "multi-method-effect" word-prop parse-variable-effect drop
    dup out>> f [ array? or ] reduce [
        [ in>> [ dup array? [ first ] when ] map ]
        [ out>> ]
        bi <effect> define-typed
    ] [ drop define ] if ;

SYNTAX: MM: (MM:) define-typed-method ;

SYNTAX: MM:: (MM::) define-typed-method ;

! Definition protocol. We qualify core generics here

M: multi-generic definer drop \ MGENERIC: f ;

M: multi-generic definition drop f ;

M: multi-generic forget*
    [ methods values [ forget ] each ] [ call-next-method ] bi ;

M: multi-method definer
    drop \ MM: \ ; ;

M: multi-method forget*
    [
        "method-specializer" "multi-generic"
        [ word-prop ] bi-curry@ bi forget-method
    ]
    [ call-next-method ]
    bi ;

M: multi-method synopsis*
    dup definer.
    [ "multi-generic" word-prop pprint-word ]
    [ "multi-method-effect" word-prop pprint* ]
    bi ;

SYNTAX: MM\
    scan-word scan-effect effect>specializer
    swap method <wrapper> suffix! ;

M: multi-method pprint*
    <block
    \ MM\ pprint-word
    [ "multi-generic" word-prop pprint-word ]
    [ "multi-method-effect" word-prop pprint* ]
    bi
    block> ;


! ! ! ! single ! ! ! !
ERROR: no-single-method object generic ;

PREDICATE: multi-single-generic < multi-generic
    "dispatch-type" word-prop single-dispatch? ;

M: multi-single-generic make-inline cannot-be-inline ;

GENERIC: single-dispatch# ( word -- n )

M: multi-generic single-dispatch#
    "dispatch-type" word-prop single-dispatch# ;

SYMBOL: assumed
SYMBOL: default
SYMBOL: generic-word
SYMBOL: dispatch-type

: with-dispatch-type ( dispatch-type quot -- )
     [ dispatch-type ] dip with-variable ; inline

HOOK: picker dispatch-type ( -- quot )


<PRIVATE

: interesting-class? ( class1 class2 -- ? )
    {
        ! Case 1: no intersection. Discard and keep going
        { [ 2dup classes-intersect? not ] [ 2drop t ] }
        ! Case 2: class1 contained in class2. Add to
        ! interesting set and keep going.
        { [ 2dup class<= ] [ nip , t ] }
        ! Case 3: class1 and class2 are incomparable. Give up
        [ 2drop f ]
    } cond ;

: interesting-classes ( class classes -- interesting/f )
    [ [ interesting-class? ] with all? ] { } make and ;

PRIVATE>

: method-classes ( generic -- classes )
    "dispatch-type" word-prop methods>> keys ;

: nearest-class ( class generic -- class/f )
    method-classes interesting-classes smallest-class ;

ERROR: method-lookup-failed class generic ;

: ?lookup-method ( class generic -- method/f )
    "dispatch-type" word-prop methods>> at ;

: method-for-object ( obj word -- method )
    [
        [ method-classes [ instance? ] with filter smallest-class ] keep
        ?lookup-method
    ] [ "default-method" word-prop ]
    bi or ;

: single-method-for-class ( class generic -- method/f )
    [ nip ] [ nearest-class ] 2bi
    [ swap ?lookup-method ] [ drop f ] if* ;

M: single-dispatch make-single-default-method
    [
        [ picker ] dip '[ @ _ no-single-method ]
    ] with-dispatch-type ;


! ! ! Build an engine ! ! !
: find-default ( methods -- default )
    ! Side-effects methods.
    [ object bootstrap-word ] dip delete-at* [
        drop generic-word get "default-method" word-prop
    ] unless ;

! 1. Flatten methods
TUPLE: predicate-engine class methods ;

C: <predicate-engine> predicate-engine

: push-method ( method class atomic assoc -- )
    dupd [
        [ ] [ H{ } clone <predicate-engine> ] ?if
        [ methods>> set-at ] keep
    ] change-at ;

: flatten-method ( method class assoc -- )
    over flatten-class [ swap push-method ] 2with with each ;

: flatten-methods ( assoc -- assoc' )
    H{ } clone [ [ swapd flatten-method ] curry assoc-each ] keep ;

! 2. Convert methods
: split-methods ( assoc class -- first second )
    [ [ nip class<= ] curry assoc-reject ]
    [ [ nip class<= ] curry assoc-filter ] 2bi ;

: convert-methods ( assoc class word -- assoc' )
    over [ split-methods ] 2dip pick assoc-empty?
    [ 3drop ] [ [ execute ] dip pick set-at ] if ; inline

! 2.1 Convert tuple methods
TUPLE: echelon-dispatch-engine n methods ;

C: <echelon-dispatch-engine> echelon-dispatch-engine

TUPLE: tuple-dispatch-engine echelons ;

: push-echelon ( class method assoc -- )
    [ swap dup "layout" word-prop third ] dip
    [ ?set-at ] change-at ;

: echelon-sort ( assoc -- assoc' )
    ! Convert an assoc mapping classes to methods into an
    ! assoc mapping echelons to assocs. The first echelon
    ! is always there
    H{ { 0 f } } clone [ [ push-echelon ] curry assoc-each ] keep ;

: copy-superclass-methods ( engine superclass assoc -- )
    at* [ [ methods>> ] bi@ assoc-union! drop ] [ 2drop ] if ;

: copy-superclasses-methods ( class engine assoc -- )
    [ superclasses-of ] 2dip
    [ swapd copy-superclass-methods ] 2curry each ;

: convert-tuple-inheritance ( assoc -- assoc' )
    ! A method on a superclass A might have a higher precedence
    ! than a method on a subclass B, if the methods are
    ! defined on incomparable classes that happen to contain
    ! A and B, respectively. Copy A's methods into B's set so
    ! that they can be sorted and selected properly.
    dup dup [ copy-superclasses-methods ] curry assoc-each ;

: <tuple-dispatch-engine> ( methods -- engine )
    convert-tuple-inheritance echelon-sort
    [ dupd <echelon-dispatch-engine> ] assoc-map
    tuple-dispatch-engine boa ;

: convert-tuple-methods ( assoc -- assoc' )
    tuple bootstrap-word
    \ <tuple-dispatch-engine> convert-methods ;

! 3 Tag methods
TUPLE: tag-dispatch-engine methods ;

C: <tag-dispatch-engine> tag-dispatch-engine

: <engine> ( assoc -- engine )
    flatten-methods
    convert-tuple-methods
    <tag-dispatch-engine> ;


! ! ! Compile engine ! ! !
GENERIC: compile-engine ( engine -- obj )

: compile-engines ( assoc -- assoc' )
    [ compile-engine ] assoc-map ;

: compile-engines* ( assoc -- assoc' )
    [ over assumed [ compile-engine ] with-variable ] assoc-map ;

: direct-dispatch-table ( assoc n -- table )
    default get <array> <enumerated> swap assoc-union! seq>> ;

: tag-number ( class -- n ) "type" word-prop ;

M: tag-dispatch-engine compile-engine
    methods>> compile-engines*
    [ [ tag-number ] dip ] assoc-map
    num-types get direct-dispatch-table ;

: build-fast-hash ( methods -- buckets )
    >alist V{ } clone [ hashcode 1array ] distribute-buckets
    [ compile-engines* >alist concat ] map ;

M: echelon-dispatch-engine compile-engine
    dup n>> 0 = [
        methods>> dup assoc-size {
            { 0 [ drop default get ] }
            { 1 [ >alist first second compile-engine ] }
        } case
    ] [
        methods>> compile-engines* build-fast-hash
    ] if ;

M: tuple-dispatch-engine compile-engine
    tuple assumed [
        echelons>> compile-engines
        dup keys supremum 1 + f <array>
        <enumerated> swap assoc-union! seq>>
    ] with-variable ;

PREDICATE: predicate-engine-word < word "owner-generic" word-prop ;

SYMBOL: predicate-engines

: sort-single-methods ( assoc -- assoc' )
    >alist [ keys sort-classes ] keep extract-keys ;

: quote-methods ( assoc -- assoc' )
    [ 1quotation \ drop prefix ] assoc-map ;

: find-predicate-engine ( classes -- word )
    predicate-engines get [ at ] curry map-find drop ;

: next-predicate-engine ( engine -- word )
    class>> superclasses-of
    find-predicate-engine
    default get or ;

: methods-with-default ( engine -- assoc )
    [ methods>> clone ] [ next-predicate-engine ] bi
    object bootstrap-word pick set-at ;

: keep-going? ( assoc -- ? )
    assumed get swap second first class<= ;

ERROR: unreachable ;

: prune-redundant-predicates ( assoc -- default assoc' )
    {
        { [ dup empty? ] [ drop [ unreachable ] { } ] }
        { [ dup length 1 = ] [ first second { } ] }
        { [ dup keep-going? ] [ rest-slice prune-redundant-predicates ] }
        [ [ first second ] [ rest-slice ] bi ]
    } cond ;

: class-predicates ( assoc -- assoc )
    [ [ predicate-def [ dup ] prepend ] dip ] assoc-map ;

: <engine-word> ( suffix -- word )
    generic-word get name>> prepend f <word>
    dup generic-word get "owner-generic" set-word-prop ;

! : <predicate-engine-word> ( -- word )
!     generic-word get name>> "/predicate-engine" append f <word>
!     dup generic-word get "owner-generic" set-word-prop ;

: <predicate-engine-word> ( -- word )
     "/predicate-engine" <engine-word> ;

M: predicate-engine-word stack-effect "owner-generic" word-prop stack-effect ;

: define-predicate-engine ( alist -- word )
    [ <predicate-engine-word> ] dip
    [ define ]
    [ drop generic-word get "engines" word-prop push ]
    [ drop ]
    2tri ;

: compile-predicate-engine ( engine -- word )
    methods-with-default
    sort-single-methods
    quote-methods
    prune-redundant-predicates
    class-predicates
    [ last ] [ alist>quot picker prepend define-predicate-engine ] if-empty ;

M: predicate-engine compile-engine
    [ compile-predicate-engine ] [ class>> ] bi
    [ drop ] [ predicate-engines get set-at ] 2bi ;

M: word compile-engine ;

M: f compile-engine ;

: build-decision-tree ( generic -- methods )
    [ "engines" word-prop forget-all ]
    [ V{ } clone "engines" set-word-prop ]
    [
        "dispatch-type" word-prop methods>> clone
        [ find-default default set ]
        [ <engine> compile-engine ] bi
    ] tri ;

HOOK: inline-cache-quots dispatch-type
        ( word methods -- pic-quot/f pic-tail-quot/f )

M: single-dispatch inline-cache-quots 2drop f f ;

: define-inline-cache-quot ( word methods -- )
    [ drop ] [ inline-cache-quots ] 2bi
    [ >>pic-def ] [ >>pic-tail-def ] bi*
    drop ;

HOOK: mega-cache-quot dispatch-type ( methods -- quot/f )

M: single-dispatch perform-dispatch
    [
        H{ } clone predicate-engines set
        dup generic-word set
        dup build-decision-tree
        [ "decision-tree" set-word-prop ]
        [ mega-cache-quot define ]
        [ define-inline-cache-quot ]
        2tri
    ] with-dispatch-type ;

M: multi-single-generic effective-method
    [ get-datastack ] dip
    [ "dispatch-type" word-prop #>> swap <reversed> nth ] keep
    method-for-object ;

PREDICATE: default-method < word "default" word-prop ;

:: single-default-method-word-props ( generic -- assoc )
    generic "declared-effect" word-prop :> effect
    effect in>> [
        dup array? [ first ] when object bootstrap-word 2array
    ] map
    generic "hooks" word-prop dup empty? [ drop ] [
        [
            object bootstrap-word 2array
        ] map { "|" } clone append swap append
    ] if
    effect out>>
    <effect> f generic method-word-props ; ! dummy spacializer

:: <single-default-method> ( generic dispatch-type -- method )
    f f <word> dup generic single-default-method-word-props >>props
    dup "multi-method-effect" word-prop generic method-word-name
    swap name<<
    generic dispatch-type make-single-default-method
    [ define ] [ drop t "default" set-word-prop ] [ drop ] 2tri ;

: define-single-default-method ( generic dispatch -- )
    dupd <single-default-method> "default-method" set-word-prop ;

! ! ! standard ! ! ! !
M: single-standard-dispatch check-dispatch-effect
    [ single-dispatch# ] [ in>> length ] bi* over >
    [ drop ] [ bad-dispatch-position ] if ;

PREDICATE: multi-standard-generic < multi-generic
    "dispatch-type" word-prop single-standard-dispatch? ;

PREDICATE: multi-simple-generic < multi-standard-generic
    "dispatch-type" word-prop #>> 0 = ;

M: single-standard-dispatch picker
    dispatch-type get #>> (picker) ;

M: single-standard-dispatch single-dispatch# #>> ;

M: multi-standard-generic effective-method
    [ get-datastack ] dip
    [ "dispatch-type" word-prop #>> swap <reversed> nth ] keep
    method-for-object ;

: inline-cache-quot ( word methods miss-word -- quot )
    [
        [ literalize , ] [ , ] [ dispatch-type get #>> , { } , , ] tri*
    ] [ ] make ;

M: single-standard-dispatch inline-cache-quots
    ! Direct calls to the generic word (not tail calls or indirect calls)
    ! will jump to the inline cache entry point instead of the megamorphic
    ! dispatch entry point.
    [ \ gsp:inline-cache-miss inline-cache-quot ]
    [ \ gsp:inline-cache-miss-tail inline-cache-quot ]
    2bi ;

: make-empty-cache ( -- array )
    mega-cache-size get f <array> ;

M: single-standard-dispatch mega-cache-quot
    dispatch-type get #>> make-empty-cache \ gsp:mega-cache-lookup
    [ ] 4sequence ;


! ! ! hook ! ! ! !
PREDICATE: single-hook-generic < multi-generic
    "dispatch-type" word-prop single-hook-dispatch? ;

M: single-hook-dispatch picker
    dispatch-type get var>> [ get ] curry ;

M: single-hook-dispatch single-dispatch# drop 0 ;

M: single-hook-dispatch mega-cache-quot
    1quotation picker [ gsp:lookup-method (execute) ] surround ;

M: single-hook-generic effective-method
    [ "dispatch-type" word-prop var>> get ] keep method-for-object ;


! ! ! math ! ! ! !
PREDICATE: multi-math-generic < multi-generic
    "dispatch-type" word-prop math-dispatch? ;

<PRIVATE

: bootstrap-words ( classes -- classes' )
    [ bootstrap-word ] map ;

: math-precedence ( class -- pair )
    [
        { fixnum integer rational real number object } bootstrap-words
        swap [ swap class<= ] curry find drop -1 or
    ] [
        { fixnum bignum ratio float complex object } bootstrap-words
        swap [ class<= ] curry find drop -1 or
    ] bi 2array ;

: (math-upgrade) ( max class -- quot )
    dupd = [ drop [ ] ] [ "coercer" word-prop [ ] or ] if ;

PRIVATE>

: math-class-max ( class1 class2 -- class )
    [ [ math-precedence ] bi@ after? ] most ;

: math-upgrade ( class1 class2 -- quot )
    [ math-class-max ] 2keep [ (math-upgrade) ] bi-curry@ bi
    [ dup empty? [ [ dip ] curry ] unless ] dip [ ] append-as ;

ERROR: no-multi-math-method left right generic ;

: multi-math-extended-dispatch ( generic -- quot )
    [
        [
            "multi-methods" word-prop [
                drop {
                    [ second math-class? ]
                    [ [ first ] [ second ] bi = ]
                } 1&&
            ] assoc-reject >alist
            prepare-methods % sort-methods ] keep
        multi-dispatch-quot %
    ] [ ] make ;

<PRIVATE

: (math-method) ( generic class -- quot )
    over ?lookup-method
    [ 1quotation ]
    [ multi-math-extended-dispatch ] ?if ;

PRIVATE>

: object-method ( generic -- quot )
    object bootstrap-word (math-method) ;

: multi-math-method ( word class1 class2 -- quot )
    2dup and [
        [ 2array [ declare ] curry nip ]
        [ math-upgrade nip ]
        [ math-class-max over nearest-class (math-method) ]
        3tri 3append
    ] [
        2drop object-method
    ] if ;


<PRIVATE

: make-math-method-table ( classes quot: ( ... class -- ... quot ) -- alist )
    [ bootstrap-words ] dip [ keep swap ] curry { } map>assoc ; inline

: math-alist>quot ( alist -- quot )
    [ generic-word get object-method ] dip alist>quot ;

: tag-dispatch-entry ( tag picker -- quot )
    [ "type" word-prop 1quotation [ tag ] [ eq? ] surround ] dip prepend ;

: tag-dispatch ( picker alist -- alist' )
    swap [ [ tag-dispatch-entry ] curry dip ] curry assoc-map math-alist>quot ;

: tuple-dispatch-entry ( class picker -- quot )
    [ 1quotation [ { tuple } declare class-of ] [ eq? ] surround ] dip prepend ;

: tuple-dispatch ( picker alist -- alist' )
    swap [ [ tuple-dispatch-entry ] curry dip ] curry assoc-map math-alist>quot ;

: math-dispatch-step ( picker quot: ( ... class -- ... quot ) -- quot )
    [ { bignum float fixnum } swap make-math-method-table ]
    [ { ratio complex } swap make-math-method-table tuple-dispatch ] 2bi
    tuple swap 2array prefix tag-dispatch ; inline

: fixnum-optimization ( word quot -- word quot' )
    [ dup fixnum bootstrap-word dup multi-math-method ]
    [
        ! remove redundant fixnum check since we know
        ! both can't be fixnums in this branch
        dup length 3 - cut unclip
        [ length 2 - ] [ nth ] bi prefix append
    ] bi*
    [ if ] 2curry [ 2dup both-fixnums? ] prepend ;

PRIVATE>


M: math-dispatch make-single-default-method
    drop multi-math-extended-dispatch ;

M: math-dispatch perform-dispatch
    drop dup generic-word [
        dup [ over ] [
            dup math-class? [
                [ dup ] [ multi-math-method ] 2with math-dispatch-step
            ] [
                drop object-method
            ] if
        ] with math-dispatch-step
        fixnum-optimization
        define
    ] with-variable ;

! ! ! dependencies ! ! !
: spec-boolean-table ( methods -- array )
    keys dup first length f <array> [
        [ object bootstrap-word = not ] map [ or ] 2map
    ] reduce ;

:: add-depends-on-multi-dispatch-generic ( classes generic -- )
    classes generic methods spec-boolean-table [
        [ drop object bootstrap-word ] unless
    ] 2map [ object bootstrap-word = ] reject :> classes'
    generic-dependencies get dup :> dependences
    [
        classes' [
            generic dependences [ ?class-or ] change-at
        ] each
    ] when ;

TUPLE: depends-on-next-multi-method classes generic next-multi-method ;

: add-depends-on-next-multi-method ( classes generic next-multi-method -- )
    over +conditional+ depends-on
    depends-on-next-multi-method add-conditional-dependency ;

M: depends-on-next-multi-method satisfied?
    {
        [ classes>> [ classoid? ] all? ]
        [
            [ [ classes>> ] [ generic>> ] bi ?lookup-next-multi-method ]
            [ next-multi-method>> ] bi eq?
        ]
    } 1&& ;

: add-next-multi-method-dependency ( method -- )
    [ "method-specializer" word-prop ]
    [ "multi-generic" word-prop ]
    bi
    2dup ?lookup-next-multi-method
    add-depends-on-next-multi-method ;

TUPLE: depends-on-multi-method classes generic multi-method ;

: add-depends-on-multi-method ( classes generic multi-method -- )
    over +conditional+ depends-on
    depends-on-multi-method add-conditional-dependency ;

M: depends-on-multi-method satisfied?
    {
        [ classes>> [ classoid? ] all? ]
        [
            [ [ classes>> ] [ generic>> ] bi ?lookup-multi-method ]
            [ multi-method>> ] bi eq?
        ]
    } 1&& ;

TUPLE: depends-on-partial-inline classes generic partial-inline-quot ;

: add-depends-on-partial-inline ( classes generic partial-inline-quot -- )
    over +conditional+ depends-on
    depends-on-partial-inline add-conditional-dependency ;

M:: depends-on-partial-inline satisfied? ( dependency -- ? )
    dependency {
        [ classes>> [ classoid? ] all? ]
        [
            [ classes>> ] [ generic>> ] bi :> ( classes generic )
            generic methods
            generic multi-math-generic? [
                [ drop first2 [ math-class? ] both? ] assoc-reject
            ] when
            sort-methods [
                drop classes swap t [
                    [ drop object bootstrap-word = ]
                    [ class<= ]
                    2bi or and
                ] 2reduce
            ] assoc-filter [
                [
                    classes [| c1 c2 |
                        c2 object bootstrap-word = [ c1 ] [
                            object bootstrap-word
                        ] if
                    ] 2map
                ] dip
            ] assoc-map prepare-methods drop
            generic multi-dispatch-quot
            dependency partial-inline-quot>> =
        ]
    } 1&& ;

! ! ! call-next-multi-method ! ! !
GENERIC: next-multi-method-quot* ( classes generic dispatch -- quot/f )

ERROR: inconsistent-next-multi-method classes generic ;

M: dispatch next-multi-method-quot* ( classes generic dispatch -- quot/f )
    [
        2dup ?lookup-next-multi-method [
            [
                pick multi-predicate %
                1quotation , '[ _ _ inconsistent-next-multi-method ] ,
                \ if ,
            ] [ ] make
        ] [ 2drop f ] if*
    ] with-dispatch-type ;

ERROR: call-next-multi-method-in-a-math-generic generic ;

M: call-next-multi-method-in-a-math-generic summary
    drop
    "call-next-multi-method can not be used in mathematical multi-methods" ;

M:: math-dispatch next-multi-method-quot* ( classes generic dispatch -- * )
    generic call-next-multi-method-in-a-math-generic ;

: next-multi-method-quot ( method -- quot/f )
    next-multi-method-quot-cache get [
        [ "method-specializer" word-prop ]
        [
            "multi-generic" word-prop
            dup "dispatch-type" word-prop
        ] bi next-multi-method-quot*
    ] cache
 ;

ERROR: no-next-multi-method method ;

ERROR: not-in-a-multi-method-error ;

M: not-in-a-multi-method-error summary
    drop
    "call-next-multi-method can only be called in a multi-method definition" ;

: call-next-multi-method-quot ( quot -- )
    ! This is a word to avoid a compiler error.
    drop ;

: (call-next-multi-method) ( method -- )
    ! The content of this definition is actually replaced and never used.
    dup next-multi-method-quot [
        call-next-multi-method-quot
    ] [ no-next-multi-method ] ?if ;

\ (call-next-multi-method) [
    [ add-next-multi-method-dependency ]
    [
        [ next-multi-method-quot ]
        [ '[ _ no-next-multi-method ] ] bi or
    ] bi
] 1 define-transform

\ (call-next-multi-method) t "no-compile" set-word-prop

SYNTAX: call-next-multi-method
   current-multi-method get
   [ literalize suffix! \ (call-next-multi-method) suffix! ]
   [ not-in-a-multi-method-error ] if* ;


! ! ! annotations ! ! !
M: multi-generic (reset)
    "multi-methods" word-prop values [ (reset) ] each ;

: annotate-multi-generic ( word quot -- )
    [ "multi-methods" word-prop values ] dip each ; inline

M: multi-generic (annotate)
    '[ _ (annotate) ] annotate-multi-generic ;

M: multi-generic (deep-annotate)
    '[ _ (deep-annotate) ] annotate-generic ;


! ! ! covariant-tuple ! ! !
! Most of the code is copied from Timor's PR #2430 "Multiple dispatch with existing
! inline cache infrastructure and abstractions for dispatch specifciers"

! Called in compiler context when generic word is encountered, can throw errors.
GENERIC: check-generic ( generic -- )

M: word check-generic drop ;

M: covariant-tuple implementor-classes classes>> ;

! If set to true, create a level of nesting for nested dispatchers to generate
! PIC-enabled call sites.  Naive test indicated that the additional level was
! more overhead, and that the megamorphic hit was faster.  This could change
! significantly depending on dispatch complexity though
SYMBOL: nested-dispatch-pics

PREDICATE: covariant-tuple-multi-method < multi-method "method-class" word-prop covariant-tuple? ;

TUPLE: method-dispatch class method ;
C: <method-dispatch> method-dispatch

GENERIC: method-types ( method -- seq )
! TODO: maybe don't use covariant dispatch tuple here anymore?  We may need
! sorting, though...
M: method-dispatch method-types class>> classes>> ;
M: object method-types "nope" throw ;

GENERIC: dispatch-arity ( method -- n )
M: class dispatch-arity drop 1 ;
M: covariant-tuple dispatch-arity classes>> length ;

: nth-type ( n method -- seq ) method-types nth ;

: method-applicable? ( class index method -- ? ) nth-type class<= ;

! TODO: this should probably be replaced with functionality from classes.algebra
:: dispatch<=> ( class1 class2 -- <=> )
    class1 class2 [ normalize-class ] bi@ :> ( c1 c2 )
    c1 c2 compare-classes dup +incomparable+ =
    [ drop c1 c2 [ rank-class ] compare dup +eq+ =
      [ drop c1 c2 [ class-name ] compare ] when
    ] when ;

! sort methods for applicability on specific index
:: sort-methods-index ( methods index -- methods )
    methods [ [ index swap nth-type ] bi@ dispatch<=> ] sort ;

: applicable-methods ( class index methods -- seq )
    [ [ method-applicable? ] 2with filter ] keepd sort-methods-index ;

! * Dispatch engine implementation

! TODO: check sorting
: method-dispatch-classes ( n methods -- seq )
    [ nth-type ] with map members ;

:: covariant-tuple-multi-methods ( methods n -- assoc )
    n 0 >=
    [ n methods method-dispatch-classes
      [ dup n methods applicable-methods
        n 1 - covariant-tuple-multi-methods
      ] map>alist ] [
        ! NOTE: This is where we rely on correct non-ambigutiy
        methods ?last [ method>> ] [ f ] if*
    ] if ;

GENERIC: promote-dispatch-class ( arity class -- class )
M: class promote-dispatch-class
    1array swap object pad-head <covariant-tuple> ;
ERROR: too-many-dispatch-args arity class ;
M: covariant-tuple promote-dispatch-class
    dup classes>> length pick <=> {
        { +lt+ [ classes>> swap object pad-head <covariant-tuple> ] }
        { +eq+ [ nip ] }
        { +gt+ [ too-many-dispatch-args ] }
    } case ;

! NOTE: Single use, should be generic if ever used to promote generally?
: class>dispatch ( class -- dispatch-class )
    dup covariant-tuple? [ 1array <covariant-tuple> ] unless ;

: methods>dispatch ( arity assoc -- seq )
    ! NOTE: not using smart-with due to dependency issues
    ! [ [ promote-dispatch-class ] dip <method-dispatch> ] smart-with { } assoc>map ;
    [ swapd [ promote-dispatch-class ] dip <method-dispatch> ] with { } assoc>map ;


:: methods>multi-methods ( arity assoc -- assoc )
    ! assoc [ [ arity swap promote-dispatch-class ] dip ] assoc-map
    arity assoc methods>dispatch
    [ f ]
    [ arity 1 -  covariant-tuple-multi-methods ] if-empty ;

! This is used to keep track of nesting during engine tree construction, as well
! as to be able to use inline-cache-quots, where it has to be set to the correct
! index.  That last part is a bit of a workaround just to avoid code duplication.
SYMBOL: current-index
current-index [ 0 ] initialize
TUPLE: nested-dispatch-engine < tag-dispatch-engine index ;

DEFER: flatten-multi-methods
: <nested-dispatch-engine> ( methods -- obj )
    current-index get 1 +
    [ current-index [ flatten-multi-methods ] with-variable
    ] keep nested-dispatch-engine boa ;

: flatten-multi-methods ( methods -- methods' )
    [ dup assoc?
      [ <nested-dispatch-engine> ] when
    ] assoc-map ;

PREDICATE: nested-dispatch-engine-word < predicate-engine-word
    "nested-dispatch-engine" word-prop ;

: <nested-dispatch-engine-word> ( -- word )
    "/dispatch" <engine-word>
    dup t "nested-dispatch-engine" set-word-prop
    ;

! This is one level of indirection to ensure that we have a PIC in the nested
! dispatch calls, which would not be compiled in otherwise.
: <pic-callsite-wrapper> ( -- word )
    "/callsite" <engine-word> ;

: add-engine ( quot word -- word )
    swap [ define ]
    [ drop [ generic-word get "engines" word-prop push ] keep ] 2bi ;

: wrap-nested-dispatch-call-site ( word -- word )
    1quotation <pic-callsite-wrapper> add-engine ;

: engine-cache-quotation ( engine -- quot )
    [ methods>> ] [ index>> ] bi make-empty-cache \ gsp:mega-cache-lookup [ ] 4sequence ;

: define-nested-dispatch-engine ( engine -- word )
    ! TODO: Why no fry? Dependencies?
    dup engine-cache-quotation <nested-dispatch-engine-word> add-engine
    ! setting current-index here for inline-cache-quots
    over index>> current-index
    [ [ swap methods>> define-inline-cache-quot ] keep ] with-variable ;

! In nested context, we reset the predicate-engines table so it will be
! populated with the default method of this subtree.
! NOTE: not pruning the tree here like find-default does, though
:: with-nested-engine ( engine quot: ( ..a engine -- ..b ) -- ..b )
    engine index>>
    dup 0 > [ engine methods>> object of default get or ] [ default get ] if
    H{ } clone 3array { current-index default predicate-engines } swap zip >hashtable
    [ engine quot call ] with-variables ; inline

M: nested-dispatch-engine compile-engine
    dup [
        [ flatten-methods convert-tuple-methods ] change-methods
        call-next-method
    ] with-nested-engine
    >>methods
    define-nested-dispatch-engine
    nested-dispatch-pics get [ wrap-nested-dispatch-call-site ] when ;

! * Method combination interface
! TUPLE: covariant-tuple-dispatch < non-multi-dispatch ;
CONSTANT: nary-combination T{ covariant-tuple-dispatch f f }
M: covariant-tuple-dispatch mega-cache-quot
    0 make-empty-cache \ gsp:mega-cache-lookup [ ] 4sequence ;


! FIXME: almost copy-paste from standard-combination

: multi-inline-cache-quot ( word methods miss-word -- quot )
    [ [ literalize , ] [ , ] [ current-index get , { } , , ] tri* ] [ ] make ;

M: covariant-tuple-dispatch inline-cache-quots
    [ \ gsp:inline-cache-miss multi-inline-cache-quot ]
    [ \ gsp:inline-cache-miss-tail multi-inline-cache-quot ] 2bi ;

M: covariant-tuple-dispatch picker current-index get (picker) ;

PREDICATE: covariant-tuple-multi-generic < multi-generic
    "dispatch-type" word-prop covariant-tuple-dispatch? ;

ERROR: not-single-dispatch generic ;
M: covariant-tuple-multi-generic single-dispatch# not-single-dispatch ;


! Dispatch is ambiguous if there is an intersection but no strict local order.
! In the case of symmetric dispatch, these pairs may exist, but only if they are
! never called or a more-specific tie-breaker also exists.
! FIXME: used cartesian-map instead of map-combinations because of bootstrapping
! dependency problems.  This means we have a lot of unnecessary comparisons.
: ambiguous-dispatch-classes ( dispatch-classes -- dispatch-classes )
    dup [
        2dup classes-intersect?
        [ 2dup compare-classes +incomparable+ =
          [ 2array ] [ 2drop f ] if
        ] [ 2drop f ] if
    ] cartesian-map concat sift
    [ first2 [ classes>> ] bi@ [ class-and ] 2map <covariant-tuple> ] map
    members
    ;

! This is the equivalent of predicate-def but for covariant-tuples in dispatch
! context
: dispatch-predicate-def ( covariant-tuple -- quot )
    classes>> <reversed>
    [ 1 + swap '{ [ _ npick _ instance? not ] [ f ] } ] map-index
    [ t ] suffix
    '[ _ cond ] ;

! M: covariant-tuple-dispatch next-method-quot*
!     drop [ class>dispatch ] dip
!     { [ drop dispatch-predicate-def ]
!       [ next-method 1quotation ]
!     } 2cleave
!     '[ _ _ [ inconsistent-next-method ] if ] ;

ERROR: ambiguous-method-specializations classes ;

! Check all dispatch tuple specs for ambiguous intersections.  Keep those that
! do not have a resolver and add a compilation error.
: check-ambiguity ( generic -- )
    "dispatch-type" word-prop methods>> keys [ class>dispatch ] map
    [ ambiguous-dispatch-classes ] keep
    [ [ class= ] with any? ] curry reject
    [ ambiguous-method-specializations ] unless-empty ;

M: covariant-tuple-multi-generic check-generic check-ambiguity ;

! We ensure that the "methods" word property is always sorted.
! The idea is to not have to do this again during compilation or lookup.
! TODO: currently not taken advantage of
: sort-generic-methods ( generic -- )
    "dispatch-type" word-prop [
        sort-single-methods >vector
    ] change-methods drop ;

! M: covariant-tuple-multi-generic update-generic
!     [ nip sort-generic-methods ]
!     [ call-next-method ] 2bi ;

! * Build Decision Tree
: multi-generic-arity ( generic -- n )
    "dispatch-type" word-prop methods>> keys [ dispatch-arity ] map [ 1 ] [ supremum ] if-empty ;

! FIXME: almost copy-paste from single-combination, need abstraction
: build-multi-decision-tree ( generic -- mega-cache-assoc )
    [ "engines" word-prop forget-all ]
    [ V{ } clone "engines" set-word-prop ]
    [
        [ multi-generic-arity ]
        [ "dispatch-type" word-prop methods>> clone
          dup find-default default set
        ] bi methods>multi-methods
        flatten-multi-methods
        compile-engines*
        <engine> compile-engine 
    ] tri ;

! FIXME: almost copy-paste from single-combination, need abstraction
M: covariant-tuple-dispatch perform-dispatch
    [
        H{ } clone predicate-engines set
        dup generic-word set
        dup build-multi-decision-tree
        [ "decision-tree" set-word-prop ]
        [ mega-cache-quot define ]
        [ define-inline-cache-quot ]
        2tri
    ] with-dispatch-type ;

! * TODO Next-method, method lookup and compiler support
ERROR: ambiguous-multi-dispatch classes ;
: assert-non-ambiguity ( sorted-methods -- )
    ! NOTE: simulating && combinator here due to dependency issues
    ! { [ length 1 > ]
    !   [ <reversed> first2 [ first ] bi@ class< not ]
    !   [ ambiguous-multi-dispatch ] } && drop ;
    dup length 1 >
    [ dup <reversed> first2 [ first ] bi@ class< not
      [ ambiguous-multi-dispatch ]
      [ drop ] if
    ] [ drop ] if ;

M: covariant-tuple-dispatch make-single-default-method
    [
        [ methods ] keep
        [ argument-count ] dip [ [ narray ] dip no-method ] 2curry
    ] with-dispatch-type ;

M: covariant-tuple add-depends-on-class
    classes>> [ add-depends-on-class ] each ;

: make-cached-multi ( word -- )
    dup multi-generic? [
        t "cached-multi" set-word-prop
    ] [ drop ] if ;

SYNTAX: cached-multi last-word make-cached-multi ;
