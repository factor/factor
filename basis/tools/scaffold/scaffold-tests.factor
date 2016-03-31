! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup io.streams.string kernel sequences
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
    [ \ undocumented-word (help.) ] with-string-writer
] unit-test

{ sequence t } [ "seq" lookup-type ] unit-test
{ sequence t } [ "seq'" lookup-type ] unit-test
{ sequence t } [ "newseq" lookup-type ] unit-test
{ { $maybe sequence } t } [ "seq/f" lookup-type ] unit-test
{ f f } [ "foo" lookup-type ] unit-test


: test-maybe ( obj -- obj/f ) ;

{ } [ \ test-maybe (help.) ] unit-test
