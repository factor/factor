USING: accessors arrays assocs classes classes.algebra classes.algebra.private
classes.private combinators combinators.short-circuit
combinators.short-circuit.smart combinators.smart definitions effects
effects.parser generic generic.parser generic.single generic.single.private
generic.standard kernel layouts make math math.order namespaces parser
quotations see sequences sequences.zipped sets sorting vectors words ;

IN: generic.multi

FROM: namespaces => set ;

! If set to true, create a level of nesting for nested dispatchers to generate
! PIC-enabled call sites.  Naive test indicated that the additional level was
! more overhead, and that the megamorphic hit was faster.  This could change
! significantly depending on dispatch complexity though
SYMBOL: nested-dispatch-pics

PREDICATE: multi-method < method "method-class" word-prop covariant-tuple? ;

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

: tuple-echelon ( class -- n ) "layout" word-prop third ;

! DOING: wrapping class/method pairs into a wrapper because we need to modify
! the class
: nth-type ( n method -- seq ) method-types nth ;

: echelon-method? ( class index method -- ? ) nth-type [ tuple-echelon ] same? ;

: method-applicable? ( class index method -- ? ) nth-type class<= ;

: tuple-dispatch? ( method -- ? ) method-types [ tuple class<= ] all? ;

: echelon-methods ( class index methods -- seq )
    [ { [ echelon-method? ] [ method-applicable? ] } && ] 2with filter ;

: direct-methods ( class index methods -- seq ) [ nth-type class= ] 2with filter ;

! Covariant dispatch tuple
: method<= ( method1 method2 -- ? )
    [ method-types ] bi@
    { [ [ class<= ] 2all? ]
      [ <zipped> [ first2 class< ] any? ] } 2&& ;

! Strict checking
: method-index< ( method1 method2 n -- ? )
    '[ _ swap nth-type ] bi@ class< ;

! ! Associate dispatch classes to methods
! : methods-classes ( methods -- assoc )
!     [ dup method-types ] map>alist ;

