USING: vocabs.refresh ;
<< refresh-all >>
USING: io prettyprint kernel namespaces parser sequences system tools.test tools.test.private ;
IN: compiler-next-algebra-tests
f restartable-tests? set-global
t silent-tests? set-global
"resource:core/classes/algebra/algebra-tests.factor" run-file
"TEST-FAILURES " write test-failures get length .
test-failures get empty? [ "CLASS-ALGEBRA-PASSED" print flush 0 ] [ :test-failures 1 ] if exit
