! Copyright (C) 2009 Matthew Willis.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.llvm io.pathnames llvm.invoker llvm.reader tools.test ;

[ 3 ] [
    <<
        "extra/llvm/reader/add.bc" resource-path "add" load-into-jit
        "add" install-module
    >> 1 2 add
] unit-test