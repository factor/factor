USING: accessors arrays compiler.cfg compiler.cfg.debugger
compiler.cfg.instructions compiler.cfg.multiply-negate compiler.cfg.utilities
compiler.test io kernel kernel.private math math.private memory namespaces
prettyprint sequences tools.time ;
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

"50 x three frontend/register-allocation compilations (ns):" print
measure
"No-negation CFG: 10,000 x 200 instructions pass time (ns):" print
pass-workload [ 10000 [ dup fuse-multiply-negate ] times ] benchmark . drop
