! Direct optimizing CFG regression: retain a heap pointer in a register/spill
! across the same ##call-gc used by an automatic nursery check.
USING: accessors alien alien.accessors arrays assocs compiler.cfg
compiler.cfg.build-stack-frame compiler.cfg.instructions
compiler.cfg.register-allocation compiler.cfg.registers compiler.cfg.utilities
compiler.codegen compiler.units cpu.architecture hashtables io kernel
kernel.private locals math memory namespaces prettyprint sequences words ;
IN: mips.gc-root-probe
:: compile-moving-root ( -- word )
    H{ { 0 tagged-rep } { 1 int-rep } { 2 int-rep } { 3 int-rep } }
    clone representations set
    4 vreg-counter set-global
    {
        T{ ##prologue }
        T{ ##peek { dst 0 } { loc D: 0 } }
        T{ ##tagged>integer { dst 1 } { src 0 } }
        T{ ##save-context { temp1 2 } { temp2 3 } }
        T{ ##call-gc { gc-map T{ gc-map } } }
        T{ ##replace { src 1 } { loc D: 0 } }
        T{ ##epilogue }
        T{ ##return }
    } [ clone ] map insns>cfg :> graph
    graph cfg set
    linear-scan-allocator register-allocator set
    graph allocate-registers
    graph build-stack-frame
    gensym [ graph generate ] dip
    [ associate >alist t t modify-code-heap ] keep ;
<< \ compile-moving-root t "no-compile" set-word-prop >>
[ compile-moving-root ] with-scope "moving-root-word" set-global
"optimized moving-root CFG:" print
"moving-root-word" get-global word-optimized? .
"GC root count (must be nonzero):" print
"moving-root-word" get-global word-code nip <alien> -12 alien-unsigned-4
 dup . 0 > [ ] [ "FAIL missing spill GC map" throw ] if flush
20 <iota> [
    1array dup "moving-root-word" get-global execute( x -- x ) eq?
    [ ] [ "FAIL stale root after generated minor-GC call" throw ] if
] each
"PASS actual compiled CFG spill root moved by minor GC" print flush
