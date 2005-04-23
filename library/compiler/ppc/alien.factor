! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: compiler
USING: alien assembler inference kernel kernel-internals lists
math memory namespaces words ;

\ alien-invoke [
    uncons load-dll dlsym compile-call-far
] "generator" set-word-prop

#parameters [
    dup 0 = [ drop ] [ 1 1 rot SUBI ] ifte
] "generator" set-word-prop

#unbox [
    uncons f dlsym compile-call-far
    3 1 rot neg 4 - STW
] "generator" set-word-prop

#parameter [
    dup 3 + 1 rot cell * neg 4 - LWZ
] "generator" set-word-prop

#box [
    f dlsym compile-call-far
] "generator" set-word-prop

#cleanup [
    dup 0 = [ drop ] [ 1 1 rot ADDI ] ifte
] "generator" set-word-prop
