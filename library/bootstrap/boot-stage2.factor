! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
USING: alien assembler command-line compiler errors generic
hashtables io kernel lists memory namespaces parser sequences
unparser words ;

: pull-in ( ? list -- )
    swap [
        [
            dup print run-resource
        ] each
    ] [
        drop
    ] ifte ;

"Loading compiler backend..." print

cpu "x86" = [
    "/library/compiler/x86/assembler.factor"
    "/library/compiler/x86/generator.factor"
    "/library/compiler/x86/slots.factor"
    "/library/compiler/x86/stack.factor"
    "/library/compiler/x86/fixnum.factor"
    "/library/compiler/x86/alien.factor"
] pull-in

cpu "ppc" = [
    "/library/compiler/ppc/assembler.factor"
    "/library/compiler/ppc/generator.factor"
    "/library/compiler/ppc/slots.factor"
    "/library/compiler/ppc/stack.factor"
    "/library/compiler/ppc/fixnum.factor"
    "/library/compiler/ppc/alien.factor"
] pull-in

"/library/bootstrap/boot-stage3.factor" run-resource
