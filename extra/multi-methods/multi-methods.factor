! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math sequences vectors classes combinators
arrays words assocs parser namespaces definitions
prettyprint prettyprint.backend quotations arrays.lib
debugger io ;
IN: multi-methods

TUPLE: method loc def ;

: <method> { set-method-def } \ method construct ;

: maximal-element ( seq quot -- n elt )
    dupd [
        swapd [ call 0 < ] 2curry subset empty?
    ] 2curry find [ "Topological sort failed" throw ] unless* ;
    inline

: topological-sort ( seq quot -- newseq )
    >r >vector [ dup empty? not ] r>
    [ dupd maximal-element >r over delete-nth r> ] curry
    [ ] unfold nip ; inline

: classes< ( seq1 seq2 -- -1/0/1 )
    [
        {
            { [ 2dup eq? ] [ 0 ] }
            { [ 2dup class< ] [ -1 ] }
            { [ 2dup swap class< ] [ 1 ] }
            { [ t ] [ 0 ] }
        } cond 2nip
    ] 2map [ zero? not ] find nip 0 or ;

: picker ( n -- quot )
    {
        { 0 [ [ dup ] ] }
        { 1 [ [ over ] ] }
        { 2 [ [ pick ] ] }
        [ 1- picker [ >r ] swap [ r> swap ] 3append ]
    } case ;

: (multi-predicate) ( class picker -- quot )
    swap "predicate" word-prop append ;

: multi-predicate ( classes -- quot )
    dup length <reversed>
    [ picker 2array ] 2map
    [ drop object eq? not ] assoc-subset
    dup empty? [ drop [ t ] ] [
        [ (multi-predicate) ] { } assoc>map
        unclip [ swap [ f ] \ if 3array append [ ] like ] reduce
    ] if ;

: methods ( word -- alist )
    "multi-methods" word-prop >alist ;

: method-defs ( methods -- methods' )
    [ method-def ] assoc-map ;

TUPLE: no-method arguments generic ;

: no-method ( argument-count generic -- * )
    >r narray r> \ no-method construct-boa throw ; inline

: argument-count ( methods -- n )
    dup assoc-empty? [ drop 0 ] [
        keys [ length ] map supremum
    ] if ;

: multi-dispatch-quot ( methods generic -- quot )
    >r
    [ [ >r multi-predicate r> ] assoc-map ] keep argument-count
    r> [ no-method ] 2curry
    swap reverse alist>quot ;

: congruify-methods ( alist -- alist' )
    dup argument-count [
        swap >r object pad-left [ \ f or ] map r>
    ] curry assoc-map ;

: sorted-methods ( alist -- alist' )
    [ [ first ] 2apply classes< ] topological-sort ;

: niceify-method [ dup \ f eq? [ drop f ] when ] map ;

M: no-method error.
    "Type check error" print
    nl
    "Generic word " write dup no-method-generic pprint
    " does not have a method applicable to inputs:" print
    dup no-method-arguments short.
    nl
    "Inputs have signature:" print
    dup no-method-arguments [ class ] map niceify-method .
    nl
    "Defined methods in topological order: " print
    no-method-generic
    methods congruify-methods sorted-methods keys
    [ niceify-method ] map stack. ;

GENERIC: perform-combination ( word combination -- quot )

TUPLE: standard-combination ;

: standard-combination ( methods generic -- quot )
    >r congruify-methods sorted-methods r> multi-dispatch-quot ;

M: standard-combination perform-combination
    drop [ methods method-defs ] keep standard-combination ;

TUPLE: hook-combination var ;

M: hook-combination perform-combination
    hook-combination-var [ get ] curry swap methods
    [ method-defs [ [ drop ] swap append ] assoc-map ] keep
    standard-combination append ;

: make-generic ( word -- )
    dup dup "multi-combination" word-prop perform-combination
    define ;

: init-methods ( word -- )
    dup "multi-methods" word-prop
    H{ } assoc-like
    "multi-methods" set-word-prop ;

: define-generic ( word combination -- )
    dupd "multi-combination" set-word-prop
    dup init-methods
    make-generic ;

: define-standard-generic ( word -- )
    T{ standard-combination } define-generic ;

: GENERIC:
    CREATE define-standard-generic ; parsing

: define-hook-generic ( word var -- )
    hook-combination construct-boa define-generic ;

: HOOK:
    CREATE scan-word define-hook-generic ; parsing

: method ( classes word -- method )
    "multi-methods" word-prop at ;

: with-methods ( word quot -- )
    over >r >r "multi-methods" word-prop
    r> call r> make-generic ; inline

: add-method ( method classes word -- )
    [ set-at ] with-methods ;

: forget-method ( classes word -- )
    [ delete-at ] with-methods ;

: parse-method ( -- method classes word method-spec )
    parse-definition 2 cut
    over >r
    >r first2 swap r> <method> -rot
    r> first2 swap add* >array ;

: METHOD:
    location
    >r parse-method >r add-method r> r>
    remember-definition ; parsing

! For compatibility
: M:
    scan-word 1array scan-word parse-definition <method>
    -rot add-method ; parsing

! Definition protocol. We qualify core generics here
USE: qualified
QUALIFIED: syntax

PREDICATE: word generic
    "multi-combination" word-prop >boolean ;

PREDICATE: word standard-generic
    "multi-combination" word-prop standard-combination? ;

PREDICATE: word hook-generic
    "multi-combination" word-prop hook-combination? ;

syntax:M: standard-generic definer drop \ GENERIC: f ;

syntax:M: standard-generic definition drop f ;

syntax:M: hook-generic definer drop \ HOOK: f ;

syntax:M: hook-generic definition drop f ;

syntax:M: hook-generic synopsis*
    dup definer.
    dup seeing-word
    dup pprint-word
    dup "multi-combination" word-prop
    hook-combination-var pprint-word stack-effect. ;

PREDICATE: array method-spec
    unclip generic? >r [ class? ] all? r> and ;

syntax:M: method-spec where
    dup unclip method method-loc [ ] [ second where ] ?if ;

syntax:M: method-spec set-where
    unclip method set-method-loc ;

syntax:M: method-spec definer
    drop \ METHOD: \ ; ;

syntax:M: method-spec definition
    unclip method method-def ;

syntax:M: method-spec synopsis*
    dup definer.
    unclip pprint* pprint* ;

syntax:M: method-spec forget
    unclip [ delete-at ] with-methods ;
