! Copyright (C) 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types arrays assocs classes.struct
combinators compiler.cfg.builder.alien.params compiler.cfg.hats
compiler.cfg.instructions compiler.cfg.intrinsics.allot
compiler.cfg.registers cpu.architecture kernel layouts
locals math math.order namespaces sequences system ;
QUALIFIED-WITH: alien.c-types c
IN: compiler.cfg.builder.alien.boxing
M: struct-c-type unbox-parameter
    dup value-struct? [ unbox ] [
        [ nip [ heap-size ] [ c-type-align cell max ] bi f ^^local-allot dup ]
        [ [ ^^unbox-any-c-ptr ] dip explode-struct keys ] 2bi
        implode-struct
        1array { { int-rep f f } }
    ] if ;


! Copyright (C) 2008, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.libraries alien.strings arrays
assocs classes.struct combinators compiler.cfg compiler.cfg.builder
compiler.cfg.builder.alien.boxing compiler.cfg.builder.alien.params
compiler.cfg.hats compiler.cfg.instructions compiler.cfg.registers
compiler.cfg.stacks compiler.cfg.stacks.local compiler.errors
compiler.tree cpu.architecture kernel layouts locals make math math.order namespaces
sequences sequences.generalizations stack-checker.alien system
words ;
IN: compiler.cfg.builder.alien
:: prepare-struct-caller ( vregs reps return -- vregs' reps' return-vreg/f )
    return large-struct? [
        return [ heap-size ] [ c-type-align cell max ] bi f ^^local-allot :> result
        struct-return-register [
            result int-rep rot 3array reg-values get push
            vregs reps
        ] [
            vregs result prefix
            reps int-rep struct-return-on-stack? f 3array prefix
        ] if* result
    ] [ vregs reps f ] if ;



USING: accessors alien.c-types math.vectors.simd ;
float-4 lookup-c-type 16 >>align-first drop

! Copyright (C) 2008, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.libraries alien.strings arrays
assocs classes.struct combinators compiler.cfg compiler.cfg.builder
compiler.cfg.builder.alien.boxing compiler.cfg.builder.alien.params
compiler.cfg.hats compiler.cfg.instructions compiler.cfg.registers
compiler.cfg.stacks compiler.cfg.stacks.local compiler.errors
compiler.tree cpu.architecture kernel layouts locals make math math.order namespaces
sequences sequences.generalizations stack-checker.alien system
words ;
IN: compiler.cfg.builder.alien
:: mark-vararg-group ( reps alignment -- reps' )
    reps [| rep i |
        rep first3 rep param-natural-size 4array
        rep length 4 > [ 4 rep nth ] [ 0 ] if suffix
        i 0 = suffix i reps length 1 - = suffix
        alignment suffix
    ] map-index ;

:: mark-varargs ( groups parameters -- groups' )
    varargs-named-count get :> named
    named integer? [
        groups [| reps i |
            i named >= [ reps i parameters nth base-type
                dup struct-c-type? [ frob-struct ] when
                c-type-align mark-vararg-group ] [ reps ] if
        ] map-index
    ] [ groups ] if ;

:: unbox-parameters ( parameters -- vregs reps )
    parameters length <iota> <reversed> parameters
    [ [ <ds-loc> peek-loc ] [ base-type ] bi* unbox-parameter ]
    2 2 mnmap parameters mark-varargs [ concat ] bi@
    windows-arm64-varargs? get [ windows-vararg-parameters ] when
    parameters length neg <ds-loc> inc-stack ;

: start-vararg ( alignment -- )
    ! Apple rounds the named stack area and each variadic argument to
    ! eight-byte slots; over-aligned aggregates also retain their C alignment.
    int-regs get delete-all float-regs get delete-all
    8 max '[ _ align ] stack-params swap change ;

:: caller-parameter ( vreg rep -- )
    rep length 8 = [ 5 rep nth [ 7 rep nth start-vararg ] when ] when
    rep prepare-parameter-group
    vreg rep first3 rep param-natural-size next-parameter
    rep length 8 = [ 6 rep nth [ stack-params [ 8 align ] change ] when ] when ;
