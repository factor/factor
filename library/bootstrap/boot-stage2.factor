! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
USING: alien assembler command-line compiler generic hashtables
kernel lists memory namespaces parser sequences stdio unparser
words ;

"Making the image happy..." print

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

"Loading compiler and friends..." print
t [
    "/library/inference/conditions.factor"
    "/library/inference/dataflow.factor"
    "/library/inference/inference.factor"
    "/library/inference/ties.factor"
    "/library/inference/branches.factor"
    "/library/inference/words.factor"
    "/library/inference/stack.factor"
    "/library/inference/types.factor"

    "/library/compiler/assembler.factor"
    "/library/compiler/relocate.factor"
    "/library/compiler/xt.factor"
    "/library/compiler/optimizer.factor"
    "/library/compiler/vops.factor"
    "/library/compiler/linearizer.factor"
    "/library/compiler/intrinsics.factor"
    "/library/compiler/simplifier.factor"
    "/library/compiler/generator.factor"
    "/library/compiler/compiler.factor"
        
    "/library/alien/c-types.factor"
    "/library/alien/enums.factor"
    "/library/alien/structs.factor"
    "/library/alien/compiler.factor"
    "/library/alien/malloc.factor"

    "/library/io/buffer.factor"
] pull-in

cpu "x86" = [
    "/library/compiler/x86/assembler.factor"
    "/library/compiler/x86/generator.factor"
    "/library/compiler/x86/stack.factor"
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
