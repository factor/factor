USING: destructors llvm.jit llvm.wrappers tools.test ;

[ ] [ "test" <module> [ <provider> ] with-disposal [ "test" add-provider ] with-disposal "test" remove-provider ] unit-test