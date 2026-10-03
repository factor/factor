! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators continuations hashtables
kernel locals math namespaces namespaces.contexts sequences
tools.test vectors ;
IN: namespaces.contexts.tests

TUPLE: throwing-variable { calls integer } ;
M: throwing-variable hashcode*
    nip [ 1 + ] change-calls dup calls>> 2 =
    [ "bad variable hash" throw ] [ drop 0 ] if ;

: fresh-context ( -- context ) H{ { "x" 1 } } clone <namespace-context> ;

{ 1 f } [ fresh-context [ "x" swap context-get ] [ "missing" swap context-get ] bi ] unit-test

{ f 1 t } [| |
    fresh-context :> ctx ctx context-push-scope
    2 "x" ctx context-set f "x" ctx context-set
    "x" ctx context-get ctx context-pop
    "x" ctx context-get ctx index>> assoc-empty?
] unit-test

! An explicitly empty stack has no namespace, matching vector last's error.
{ f } [ "x" f <namespace-context> context-get ] unit-test
[ f <namespace-context> context-namespace ] must-fail
[ 1 "x" f <namespace-context> context-set ] must-fail

{ 3 2 1 } [| |
    fresh-context :> ctx ctx context-push-scope 2 "x" ctx context-set
    ctx context-push-scope 3 "x" ctx context-set
    "x" ctx context-get ctx context-pop
    "x" ctx context-get ctx context-pop "x" ctx context-get
] unit-test

! Captures keep owned frames indexed, and share new as well as existing keys.
{ 3 9 t t 3 } [| |
    fresh-context :> parent parent context-push-scope
    2 "x" parent context-set parent context-snapshot :> child
    3 "x" parent context-set "x" child context-get
    9 "new" parent context-set "new" child context-get
    parent borrowed>> empty? child borrowed>> empty?
    child context-push-scope 5 "x" child context-set
    "x" parent context-get child context-pop parent context-pop
] unit-test

! Changes in a captured frame invalidate other contexts even after they index it.
{ f 7 8 } [| |
    fresh-context :> parent parent context-push-scope
    parent context-snapshot :> child
    "new" child context-get
    7 "new" parent context-set "new" child context-get
    8 "child-key" child context-set "child-key" parent context-get
    parent context-pop child context-pop
] unit-test

! Export through either context preserves raw mutation and deletion semantics.
{ 2 9 1 f t } [| |
    fresh-context :> parent parent context-push-scope 2 "x" parent context-set
    parent context-snapshot :> child "x" child context-get
    parent context-namespace :> vars
    9 "new" vars set-at "new" child context-get
    "x" vars delete-at "x" child context-get
    f "x" vars set-at "x" parent context-get
    child context-namespace vars eq?
    parent context-pop child context-pop
] unit-test

! A borrowed outer frame cannot mask a newer owned binding.
{ 5 8 t } [| |
    fresh-context :> ctx H{ { "x" 2 } } clone :> vars
    vars ctx context-push-variables ctx context-push-scope 5 "x" ctx context-set
    8 "x" vars set-at "x" ctx context-get
    ctx context-pop "x" ctx context-get ctx context-pop
    ctx borrowed>> empty?
] unit-test

{ 7 7 1 } [| |
    fresh-context :> ctx H{ { "x" 2 } } clone :> vars
    vars ctx context-push-variables ctx context-push-scope 5 "x" ctx context-set
    vars ctx context-push-variables 7 "x" ctx context-set "x" ctx context-get
    ctx context-pop ctx context-pop "x" ctx context-get
    ctx context-pop "x" ctx context-get
] unit-test

{ 6 7 } [| |
    fresh-context :> ctx ctx context-push-scope
    6 "x" ctx globals>> set-at "x" ctx context-get
    7 "new" ctx globals>> set-at "new" ctx context-get ctx context-pop
] unit-test

! Reusing a saved topology must not mutate its scopes when another copy unwinds.
{ 2 2 } [| |
    fresh-context :> ctx ctx context-push-scope 2 "x" ctx context-set
    ctx context-snapshot :> saved ctx context-pop
    saved context-snapshot :> first-copy "x" first-copy context-get
    first-copy context-pop saved context-snapshot :> second-copy
    "x" second-copy context-get second-copy context-pop
] unit-test

{ t 2 8 } [| |
    fresh-context :> ctx ctx context-push-scope 2 "x" ctx context-set
    ctx context>namestack :> stack
    stack vector? stack last "x" swap at
    8 "x" stack last set-at "x" ctx context-get ctx context-pop
] unit-test

