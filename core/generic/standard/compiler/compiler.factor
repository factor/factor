! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs classes.algebra math combinators
generic.standard.engines hashtables kernel kernel.private layouts
namespaces sequences words sorting quotations effects
generic.standard.private words.private ;
IN: generic.standard.compiler

! ! ! Build an engine ! ! !

! 1. Flatten methods
TUPLE: predicate-engine methods ;

: <predicate-engine> ( methods -- engine ) predicate-engine boa ;

: push-method ( method specializer atomic assoc -- )
    [
        [ H{ } clone <predicate-engine> ] unless*
        [ methods>> set-at ] keep
    ] change-at ;

: flatten-method ( class method assoc -- )
    [ [ flatten-class keys ] keep ] 2dip [
        [ spin ] dip push-method
    ] 3curry each ;

: flatten-methods ( assoc -- assoc' )
    H{ } clone [ [ flatten-method ] curry assoc-each ] keep ;

! 2. Convert methods
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
    H{ } clone [ [ push-echelon ] curry assoc-each ] keep ;

: <tuple-dispatch-engine> ( methods -- engine )
    echelon-sort
    [ dupd <echelon-dispatch-engine> ] assoc-map
    \ tuple-dispatch-engine boa ;

: convert-tuple-methods ( assoc -- assoc' )
    tuple bootstrap-word
    \ <tuple-dispatch-engine> convert-methods ;

! 2.2 Convert hi-tag methods
TUPLE: hi-tag-dispatch-engine methods ;

C: <hi-tag-dispatch-engine> hi-tag-dispatch-engine

: convert-hi-tag-methods ( assoc -- assoc' )
    \ hi-tag bootstrap-word
    \ <hi-tag-dispatch-engine> convert-methods ;

! 3 Tag methods
TUPLE: tag-dispatch-engine methods ;

C: <tag-dispatch-engine> tag-dispatch-engine

: <engine> ( assoc -- engine )
    flatten-methods
    convert-tuple-methods
    convert-hi-tag-methods
    <tag-dispatch-engine> ;

! ! ! Compile engine ! ! !
SYMBOL: assumed
SYMBOL: default
SYMBOL: generic-word

GENERIC: compile-engine ( engine -- obj )

: compile-engines ( assoc -- assoc' )
    [ compile-engine ] assoc-map ;

: compile-engines* ( assoc -- assoc' )
    [ over assumed [ compile-engine ] with-variable ] assoc-map ;

: direct-dispatch-table ( assoc n -- table )
    default get <array> [ <enum> swap update ] keep ;

M: tag-dispatch-engine compile-engine
    methods>> compile-engines*
    [ [ tag-number ] dip ] assoc-map
    num-tags get direct-dispatch-table ;

: hi-tag-number ( class -- n ) "type" word-prop ;

: num-hi-tags ( -- n )
    num-types get num-tags get - ;

M: hi-tag-dispatch-engine compile-engine
    methods>> compile-engines*
    [ [ hi-tag-number num-tags get - ] dip ] assoc-map
    num-hi-tags direct-dispatch-table ;

: build-fast-hash ( methods -- buckets )
    >alist V{ } clone [ hashcode 1array ] distribute-buckets
    [ compile-engines* >alist >array ] map ;

M: echelon-dispatch-engine compile-engine
    methods>> compile-engines* build-fast-hash ;

M: tuple-dispatch-engine compile-engine
    tuple assumed [
        echelons>> compile-engines
        dup keys supremum f <array> default get prefix
        [ <enum> swap update ] keep
    ] with-variable ;

: sort-methods ( assoc -- assoc' )
    >alist [ keys sort-classes ] keep extract-keys ;

: literalize-methods ( assoc -- assoc' )
    [ [ ] curry \ drop prefix ] assoc-map ;

: methods-with-default ( engine -- assoc )
    methods>> clone default get object bootstrap-word pick set-at ;

: keep-going? ( assoc -- ? )
    assumed get swap second first class<= ;

: prune-redundant-predicates ( assoc -- default assoc' )
    {
        { [ dup empty? ] [ drop [ "Unreachable" throw ] { } ] }
        { [ dup length 1 = ] [ first second { } ] }
        { [ dup keep-going? ] [ rest-slice prune-redundant-predicates ] }
        [ [ first second ] [ rest-slice ] bi ]
    } cond ;

: class-predicates ( assoc -- assoc )
    [ [ "predicate" word-prop picker prepend ] dip ] assoc-map ;

: predicate-engine-effect ( -- effect )
    (dispatch#) get 1+ dup 1+ <effect> ;

: define-predicate-engine ( alist -- word )
    [ generic-word get name>> "/predicate-engine" append f <word> dup ] dip
    predicate-engine-effect define-declared ;

M: predicate-engine compile-engine
    methods-with-default
    sort-methods
    literalize-methods
    prune-redundant-predicates
    class-predicates
    [ peek wrapped>> ]
    [ alist>quot picker prepend define-predicate-engine ] if-empty ;

M: word compile-engine ;

M: f compile-engine ;

: build-engine ( generic combination -- engine )
    [
        #>> (dispatch#) set
        [ generic-word set ]
        [ "default-method" word-prop default set ]
        [ "methods" word-prop ] tri
        <engine> compile-engine 1quotation
        picker [ lookup-method ] surround
    ] with-scope ;