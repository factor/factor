USING: alien.c-types arrays assocs combinators compiler.cfg
compiler.cfg.build-stack-frame compiler.cfg.instructions
compiler.cfg.linear-scan compiler.cfg.registers
compiler.cfg.ssa.destruction compiler.cfg.utilities compiler.codegen
compiler.test compiler.units cpu.architecture hashtables kernel
layouts literals math namespaces sequences tools.test words ;
IN: compiler.tests.low-level-ir

: compile-cfg ( cfg -- word )
    gensym [
        [ linear-scan ] [ build-stack-frame ] [ generate ] tri
    ] dip
    [ associate >alist t t modify-code-heap ] keep ;

: compile-test-cfg ( -- word )
    0 get block>cfg {
        [ cfg set ]
        [ fake-representations ]
        [ destruct-ssa ]
        [ compile-cfg ]
    } cleave ;

: compile-test-bb ( insns -- result )
    V{ T{ ##prologue } T{ ##branch } } [ clone ] map 0 test-bb
    V{
        T{ ##inc f D: 1 }
        T{ ##replace f 0 D: 0 }
        T{ ##branch }
    } [ clone ] map append 1 test-bb
    V{
        T{ ##epilogue }
        T{ ##return }
    } [ clone ] map 2 test-bb
    0 1 edge
    1 2 edge
    compile-test-cfg
    execute( -- result ) ;

! loading constants
[ "hello" ] [
    V{
        T{ ##load-reference f 0 "hello" }
    } compile-test-bb
] unit-test

! make sure slot access works when the destination is
! one of the sources
[ t ] [
    V{
        T{ ##load-tagged f 1 $[ 2 cell log2 shift array type-number - ] }
        T{ ##load-reference f 0 { t f t } }
        T{ ##slot f 0 0 1 0 0 }
    } compile-test-bb
] unit-test

[ t ] [
    V{
        T{ ##load-reference f 0 { t f t } }
        T{ ##slot-imm f 0 0 2 $[ array type-number ] }
    } compile-test-bb
] unit-test

[ t ] [
    V{
        T{ ##load-tagged f 1 $[ 2 cell log2 shift array type-number - ] }
        T{ ##load-reference f 0 { t f t } }
        T{ ##set-slot f 0 0 1 0 0 }
    } compile-test-bb
    dup first eq?
] unit-test

[ t ] [
    V{
        T{ ##load-reference f 0 { t f t } }
        T{ ##set-slot-imm f 0 0 2 $[ array type-number ] }
    } compile-test-bb
    dup first eq?
] unit-test

[ $[ tag-bits get ] ] [
    V{
        T{ ##load-tagged f 0 $[ tag-bits get ] }
        T{ ##shl f 0 0 0 }
    } compile-test-bb
] unit-test

[ $[ tag-bits get ] ] [
    V{
        T{ ##load-tagged f 0 $[ tag-bits get ] }
        T{ ##shl-imm f 0 0 $[ tag-bits get ] }
    } compile-test-bb
] unit-test

[ 31 ] [
    V{
        T{ ##load-reference f 1 B{ 31 67 52 } }
        T{ ##unbox-any-c-ptr f 2 1 }
        T{ ##load-memory-imm f 3 2 0 int-rep uchar }
        T{ ##shl-imm f 0 3 $[ tag-bits get ] }
    } compile-test-bb
] unit-test

[ 1 ] [
    V{
        T{ ##load-tagged f 0 $[ 2 tag-fixnum ] }
        T{ ##add-imm f 0 0 $[ -1 tag-fixnum ] }
    } compile-test-bb
] unit-test

[ -1 ] [
    V{
        T{ ##load-tagged f 1 $[ -1 tag-fixnum ] }
        T{ ##convert-integer f 0 1 char }
    } compile-test-bb
] unit-test

[ -1 ] [
    V{
        T{ ##load-tagged f 1 $[ -1 9 2^ bitxor tag-fixnum ] }
        T{ ##convert-integer f 0 1 char }
    } compile-test-bb
] unit-test

[ $[ 255 tag-bits get neg shift ] ] [
    V{
        T{ ##load-tagged f 1 $[ -1 9 2^ bitxor tag-fixnum ] }
        T{ ##convert-integer f 0 1 uchar }
    } compile-test-bb
] unit-test
