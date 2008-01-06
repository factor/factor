! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math sequences vectors classes combinators
arrays words assocs parser namespaces definitions
prettyprint prettyprint.backend quotations ;
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

: multi-predicate ( classes -- quot )
    dup length <reversed> [
        >r "predicate" word-prop r>
        picker swap [ not ] 3append [ f ] 2array
    ] 2map [ t ] swap alist>quot ;

: method-defs ( methods -- methods' )
    [ method-def ] assoc-map ;

: multi-dispatch-quot ( methods -- quot )
    [ >r multi-predicate r> ] assoc-map
    [ "No method" throw ] swap reverse alist>quot ;

: methods ( word -- alist )
    "multi-methods" word-prop >alist ;

: congruify-methods ( alist -- alist' )
    dup empty? [
        dup [ first length ] map supremum [
            swap >r object pad-left [ \ f or ] map r>
        ] curry assoc-map
    ] unless ;

: sorted-methods ( alist -- alist' )
    [ [ first ] 2apply classes< ] topological-sort ;

GENERIC: perform-combination ( word combination -- quot )

TUPLE: standard-combination ;

: standard-combination ( methods -- quot )
    congruify-methods sorted-methods multi-dispatch-quot ;

M: standard-combination perform-combination
    drop methods method-defs standard-combination ;

TUPLE: hook-combination var ;

M: hook-combination perform-combination
    hook-combination-var [ get ] curry
    swap methods method-defs [ [ drop ] swap append ] assoc-map
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
    dup seeing-word \ HOOK: pprint-word dup pprint-word
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
    dup definer drop pprint-word
    unclip pprint* pprint* ;

syntax:M: method-spec forget
    unclip [ delete-at ] with-methods ;
