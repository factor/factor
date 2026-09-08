USING: fry math kernel sequences io.files io.pathnames
tools.crossref tools.crossref.private tools.test parser
namespaces source-files generic definitions words accessors
compiler.units classes ;
IN: tools.crossref.tests

: fry-target ( x -- y ) 1 + ;
: fry-user ( x -- quot ) '[ _ fry-target ] ;
: nested-fry-user ( x -- quot ) '[ _ '[ _ fry-target ] ] ;

{ t } [ \ fry-target \ fry-user uses member? ] unit-test
{ t } [ \ fry-user \ fry-target usage member? ] unit-test
{ t } [ \ fry-target \ nested-fry-user uses member? ] unit-test
{ t } [ \ nested-fry-user \ fry-target usage member? ] unit-test

! Forgetting the enclosing definition also removes its fried references.
{ } [ [ \ fry-user forget ] with-compilation-unit ] unit-test
{ f } [
    \ fry-target usage [ word? ] filter [ name>> "fry-user" = ] any?
] unit-test

GENERIC: predicate-test ( a -- b )

M: class predicate-test ;

M: generic predicate-test ;

{ f } [ \ + irrelevant? ] unit-test
{ t } [ \ predicate-test "engines" word-prop first irrelevant? ] unit-test

GENERIC: foo ( a b -- c )

M: integer foo + ;

"vocab:tools/crossref/test/foo.factor" run-file

{ t } [ integer \ foo lookup-method \ + usage member? ] unit-test
{ t } [ \ foo usage [ pathname? ] any? ] unit-test

! Issues with forget
GENERIC: generic-forget-test-1 ( a b -- c )

M: integer generic-forget-test-1 / ;

{ t } [
    \ / usage [ word? ] filter
    [ name>> "integer=>generic-forget-test-1" = ] any?
] unit-test

{ } [
    [ \ generic-forget-test-1 forget ] with-compilation-unit
] unit-test

{ f } [
    \ / usage [ word? ] filter
    [ name>> "integer=>generic-forget-test-1" = ] any?
] unit-test

GENERIC: generic-forget-test-2 ( a b -- c )

M: sequence generic-forget-test-2 = ;

{ t } [
    \ = usage [ word? ] filter
    [ name>> "sequence=>generic-forget-test-2" = ] any?
] unit-test

{ } [
    [ M\ sequence generic-forget-test-2 forget ] with-compilation-unit
] unit-test

{ f } [
    \ = usage [ word? ] filter
    [ name>> "sequence=>generic-forget-test-2" = ] any?
] unit-test
