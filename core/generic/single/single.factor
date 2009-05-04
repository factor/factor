! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs classes classes.algebra
combinators definitions generic hashtables kernel
kernel.private layouts math namespaces quotations
sequences words generic.single.private effects make ;
IN: generic.single

ERROR: no-method object generic ;

ERROR: inconsistent-next-method class generic ;

TUPLE: single-combination ;

PREDICATE: single-generic < generic
    "combination" word-prop single-combination? ;

GENERIC: dispatch# ( word -- n )

M: generic dispatch# "combination" word-prop dispatch# ;

SYMBOL: assumed
SYMBOL: default
SYMBOL: generic-word
SYMBOL: combination

: with-combination ( combination quot -- )
    [ combination ] dip with-variable ; inline

HOOK: picker combination ( -- quot )

M: single-combination next-method-quot* ( class generic combination -- quot )
    [
        2dup next-method dup [
            [
                pick "predicate" word-prop %
                1quotation ,
                [ inconsistent-next-method ] 2curry ,
                \ if ,
            ] [ ] make picker prepend
        ] [ 3drop f ] if
    ] with-combination ;

: (effective-method) ( obj word -- method )
    [ [ order [ instance? ] with find-last nip ] keep method ]
    [ "default-method" word-prop ]
    bi or ;

M: single-combination make-default-method
    [ [ picker ] dip [ no-method ] curry append ] with-combination ;

! ! ! Build an engine ! ! !

: find-default ( methods -- default )
    #! Side-effects methods.
    [ object bootstrap-word ] dip delete-at* [
        drop generic-word get "default-method" word-prop
    ] unless ;

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
: split-methods ( assoc class -- first second )
    [ [ nip class<= not ] curry assoc-filter ]
    [ [ nip class<=     ] curry assoc-filter ] 2bi ;

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
    #! Convert an assoc mapping classes to methods into an
    #! assoc mapping echelons to assocs. The first echelon
    #! is always there
    H{ { 0 f } } clone [ [ push-echelon ] curry assoc-each ] keep ;

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
GENERIC: compile-engine ( engine -- obj )

: compile-engines ( assoc -- assoc' )
    [ compile-engine ] assoc-map ;

: compile-engines* ( assoc -- assoc' )
    [ over assumed [ compile-engine ] with-variable ] assoc-map ;

: direct-dispatch-table ( assoc n -- table )
    default get <array> [ <enum> swap update ] keep ;

: lo-tag-number ( class -- n )
    "type" word-prop dup num-tags get member?
    [ drop object tag-number ] unless ;

M: tag-dispatch-engine compile-engine
    methods>> compile-engines*
    [ [ lo-tag-number ] dip ] assoc-map
    num-tags get direct-dispatch-table ;

: num-hi-tags ( -- n ) num-types get num-tags get - ;

: hi-tag-number ( class -- n ) "type" word-prop ;

M: hi-tag-dispatch-engine compile-engine
    methods>> compile-engines*
    [ [ hi-tag-number num-tags get - ] dip ] assoc-map
    num-hi-tags direct-dispatch-table ;

: build-fast-hash ( methods -- buckets )
    >alist V{ } clone [ hashcode 1array ] distribute-buckets
    [ compile-engines* >alist >array ] map ;

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
        [ <enum> swap update ] keep
    ] with-variable ;

: sort-methods ( assoc -- assoc' )
    >alist [ keys sort-classes ] keep extract-keys ;

: quote-methods ( assoc -- assoc' )
    [ 1quotation \ drop prefix ] assoc-map ;

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
    [ [ "predicate" word-prop [ dup ] prepend ] dip ] assoc-map ;

PREDICATE: predicate-engine-word < word "owner-generic" word-prop ;

: <predicate-engine-word> ( -- word )
    generic-word get name>> "/predicate-engine" append f <word>
    dup generic-word get "owner-generic" set-word-prop ;

M: predicate-engine-word stack-effect "owner-generic" word-prop stack-effect ;

: define-predicate-engine ( alist -- word )
    [ <predicate-engine-word> ] dip
    [ define ] [ drop generic-word get "engines" word-prop push ] [ drop ] 2tri ;

M: predicate-engine compile-engine
    methods-with-default
    sort-methods
    quote-methods
    prune-redundant-predicates
    class-predicates
    [ peek ] [ alist>quot picker prepend define-predicate-engine ] if-empty ;

M: word compile-engine ;

M: f compile-engine ;

: build-decision-tree ( generic -- methods )
    [ "engines" word-prop forget-all ]
    [ V{ } clone "engines" set-word-prop ]
    [
        "methods" word-prop clone
        [ find-default default set ]
        [ <engine> compile-engine ] bi
    ] tri ;

HOOK: inline-cache-quot combination ( word methods -- quot/f )

: define-inline-cache-quot ( word methods -- )
    [ drop ] [ inline-cache-quot ] 2bi >>direct-entry-def drop ;

HOOK: mega-cache-quot combination ( methods -- quot/f )

M: single-combination perform-combination
    [
        dup generic-word set
        dup build-decision-tree
        [ "decision-tree" set-word-prop ]
        [ mega-cache-quot define ]
        [ define-inline-cache-quot ]
        2tri
    ] with-combination ;
