USING: accessors arrays compiler.cfg compiler.cfg.debugger
compiler.cfg.instructions compiler.cfg.multiply-negate compiler.cfg.utilities
compiler.test io kernel kernel.private math math.private memory namespaces
prettyprint sequences tools.time words compiler.units ;
IN: arm64-gap-isa.benchmark

: compiler-workload ( -- )
    [ { fixnum fixnum } declare fixnum*fast -1 fixnum*fast ] test-regs drop
    [ { fixnum fixnum } declare fixnum+fast 3 fixnum*fast ] test-regs drop
    [ { fixnum } declare 255 fixnum-bitand ] test-regs drop ;

: pass-workload ( -- cfg )
    200 <iota> [| n | T{ ##add { dst 3 } { src1 0 } { src2 1 } } clone n >>dst ] map insns>cfg ;

: measure ( -- )
    3 [ compiler-workload ] times
    7 [ [ 50 [ compiler-workload ] times ] benchmark . flush ] times ;

SYMBOL: enabled-definition
\ fuse-multiply-negate def>> enabled-definition set
: disable-fusion ( -- )
    [ \ fuse-multiply-negate [ drop ] define ] with-compilation-unit ;
: enable-fusion ( -- )
    [ \ fuse-multiply-negate enabled-definition get define ] with-compilation-unit ;
: sample-compile ( -- )
    10 [ compiler-workload ] times
    [ 100 [ compiler-workload ] times ] benchmark . flush ;
"Interleaved disabled/enabled pass; 100 x three CFG compilations (ns):" print
9 [ disable-fusion sample-compile enable-fusion sample-compile ] times
