USING: accessors arrays assocs classes.algebra classes.dispatch
classes.dispatch.covariant-tuples classes.dispatch.order combinators definitions
effects effects.parser generic generic.parser generic.single
generic.single.private generic.standard hashtables kernel make math namespaces
parser quotations sequences sets vectors words ;

IN: generic.multi

FROM: namespaces => set ;

! If set to true, create a level of nesting for nested dispatchers to generate
! PIC-enabled call sites.  Naive test indicated that the additional level was
! more overhead, and that the megamorphic hit was faster.  This could change
! significantly depending on dispatch complexity though
SYMBOL: nested-dispatch-pics

PREDICATE: multi-method < method "method-class" word-prop covariant-tuple? ;

TUPLE: method-dispatch { class maybe{ dispatch-type } read-only } { method read-only } ;
C: <method-dispatch> method-dispatch

:: applicable-methods ( class index methods -- assoc )
    methods [ class>> :> dispatch-type
              class index dispatch-type nth-dispatch-applicable?
              [ index dispatch-type nth-dispatch-class ] [ f ] if
    ] sort-dispatch values concat ;

! * Dispatch engine implementation

: method-dispatch-classes ( n methods -- seq )
    [ class>> nth-dispatch-class ] with map members ;

! FIXME: input is seq of method-dispatches
:: multi-methods ( methods n arity -- assoc )
    n arity <
    [ n methods method-dispatch-classes
    [ dup n methods applicable-methods
      n 1 + arity multi-methods
    ] map>alist ] [
        ! NOTE: This is where we rely on correct non-ambigutiy
        methods ?last [ method>> ] [ f ] if*
    ] if ;

: methods>dispatch ( assoc -- seq )
    [ <method-dispatch> ] {  } assoc>map ;

:: methods>multi-methods ( arity assoc -- assoc )
    assoc methods>dispatch
    [ f ] [ 0 arity multi-methods ] if-empty ;

! This is used to keep track of nesting during engine tree construction, as well
! as to be able to use inline-cache-quots, where it has to be set to the correct
! index.  That last part is a bit of a workaround just to avoid code duplication.
SYMBOL: current-index
current-index [ 0 ] initialize
TUPLE: nested-dispatch-engine < tag-dispatch-engine index ;

DEFER: flatten-multi-methods
: <nested-dispatch-engine> ( methods -- obj )
    current-index get 1 +
    ! setting current-index here for picker
    [ current-index [ flatten-multi-methods ] with-variable
    ] keep nested-dispatch-engine boa ;

! Preprocessing step.  Creates nested engine words so that flatten methods can
! then operate and create the predicate engines
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

M: multi-combination next-method-quot*
    drop
    { [ drop dispatch-predicate-def ]
      [ next-method 1quotation ]
    } 2cleave
    '[ _ _ [ inconsistent-next-method ] if ] ;

ERROR: ambiguous-method-specializations classes ;

! Check all dispatch tuple specs for ambiguous intersections.  Keep those that
! do not have a resolver and add a compilation error.
: check-ambiguity ( generic -- )
    "methods" word-prop keys
    [ ambiguous-dispatch-types ] keep
    [ [ class= ] with any? ] curry reject
    [ ambiguous-method-specializations ] unless-empty ;

M: multi-generic check-generic check-ambiguity ;

! We ensure that the "methods" word property is always sorted.
! The idea is to not have to do this again during compilation or lookup.
! TODO: currently not taken advantage of
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

! Since we decided that dispatch types cannot be ordered with regular classes,
! all regularly defined single method classes need to be promoted.
: ensure-method-dispatch-types ( generic -- )
    "methods" [ [ [ class>dispatch ] dip ] assoc-map ] change-word-prop ;

! FIXME: almost copy-paste from single-combination, need abstraction
M: multi-combination perform-combination
    [
        H{ } clone predicate-engines set
        dup ensure-method-dispatch-types
        dup generic-word set
        dup build-multi-decision-tree
        [ "decision-tree" set-word-prop ]
        [ mega-cache-quot define ]
        [ define-inline-cache-quot ]
        2tri
    ] with-combination ;

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
