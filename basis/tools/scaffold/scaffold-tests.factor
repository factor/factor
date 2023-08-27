! Copyright (C) 2009 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.

USING: help.markup io.streams.string kernel math sequences
tools.scaffold tools.scaffold.private tools.test unicode ;

IN: tools.scaffold.tests


: undocumented-word ( obj1 obj2 -- obj3 obj4 )
    [ >lower ] [ >upper ] bi* ;

{
"HELP: undocumented-word
{ $values
    { \"obj1\" object } { \"obj2\" object }
    { \"obj3\" object } { \"obj4\" object }
}
{ $description \"\" } ;
"
}
[
    [ \ undocumented-word scaffold-word-docs ] with-string-writer
] unit-test

{
"HELP: iota
{ $class-description \"\" } ;
"
}
[
    [ \ iota scaffold-word-docs ] with-string-writer
] unit-test

{ sequence t } [ "seq" lookup-type ] unit-test
{ sequence t } [ "seq'" lookup-type ] unit-test
{ sequence t } [ "newseq" lookup-type ] unit-test
{ { $maybe sequence } t } [ "seq/f" lookup-type ] unit-test
{ f f } [ "foo" lookup-type ] unit-test


: test-maybe ( obj -- obj/f ) ;

{
"HELP: test-maybe
{ $values
    { \"obj\" object }
    { \"obj/f\" { $maybe object } }
}
{ $description \"\" } ;
"
}
[ [ \ test-maybe scaffold-word-docs ] with-string-writer ]
unit-test

{ "{ \"foofoo\" } [\n    USING: kernel sequences ; \"foo\" dup append\n] unit-test\n" } [
    "USING: kernel sequences ; \"foo\" dup append" [ read-unit-test ] with-string-reader
] unit-test

{
    "{\n    \"foobarbazfoobarbazfoobarbazfoobarbazfoobarbazfoobarbazfoobarbazfoobarbaz\"\n} [\n    USING: kernel math sequences ; \"foobarbaz\" 3 [ dup append ] times\n] unit-test\n"
} [
    "USING: kernel math sequences ; \"foobarbaz\" 3 [ dup append ] times"
    [ read-unit-test ] with-string-reader
] unit-test

{ "foobar [\n    baz\n] unit-test\n" } [
    "foobar" "baz" make-unit-test
] unit-test


{ "foobar [\n    foz\n    baz\n] unit-test\n" } [
    "foobar" "foz\nbaz" make-unit-test
] unit-test

{ { 2 } } [
    "USING: math ; 2 1 + 3 * 7 -" run-string
] unit-test