{ 2 f 3 } [| |
    V{ H{ { "x" 2 } } H{ } } clone global namestack>context :> ctx
    "x" ctx context-get "not-a-global" ctx context-get
    3 "x" ctx context-set "x" ctx context-get
] unit-test

! Borrowed assocs do not need an enumeration protocol (the global assoc has none).
{ t } [ global <namespace-context> dup global swap context-push-variables
    context-namespace global eq? ] unit-test

! Compare 3000 mixed operations to the original vector-of-assocs semantics.
:: differential-test ( -- clean? )
    H{ { -1 99 } } clone :> globals
    globals 1vector :> stack!
    globals <namespace-context> :> ctx!
    f :> saved-stack! f :> saved-context! 12345 :> seed!
    3000 <iota> [| i |
        seed 1664525 * 1013904223 + 4294967296 mod seed!
        seed 97 /i 8 mod :> key
        i 3 mod 0 = [ f ] [ i ] if :> value
        seed 9 mod {
            { 0 [ stack length 8 < [
                H{ } clone stack push ctx context-push-scope
            ] when ] }
            { 1 [ stack length 1 > [ stack pop* ctx context-pop ] when ] }
            { 2 [ value key stack last set-at value key ctx context-set ] }
            { 3 [ value key stack last set-at value key ctx context-namespace set-at ] }
            { 4 [ key stack last delete-at key ctx context-namespace delete-at ] }
            { 5 [ stack length 8 < [
                value key associate dup stack push ctx context-push-variables
            ] when ] }
            { 6 [ stack clone saved-stack! ctx context-snapshot saved-context! ] }
            { 7 [ saved-stack [
                saved-stack clone stack! saved-context context-snapshot ctx!
            ] when ] }
            { 8 [ value key globals set-at ] }
        } case
        9 <iota> [| candidate |
            candidate 1 - dup stack assoc-stack swap ctx context-get assert=
        ] each
        stack length ctx scopes>> length 1 + assert=
    ] each
    [ ctx scopes>> empty? not ] [ ctx context-pop ] while
    ctx index>> assoc-empty? ctx borrowed>> empty? and ;

{ t } [ differential-test ] unit-test

! Captures share an index until a private scope needs to modify its topology.
{ t t f 1 9 2 } [| |
    fresh-context :> parent parent context-push-scope 2 "x" parent context-set
    parent context-snapshot :> saved
    parent index>> saved index>> eq?
    parent clock>> revision>> :> before
    parent context-push-scope 9 "x" parent context-set
    parent clock>> revision>> before eq?
    parent index>> saved index>> eq?
    saved scopes>> length "x" parent context-get "x" saved context-get
    parent context-pop parent context-pop saved context-pop
] unit-test

! Exported assocs become authoritative; stale captures must release cell values.
{ 9 f t } [| |
    fresh-context :> ctx ctx context-push-scope 2 "x" ctx context-set
    "x" ctx index>> at first :> cell
    ctx context-snapshot :> saved
    ctx context-namespace :> vars 9 "x" vars set-at
    "x" saved context-get cell value>> ctx scopes>> last bindings>> empty?
    ctx context-pop saved context-pop
] unit-test

! Failed hash lookup must not publish a binding through a captured frame journal.
{ f 1 1 } [| |
    fresh-context :> ctx ctx context-push-scope 1 "existing" ctx context-set
    0 throwing-variable boa :> key ctx context-snapshot :> saved
    [ 7 key ctx context-set ] [ drop ] recover
    key saved context-get "existing" saved context-get
    saved scopes>> last bindings>> length
    ctx context-pop saved context-pop
] unit-test

! Dropping an owned scope must tolerate keys mutated after insertion.
{ 1 t } [| |
    fresh-context :> ctx ctx context-push-scope
    2 1array :> key 7 key ctx context-set
    1 0 key set-nth ctx context-pop
    "x" ctx context-get ctx index>> assoc-empty?
] unit-test

! A mutated inner key must not remove the equal key in an outer scope.
{ 2 t } [| |
    fresh-context :> ctx ctx context-push-scope
    1 1array :> outer 2 outer ctx context-set
    ctx context-push-scope
    2 1array :> inner 7 inner ctx context-set
    1 0 inner set-nth ctx context-pop
    outer ctx context-get ctx context-pop ctx index>> assoc-empty?
] unit-test
