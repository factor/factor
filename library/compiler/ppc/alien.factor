! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: assembler
USING: alien compiler inference kernel kernel-internals lists
math memory namespaces words ;

\ alien-invoke [
    uncons load-dll 2dup rel-dlsym-16/16 dlsym compile-call-far
] "generator" set-word-prop

: stack-size 8 + 16 align ;
: stack@ 3 + cell * ;

#parameters [
    dup 0 = [ drop ] [ stack-size 1 1 rot SUBI ] ifte
] "generator" set-word-prop

#unbox [
    uncons f 2dup rel-dlsym-16/16 dlsym compile-call-far
    3 1 rot stack@ STW
] "generator" set-word-prop

#parameter [
    dup 3 + 1 rot stack@ LWZ
] "generator" set-word-prop

#box [
    f 2dup rel-dlsym-16/16 dlsym compile-call-far
] "generator" set-word-prop

#cleanup [
    dup 0 = [ drop ] [ stack-size 1 1 rot ADDI ] ifte
] "generator" set-word-prop
