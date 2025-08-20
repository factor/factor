USING: tools.test sequences strings classes.enumeration combinators see kernel io.streams.string compiler.units parser math eval ;
IN: classes.enumeration.tests

ENUMERATION: test-enum < string { val-1 "a" [ CHAR: a suffix ] } val-2 val-3 ;
{ "USING: sequences strings ;\nIN: classes.enumeration.tests\nENUMERATION: test-enum < string\n    { val-1 \"a\" [ 97 suffix ] } val-2 val-3 ;\n" } [ [ \ test-enum see ] with-string-writer ] unit-test

{ "a" "aa" "aaa" } [ test-enum.val-1 test-enum.val-2 test-enum.val-3 ] unit-test

{ t } [ \ test-enum.val-1 enumeration-member-word? ] unit-test

{ t } [ \ test-enum enumeration-class? ] unit-test

{ t } [ "aaa" test-enum? ] unit-test

{ f } [ "aaaa" test-enum? ] unit-test

ENUMERATION: foo foo { bar 3 } baz ;

{ "IN: classes.enumeration.tests\nENUMERATION: foo foo { bar 3 } baz ;\n" } [ [ \ foo see ] with-string-writer ] unit-test

{ 0 3 4 } [ foo.foo foo.bar foo.baz ] unit-test

{ "foo.foo" } [ 0 { { foo.foo [ "foo.foo" ] } { foo.bar [ "foo.bar" ] } { foo.baz [ "foo.baz" ] } [ drop "not in foo" ] } case ] unit-test

{ "not in foo" } [ 2 { { foo.foo [ "foo.foo" ] } { foo.bar [ "foo.bar" ] } { foo.baz [ "foo.baz" ] } [ drop "not in foo" ] } case ] unit-test
<<
SYNTAX: define-foo  
    "foo2" create-word-in fixnum { { "foo" } { "bar" 3 } { "baz" } } define-enum-class ;
>>

define-foo

{ "IN: classes.enumeration.tests\nENUMERATION: foo2 foo { bar 3 } baz ;\n" } 
[
    [ \ foo2 see ] with-string-writer 
] unit-test

{ 0 3 4 } [ foo2.foo foo2.bar foo2.baz ] unit-test

{ "foo2.foo" } [ 0 { { foo2.foo [ "foo2.foo" ] } { foo2.bar [ "foo2.bar" ] } { foo2.baz [ "foo2.baz" ] } [ drop "not in foo" ] } case ] unit-test

{ "not in foo2" } [ 2 { { foo2.foo [ "foo2.foo" ] } { foo2.bar [ "foo2.bar" ] } { foo2.baz [ "foo2.baz" ] } [ drop "not in foo2" ] } case ] unit-test

[ "ENUMERATION: foo3 foo { bar \"a\" [ CHAR: a suffix ] } ; " parse-string ] must-fail
