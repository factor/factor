USING: accessors assocs compiler compiler.cfg
compiler.cfg.debugger compiler.cfg.instructions compiler.cfg.mr
compiler.cfg.registers compiler.codegen compiler.units
cpu.architecture hashtables kernel namespaces sequences
tools.test vectors words layouts literals math arrays
alien.syntax ;
IN: compiler.tests.low-level-ir

: compile-cfg ( cfg -- word )
    gensym
    [ build-mr generate code>> ] dip
    [ associate >alist modify-code-heap ] keep ;

: compile-test-cfg ( -- word )
    cfg new
    0 get >>entry
    compile-cfg ;

: compile-test-bb ( insns -- result )
    V{ T{ ##prologue } T{ ##branch } } 0 test-bb
    V{
        T{ ##inc-d f 1 }
        T{ ##replace f V int-regs 0 D 0 }
        T{ ##branch }
    } [ clone ] map append 1 test-bb
    V{
        T{ ##epilogue }
        T{ ##return }
    } [ clone ] map 2 test-bb
    0 get 1 get 1vector >>successors drop
    1 get 2 get 1vector >>successors drop
    compile-test-cfg
    execute( -- result ) ;

! loading immediates
[ f ] [
    V{
        T{ ##load-immediate f V int-regs 0 5 }
    } compile-test-bb
] unit-test

[ "hello" ] [
    V{
        T{ ##load-reference f V int-regs 0 "hello" }
    } compile-test-bb
] unit-test

! make sure slot access works when the destination is
! one of the sources
[ t ] [
    V{
        T{ ##load-immediate f V int-regs 1 $[ 2 cell log2 shift ] }
        T{ ##load-reference f V int-regs 0 { t f t } }
        T{ ##slot f V int-regs 0 V int-regs 0 V int-regs 1 $[ array tag-number ] V int-regs 2 }
    } compile-test-bb
] unit-test

[ t ] [
    V{
        T{ ##load-reference f V int-regs 0 { t f t } }
        T{ ##slot-imm f V int-regs 0 V int-regs 0 2 $[ array tag-number ] V int-regs 2 }
    } compile-test-bb
] unit-test

[ t ] [
    V{
        T{ ##load-immediate f V int-regs 1 $[ 2 cell log2 shift ] }
        T{ ##load-reference f V int-regs 0 { t f t } }
        T{ ##set-slot f V int-regs 0 V int-regs 0 V int-regs 1 $[ array tag-number ] V int-regs 2 }
    } compile-test-bb
    dup first eq?
] unit-test

[ t ] [
    V{
        T{ ##load-reference f V int-regs 0 { t f t } }
        T{ ##set-slot-imm f V int-regs 0 V int-regs 0 2 $[ array tag-number ] }
    } compile-test-bb
    dup first eq?
] unit-test

[ 8 ] [
    V{
        T{ ##load-immediate f V int-regs 0 4 }
        T{ ##shl f V int-regs 0 V int-regs 0 V int-regs 0 }
    } compile-test-bb
] unit-test

[ 4 ] [
    V{
        T{ ##load-immediate f V int-regs 0 4 }
        T{ ##shl-imm f V int-regs 0 V int-regs 0 3 }
    } compile-test-bb
] unit-test

[ 31 ] [
    V{
        T{ ##load-reference f V int-regs 1 B{ 31 67 52 } }
        T{ ##unbox-any-c-ptr f V int-regs 0 V int-regs 1 V int-regs 2 }
        T{ ##alien-unsigned-1 f V int-regs 0 V int-regs 0 }
        T{ ##shl-imm f V int-regs 0 V int-regs 0 3 }
    } compile-test-bb
] unit-test

[ CHAR: l ] [
    V{
        T{ ##load-reference f V int-regs 0 "hello world" }
        T{ ##load-immediate f V int-regs 1 3 }
        T{ ##string-nth f V int-regs 0 V int-regs 0 V int-regs 1 V int-regs 2 }
        T{ ##shl-imm f V int-regs 0 V int-regs 0 3 }
    } compile-test-bb
] unit-test

[ 1 ] [
    V{
        T{ ##load-immediate f V int-regs 0 16 }
        T{ ##add-imm f V int-regs 0 V int-regs 0 -8 }
    } compile-test-bb
] unit-test

! These are def-is-use-insns
USE: multiline

/*

[ 100 ] [
    V{
        T{ ##load-immediate f V int-regs 0 100 }
        T{ ##integer>bignum f V int-regs 0 V int-regs 0 V int-regs 1 }
    } compile-test-bb
] unit-test

[ 1 ] [
    V{
        T{ ##load-reference f V int-regs 0 ALIEN: 8 }
        T{ ##unbox-any-c-ptr f V int-regs 0 V int-regs 0 V int-regs 1 }
    } compile-test-bb
] unit-test

*/