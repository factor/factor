USING: accessors arrays assocs classes classes.algebra classes.algebra.private
classes.private combinators definitions effects effects.parser
generic generic.parser generic.single generic.single.private generic.standard
kernel make math math.order namespaces parser quotations sequences sets sorting
vectors words ;

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
    ! NOTE: not using smart-with due to dependency issues
    ! [ [ promote-dispatch-class ] dip <method-dispatch> ] smart-with { } assoc>map ;
    [ swapd [ promote-dispatch-class ] dip <method-dispatch> ] with { } assoc>map ;


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
    ! NOTE: simulating && combinator here due to dependency issues
    ! { [ length 1 > ]
    !   [ <reversed> first2 [ first ] bi@ class< not ]
    !   [ ambiguous-multi-dispatch ] } && drop ;
    dup length 1 >
    [ dup <reversed> first2 [ first ] bi@ class< not
      [ ambiguous-multi-dispatch ]
      [ drop ] if
    ] [ drop ] if ;

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