: assign-dispatch-class ( classes -- echelon classes' )
    unclip tuple-echelon swap ;

: dispatch-methods ( index methods -- assoc )
    [ [ method-types nth ] keep ] with map>alist ;
    ! flatten-methods ;

: make-dispatch-tree? ( methods index -- res )
    {
        [ drop length 1 > ]
        [ [ first method-types length ] dip > ]
    } && ;
    ! { [ drop empty? not ] [ [ methlengh ] ] }
    ! over empty?
    ! [ 2drop f ]
    ! [ swap first method-types length < ] if ;

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

:: make-dispatch-tree ( methods index  -- res )
    methods index sort-methods-index :> methods
    methods [ method-types index swap nth ] map members
    ! [ flatten-class ] gather
    sort-classes
    [| class |
     ! class tuple-echelon :> echelon
     class index methods [ direct-methods ] [ applicable-methods ] 3bi over diff
     :> ( this-echelon rest-methods )
     this-echelon rest-methods union index 1 + make-dispatch-tree?
     [ class this-echelon rest-methods union index 1 + make-dispatch-tree 2array ]
     ! Combine into a single list for now
     ! [ class this-echelon rest-methods 3array ] if
     [ class this-echelon rest-methods union 2array ] if
    ] map ;

: rebalance-inheritance ( class assoc -- assoc )
    clone >vector
    over [ nip class<= ] curry assoc-partition
    swapd [ set-at ] keep
    ! [ keys sort-classes ] [ >alist ] bi extract-keys
    ;

: generic-dispatch-tree ( generic -- tree )
    methods 0 make-dispatch-tree ;

! * Building the engines

TUPLE: tuple-dispatcher assoc n ;
C: <tuple-dispatcher> tuple-dispatcher
TUPLE: tag-dispatcher < tuple-dispatcher ;
C: <tag-dispatcher> tag-dispatcher
TUPLE: external-dispatcher < tuple-dispatcher ;
C: <external-dispatcher> external-dispatcher

: new-dispatcher ( assoc n class -- obj )
    new swap >>n swap >>assoc ;

! cache engines on dispatch index and remaining possibilities
SYMBOL: handled-dispatch

: flat-dispatch? ( subtree -- ? )
    [ sequence? not ] all? ;

ERROR: no-dispatch-error tree ;

! each index gets their own cache
: new-cache ( cache class tree n -- cache class tree n )
    [ V{ } clone suffix ] 3dip ;

: diff-cached ( cache class tree n -- cache class tree n )
    ! over hashtable?
    ! [
        [ pick last diff ] dip
    ! ] unless
    ;

: push-cache ( cache class obj tree -- cache class obj )
    dup flat-dispatch? [ reach last push-all ] [ drop ] if ;

DEFER: build-dispatch-assoc
: build-dispatch ( cache tree n type -- dispatcher )
    [ [ build-dispatch-assoc ] keep ] dip new-dispatcher ;

: build-tag-dispatcher ( cache tree n -- dispatcher )
    [ tuple swap rebalance-inheritance ] dip
    tag-dispatcher build-dispatch ;

: build-tuple-dispatcher ( cache tree n -- dispatcher )
    tuple-dispatcher build-dispatch ;

! This is right now using factor's class sorting for breaking ambiguity.  This
! means this place can not be used to check for ambiguities with the current
! linearization/inheritance model
: resolve-ambiguity ( tree n -- dispatcher )
    sort-methods-index first ;
    ! [  ]

    ! Check for strict linear specificness
    ! [ dup 2 <clumps> ] dip '[ first2 _ method-index< ] all?
    ! [ first ]
    ! [ no-dispatch-error ] if ;

: tuple-subtree? ( class subtree n -- class subtree n ? )
    pick tuple =
    [ over flat-dispatch? not ]
    [ f ] if ;

! TODO: handle predicates
: build-dispatch-assoc ( cache tree n -- assoc )
    [                      ! cache [ class subtree n ]
        ! break
        diff-cached
        [ {
                { [ over assoc-empty? ] [ 2drop f ] }
                { [ tuple-subtree? ] [ [ over ] 2dip build-tuple-dispatcher ] }
                { [ over flat-dispatch? not ]
                  [ 1 + [ over V{ } clone suffix ] 2dip build-tag-dispatcher ] }
                { [ over length 1 = ] [ drop first ] }
                { [ over length 1 > ] [ resolve-ambiguity ] }
            } cond ] keepd ! cache [ class dispatcher subtree ]
        ! push-cache
        drop
    ] curry assoc-map nip ;

: make-dispatch ( tree -- dispatcher )
    V{ } clone 1array swap 0 build-tag-dispatcher ;

! * Compiling the dispatchers
SYMBOL: default-method
SYMBOL: engines
engines [ H{  } clone ] initialize
GENERIC: compile-dispatcher* ( dispatcher -- obj )
DEFER: flatten-dispatch
DEFER: compile-dispatcher
GENERIC: flatten-dispatch* ( dispatcher -- obj )
M: object flatten-dispatch* ;
M: tuple-dispatcher flatten-dispatch*
    [ flatten-dispatch ] change-assoc ;
M: tag-dispatcher flatten-dispatch*
    compile-dispatcher ;

: flatten-dispatch ( assoc -- assoc )
    [ flatten-dispatch*
    ] assoc-map ;

: compile-dispatcher ( dispatcher -- obj )
    [ flatten-dispatch ] change-assoc
    compile-dispatcher* ;

: multi-mega-cache-quot ( methods n -- quot )
    make-empty-cache \ mega-cache-lookup [ ] 4sequence ;

: new-dispatcher-word ( dispatcher quotation -- word )
    "dispatch"  <uninterned-word>
    engines get [ set-at ] keepd
    swap "dispatcher" [ set-word-prop ] keepdd ;

! ** Tag Dispatcher
! Main type of dispatcher, compiles down to a mega-cache-lookup quotation
M: tag-dispatcher compile-dispatcher*
    dup
    [
        assoc>> [ [ tag-number ] dip ] assoc-map
        num-types get default-method get <array> <enumerated> swap assoc-union! seq>>
    ] [ n>> ] bi
    multi-mega-cache-quot new-dispatcher-word ;

! ** Tuple Dispatcher
! Compiles down to a subtree inside the tag dispatcher

M: tuple-dispatcher compile-dispatcher*
    assoc>> echelon-sort ;

! * Interface
: make-multi-dispatch ( generic -- word engines )
    H{ } clone engines [
        generic-dispatch-tree
        make-dispatch
        compile-dispatcher engines get
    ] with-variable ;


! * Dispatch engine implementation

! TODO: check sorting
: method-dispatch-classes ( n methods -- seq )
    [ nth-type ] with map members ;

:: multi-methods ( methods n -- assoc )
    n 0 >=
    [ n methods method-dispatch-classes
    [ dup n methods applicable-methods
      dup length 1 >
      [ n 1 - multi-methods ]
      ! TODO check sorting
      [ ?first method>> ] if
    ] map>alist ] [
        ! NOTE: This is where we rely on correct non-ambigutiy
        methods ?first method>>
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

: methods>dispatch ( arity assoc -- seq )
    [ [ promote-dispatch-class ] dip <method-dispatch> ] smart-with { } assoc>map ;


:: methods>multi-methods ( arity assoc -- assoc )
    ! assoc [ [ arity swap promote-dispatch-class ] dip ] assoc-map
    arity assoc methods>dispatch
    [ f ]
    [ arity 1 -  multi-methods ] if-empty ;

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
    [ methods>> ] [ index>> ] bi make-empty-cache \ mega-cache-lookup [ ] 4sequence ;

: define-nested-dispatch-engine ( engine -- word )
    ! TODO: Why no fry? Dependencies?
    dup engine-cache-quotation <nested-dispatch-engine-word> add-engine
    ! setting current-index here for inline-cache-quots
    over index>> current-index
    [ [ swap methods>> define-inline-cache-quot ] keep ] with-variable ;

M: nested-dispatch-engine compile-engine
    [ flatten-methods convert-tuple-methods ] change-methods
    dup dup index>> current-index [ call-next-method ] with-variable
    >>methods
    define-nested-dispatch-engine
    nested-dispatch-pics get [ wrap-nested-dispatch-call-site ] when
    ;

! * Method combination interface
TUPLE: multi-combination ;
CONSTANT: nary-combination T{ multi-combination f }
M: multi-combination mega-cache-quot
    0 make-empty-cache \ mega-cache-lookup [ ] 4sequence ;


! FIXME: almost copy-paste from standard-combination

: multi-inline-cache-quot ( word methods miss-word -- quot )
    [ [ literalize , ] [ , ] [ current-index get , { } , , ] tri* ] [ ] make ;

M: multi-combination inline-cache-quots
    [ \ inline-cache-miss multi-inline-cache-quot ]
    [ \ inline-cache-miss-tail multi-inline-cache-quot ] 2bi ;

M: multi-combination picker current-index get (picker) ;

PREDICATE: multi-generic < generic
    "combination" word-prop multi-combination? ;

ERROR: not-single-dispatch generic ;
M: multi-generic dispatch# not-single-dispatch ;

! We ensure that the "methods" word property is always sorted.
! The idea is to not have to do this again during compilation or lookup.
: sort-generic-methods ( generic -- )
    "methods" [ sort-methods >vector ] change-word-prop ;

M: multi-generic update-generic
    [ nip sort-generic-methods ]
    [ call-next-method ] 2bi ;

! * Build Decision Tree
: multi-generic-arity ( generic -- n )
    "methods" word-prop keys [ dispatch-arity ] map [ 1 ] [ supremum ] if-empty ;

! FIXME: almost copy-paste from single-combination, need abstraction
: build-multi-decision-tree ( generic -- mega-cache-assoc )
    [ "engines" word-prop forget-all ]
    [ V{ } clone "engines" set-word-prop ]
    [
        [ multi-generic-arity ]
        [ "methods" word-prop clone
          dup find-default default set
        ] bi methods>multi-methods
        flatten-multi-methods
        compile-engines*
        <engine> compile-engine 
    ] tri ;

! FIXME: almost copy-paste from single-combination, need abstraction
M: multi-combination perform-combination
    [
        H{ } clone predicate-engines set
        dup generic-word set
        dup build-multi-decision-tree
        [ "decision-tree" set-word-prop ]
        [ mega-cache-quot define ]
        [ define-inline-cache-quot ]
        2tri
    ] with-combination ;

! * TODO Next-method, method lookup and compiler support
ERROR: ambiguous-multi-dispatch classes ;
: assert-non-ambiguity ( sorted-methods -- )
    { [ length 1 > ]
      [ <reversed> first2 [ first ] bi@ class< not ]
      [ ambiguous-multi-dispatch ] } && drop ;

! Relies on "methods" being a sorted assoc
: multi-method-for-class ( class generic -- method/f )
    "methods" word-prop [ first class<= ] with filter
    dup assert-non-ambiguity
    ?last [ second ] [ f ] if*  ;

! * Syntax
ERROR: empty-dispatch-spec seq ;
: assert-dispatch-types ( seq -- seq )
    dup empty? [ empty-dispatch-spec ] when ;

: >multi-combination ( combination -- )
    dup multi-combination?
    [ drop ] [ nary-combination "combination" set-word-prop ] if ;

: create-multi-method-in ( class generic -- method )
    [ create-method-in ] keep >multi-combination ;

: scan-new-multi-method ( -- method )
    scan-word
    scan-effect effect-in-types assert-dispatch-types
    [ bootstrap-word ] map <covariant-tuple> swap create-multi-method-in ;


: (MM:) ( -- method def )
    [
        scan-new-multi-method [ parse-definition ] with-method-definition
    ] with-definition ;

SYNTAX: MM: (MM:) define ;
