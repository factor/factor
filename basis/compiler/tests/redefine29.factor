USING: assocs compiler compiler.tree.propagation.inlining compiler.units
definitions generic kernel kernel.private math sequences tools.test words ;
IN: compiler.tests.redefine29

: clone-empty ( -- vector ) V{ } clone ;
: lookup-literal ( key -- value ? ) H{ { 1 2 } } at* ;
: compare-integers ( a b -- ? ) { integer integer } declare equal? ;

! Unrelated method changes rebuild these dispatchers, but their built-in
! hooks did not change. Invalidate only callers whose assumptions changed.
{ f } [
    [
        { clone at* equal? } [ remake-generic ] each remake-generics
        to-recompile
        { clone-empty lookup-literal compare-integers }
        [ swap member? ] with any?
    ] with-compilation-unit
] unit-test

{ V{ } 2 t f } [ clone-empty 1 lookup-literal 4 4 compare-integers ] unit-test

GENERIC: custom-generic ( x -- y )
M: integer custom-generic 1 + ;
<<
\ custom-generic [ drop [ drop 7 ] ] set-dispatch-independent-inlining
>>
: custom-caller ( x -- y ) custom-generic ;

{ 7 } [ 2 custom-caller ] unit-test

! Rebuilding dispatch must not recompile a caller that only used the hook.
{ f } [
    [
        \ custom-generic remake-generic remake-generics
        to-recompile \ custom-caller swap member?
    ] with-compilation-unit
] unit-test

! A replacement hook still invalidates callers on an ordinary definition
! change, even when it was installed through the conservative property API.
{ } [
    [
        \ custom-generic [ drop [ drop 8 ] ] "custom-inlining" set-word-prop
        \ custom-generic changed-definition
    ] with-compilation-unit
] unit-test
{ 8 } [ 2 custom-caller ] unit-test

! The replacement did not opt in, so it regains a definition dependency.
{ t } [
    [
        \ custom-generic remake-generic remake-generics
        to-recompile \ custom-caller swap member?
    ] with-compilation-unit
] unit-test

{ } [
    [
        \ custom-generic [ drop f ] set-dispatch-independent-inlining
        \ custom-generic changed-definition
    ] with-compilation-unit
] unit-test
{ 3 } [ 2 custom-caller ] unit-test

! Declining to inline also records the hook, so replacing it is observable.
{ } [
    [
        \ custom-generic [ drop [ drop 9 ] ] set-dispatch-independent-inlining
        \ custom-generic changed-definition
    ] with-compilation-unit
] unit-test
{ 9 } [ 2 custom-caller ] unit-test

{ } [
    [
        \ custom-generic "custom-inlining" remove-word-prop
        \ custom-generic changed-definition
    ] with-compilation-unit
] unit-test
{ 3 } [ 2 custom-caller ] unit-test
