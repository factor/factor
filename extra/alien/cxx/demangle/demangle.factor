! Copyright (C) 2010 Joe Groff.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.cxx kernel ;
QUALIFIED-WITH: alien.cxx.demangle.libstdcxx libstdcxx
IN: alien.cxx.demangle

GENERIC: c++-symbol? ( mangled-name abi -- ? )
GENERIC: demangle ( mangled-name abi -- c++-name )

M: g++ c++-symbol?
    drop libstdcxx:mangled-name? ;
M: g++ demangle
    drop libstdcxx:demangle ;
