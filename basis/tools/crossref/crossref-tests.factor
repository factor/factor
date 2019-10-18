USING: math kernel sequences io.files io.pathnames
tools.crossref tools.test parser namespaces source-files generic
definitions words accessors compiler.units ;
IN: tools.crossref.tests

GENERIC: foo ( a b -- c )

M: integer foo + ;

"vocab:tools/crossref/test/foo.factor" run-file

[ t ] [ integer \ foo method \ + usage member? ] unit-test
[ t ] [ \ foo usage [ pathname? ] any? ] unit-test

! Issues with forget
GENERIC: generic-forget-test-1 ( a b -- c )

M: integer generic-forget-test-1 / ;

[ t ] [
    \ / usage [ word? ] filter
    [ name>> "integer=>generic-forget-test-1" = ] any?
] unit-test

[ ] [
    [ \ generic-forget-test-1 forget ] with-compilation-unit
] unit-test

[ f ] [
    \ / usage [ word? ] filter
    [ name>> "integer=>generic-forget-test-1" = ] any?
] unit-test

GENERIC: generic-forget-test-2 ( a b -- c )

M: sequence generic-forget-test-2 = ;

[ t ] [
    \ = usage [ word? ] filter
    [ name>> "sequence=>generic-forget-test-2" = ] any?
] unit-test

[ ] [
    [ M\ sequence generic-forget-test-2 forget ] with-compilation-unit
] unit-test

[ f ] [
    \ = usage [ word? ] filter
    [ name>> "sequence=>generic-forget-test-2" = ] any?
] unit-test