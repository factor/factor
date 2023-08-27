! Copyright (C) 2010 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: alien kernel ;
IN: alien.cxx

SINGLETONS: g++ visual-c++ ;
UNION: c++-abi
    g++ visual-c++ ;

GENERIC: c++>c-abi ( c++-abi -- c-abi )

M: g++ c++>c-abi drop cdecl ;
M: visual-c++ c++>c-abi drop thiscall ;
