! Copyright (C) 2009 Doug Coleman.
! Copyright (C) 2018 Alexander Ilin.
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

{
"HELP: iota
{ $class-description \"\" } ;
" }
[
    [ \ iota (help.) ] with-string-writer
] unit-test

{ sequence t } [ "seq" lookup-type ] unit-test
{ sequence t } [ "seq'" lookup-type ] unit-test
{ sequence t } [ "newseq" lookup-type ] unit-test
{ { $maybe sequence } t } [ "seq/f" lookup-type ] unit-test
{ f f } [ "foo" lookup-type ] unit-test


: test-maybe ( obj -- obj/f ) ;

{ } [ \ test-maybe (help.) ] unit-test

[ "resource:work" "math" check-shadowed ]
[
    "Vocab with this name already exists in resource:core" =
] must-fail-with

[ "resource:core" "math" check-shadowed ]
[
    "Vocab with this name already exists in resource:core" =
] must-fail-with

[ "resource:extra" "sequences.extras" check-shadowed ]
[
    "Vocab with this name already exists in resource:extra" =
] must-fail-with

{ } [ "resource:core" "sequences.extras" check-shadowed ] unit-test
