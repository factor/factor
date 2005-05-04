! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
USING: generic hashtables kernel lists memory parser stdio words ;

"Bootstrap stage 2..." print

! Rehash hashtables
[ hashtable? ] instances
[ dup hash-size swap set-bucket-count ] each

! Update generics
[ dup generic? [ make-generic ] [ drop ] ifte ] each-word

recrossref

: pull-in ( ? list -- )
    swap [
        [
            dup print run-resource
        ] each
    ] [
        drop
    ] ifte ;

t [
    "/library/alien/c-types.factor"
    "/library/alien/compiler.factor"
    "/library/alien/enums.factor"
    "/library/alien/structs.factor"
] pull-in

cpu "x86" = [
    "/library/compiler/x86/assembler.factor"
    "/library/compiler/x86/stack.factor"
    "/library/compiler/x86/generator.factor"
    "/library/compiler/x86/fixnum.factor"
    "/library/compiler/x86/alien.factor"
] pull-in

cpu "ppc" = [
    "/library/compiler/ppc/assembler.factor"
    "/library/compiler/ppc/stack.factor"
    "/library/compiler/ppc/generator.factor"
    "/library/compiler/ppc/alien.factor"
] pull-in

"/library/bootstrap/boot-stage3.factor" run-resource
