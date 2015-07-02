! Copyright (C) 2009 Matthew Willis.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.llvm io.pathnames llvm.invoker llvm.reader tools.test ;

[ 3 ] [
    << "resource:extra/llvm/reader/add.bc" install-bc >> 1 2 add
] unit-test
