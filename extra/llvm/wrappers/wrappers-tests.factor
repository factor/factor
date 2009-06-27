USING: destructors kernel llvm.wrappers sequences tools.test vocabs ;

[ ] [ "test" <module> dispose ] unit-test
[ ] [ "test" <module> [ <provider> ] with-disposal dispose ] unit-test
[ ] [ "llvm.jit" vocabs member? [ "test" <module> [ <provider> ] with-disposal [ <engine> ] with-disposal dispose ] unless ] unit-test