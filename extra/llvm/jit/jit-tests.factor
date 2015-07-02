! Copyright (C) 2009 Matthew Willis.
! See http://factorcode.org/license.txt for BSD license.
USING: destructors llvm.jit llvm.wrappers tools.test ;

[ ] [ "test" <module> "test" add-module "test" remove-module ] unit-test
