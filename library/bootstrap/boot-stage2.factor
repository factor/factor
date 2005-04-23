! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
USING: kernel lists parser stdio words ;

"Bootstrap stage 2..." print

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
    "/library/syntax/unparser.factor"
    "/library/syntax/prettyprint.factor"
    
    ! This has to be loaded here because it overloads sequence
    ! generics, and we don't want to compile twice.
    "/library/math/matrices.factor"

    "/library/tools/debugger.factor"
    "/library/tools/gensym.factor"
    "/library/tools/interpreter.factor"

    "/library/inference/conditions.factor"
    "/library/inference/dataflow.factor"
    "/library/inference/inference.factor"
    "/library/inference/ties.factor"
    "/library/inference/branches.factor"
    "/library/inference/words.factor"
    "/library/inference/stack.factor"
    "/library/inference/types.factor"

    "/library/compiler/assembler.factor"
    "/library/compiler/xt.factor"
    "/library/compiler/optimizer.factor"
    "/library/compiler/linearizer.factor"
    "/library/compiler/simplifier.factor"
    "/library/compiler/generator.factor"
    "/library/compiler/compiler.factor"

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
] pull-in

cpu "ppc" = [
    "/library/compiler/ppc/assembler.factor"
    "/library/compiler/ppc/stack.factor"
    "/library/compiler/ppc/generator.factor"
] pull-in

"/library/bootstrap/boot-stage3.factor" run-resource
