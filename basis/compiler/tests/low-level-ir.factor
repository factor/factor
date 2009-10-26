USING: accessors assocs compiler compiler.cfg
compiler.cfg.debugger compiler.cfg.instructions compiler.cfg.mr
compiler.cfg.registers compiler.codegen compiler.units
cpu.architecture hashtables kernel namespaces sequences
tools.test vectors words layouts literals math arrays
alien.syntax math.private ;
IN: compiler.tests.low-level-ir

: compile-cfg ( cfg -- word )
    gensym
    [ build-mr generate code>> ] dip
    [ associate >alist modify-code-heap ] keep ;

: compile-test-cfg ( -- word )
    cfg new 0 get >>entry
    dup cfg set
    dup fake-representations representations get >>reps
    compile-cfg ;

: compile-test-bb ( insns -- result )
    V{ T{ ##prologue } T{ ##branch } } [ clone ] map 0 test-bb
    V{
        T{ ##inc-d f 1 }
        T{ ##replace f 0 D 0 }
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

! loading immediates
[ f ] [
    V{
        T{ ##load-immediate f 0 5 }
    } compile-test-bb
] unit-test

[ "hello" ] [
    V{
        T{ ##load-reference f 0 "hello" }
    } compile-test-bb
] unit-test

! make sure slot access works when the destination is
! one of the sources
[ t ] [
    V{
        T{ ##load-immediate f 1 $[ 2 cell log2 shift array tag-number - ] }
        T{ ##load-reference f 0 { t f t } }
        T{ ##slot f 0 0 1 }
    } compile-test-bb
] unit-test

[ t ] [
    V{
        T{ ##load-reference f 0 { t f t } }
        T{ ##slot-imm f 0 0 2 $[ array tag-number ] }
    } compile-test-bb
] unit-test

[ t ] [
    V{
        T{ ##load-immediate f 1 $[ 2 cell log2 shift array tag-number - ] }
        T{ ##load-reference f 0 { t f t } }
        T{ ##set-slot f 0 0 1 }
    } compile-test-bb
    dup first eq?
] unit-test

[ t ] [
    V{
        T{ ##load-reference f 0 { t f t } }
        T{ ##set-slot-imm f 0 0 2 $[ array tag-number ] }
    } compile-test-bb
    dup first eq?
] unit-test

[ 8 ] [
    V{
        T{ ##load-immediate f 0 4 }
        T{ ##shl f 0 0 0 }
    } compile-test-bb
] unit-test

[ 4 ] [
    V{
        T{ ##load-immediate f 0 4 }
        T{ ##shl-imm f 0 0 3 }
    } compile-test-bb
] unit-test

[ 31 ] [
    V{
        T{ ##load-reference f 1 B{ 31 67 52 } }
        T{ ##unbox-any-c-ptr f 0 1 2 }
        T{ ##alien-unsigned-1 f 0 0 0 }
        T{ ##shl-imm f 0 0 3 }
    } compile-test-bb
] unit-test

[ CHAR: l ] [
    V{
        T{ ##load-reference f 0 "hello world" }
        T{ ##load-immediate f 1 3 }
        T{ ##string-nth f 0 0 1 2 }
        T{ ##shl-imm f 0 0 3 }
    } compile-test-bb
] unit-test

[ 1 ] [
    V{
        T{ ##load-immediate f 0 16 }
        T{ ##add-imm f 0 0 -8 }
    } compile-test-bb
] unit-test
