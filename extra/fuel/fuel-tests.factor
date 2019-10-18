! Copyright (C) 2009 Nicholas Seckar.
! See http://factorcode.org/license.txt for BSD license.
USING: continuations eval fuel fuel.private namespaces tools.test words ;
IN: fuel.tests

: fake-continuation ( -- continuation )
    f f f "fake" f <continuation> ;

: make-uses-restart ( -- restart )
    "Use the words vocabulary" \ word?
    fake-continuation <restart> ;

: make-defer-restart ( -- restart )
    "Defer word in current vocabulary" f
    fake-continuation <restart> ;

{ f } [ make-defer-restart is-use-restart ] unit-test
{ t } [ make-uses-restart is-use-restart ] unit-test

{ "words" } [ make-uses-restart get-restart-vocab ] unit-test

{ f } [ make-defer-restart is-suggested-restart ] unit-test
{ f } [ make-uses-restart is-suggested-restart ] unit-test
{ f } [ { "io" } :uses-suggestions
        [ make-uses-restart is-suggested-restart ] with-variable
] unit-test
{ t } [ { "words" } :uses-suggestions
        [ make-uses-restart is-suggested-restart ] with-variable
] unit-test

{ } [
    { "kernel" } [ "\\ dup drop" eval( -- ) ] fuel-use-suggested-vocabs
] unit-test
