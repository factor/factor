! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: compiler
USING: alien assembler inference kernel kernel-internals lists
math memory namespaces words ;

\ alien-invoke [
    uncons load-dll 2dup dlsym CALL t rel-dlsym
] "generator" set-word-prop

\ alien-global [
    uncons load-dll 2dup dlsym EAX swap unit MOV f rel-dlsym
] "generator" set-word-prop

#parameters [
    drop
] "generator" set-word-prop

#unbox [
    dup f dlsym CALL f t rel-dlsym
    EAX PUSH
] "generator" set-word-prop

#parameter [
    #! x86 does not pass parameters in registers
    drop
] "generator" set-word-prop

#box [
    EAX PUSH
    dup f dlsym CALL f t rel-dlsym
    ESP 4 ADD
] "generator" set-word-prop

#cleanup [
    dup 0 = [ drop ] [ ESP swap ADD ] ifte
] "generator" set-word-prop
