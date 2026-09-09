USING: vocabs.refresh ;
<< refresh-all >>
USING: accessors arrays compiler.units assocs compiler.cfg.loop-optimization compiler.cfg.checker
compiler.cfg.utilities compiler.cfg.rpo compiler.cfg.loop-detection compiler.cfg.dominance compiler.cfg.def-use
compiler.cfg.optimizer compiler.cfg.alias-analysis compiler.cfg.ssa.construction
compiler.cfg.copy-prop compiler.cfg.multiply-negate compiler.cfg.dce
compiler.cfg.value-numbering compiler.cfg.register-allocation.verifier
compiler.cfg.register-allocation.verifier.rematerialization
compiler.cfg.linear-scan.allocation.state compiler.cfg.register-allocation.rematerialization
compiler.test io kernel locals math math.bitwise namespaces prettyprint
sequences system tools.test typed words ;
IN: compiler.cfg.optimizer
! Isolated opt-in activation; root owns the eventual shared pipeline hook.
: optimize-ssa ( cfg -- )
    dup \ construct-ssa checked-ssa-pass
    dup \ alias-analysis checked-ssa-pass
    dup \ value-numbering checked-ssa-pass
    dup \ copy-propagation checked-ssa-pass
    dup \ optimize-loops checked-ssa-pass
    dup \ fuse-multiply-negate checked-ssa-pass
    \ eliminate-dead-code checked-ssa-pass ;
IN: compiler.loop-source-probe
SYMBOL: source-hoists
V{ } clone source-hoists set-global
<< \ source-hoists \ perform-loop-optimization def>> "original-pass" set-word-prop >>
USE: compiler.loop-source-probe
IN: compiler.cfg.loop-optimization
: perform-loop-optimization ( cfg -- )
    dup reverse-post-order [ [ number>> ] [ kill-block?>> ] [ instructions>> ] tri 3array . ] each
    \ source-hoists "original-pass" word-prop call( cfg -- )
    "hoisted" loop-optimization-statistics get at 0 or
    source-hoists get push ;
IN: compiler.loop-source-probe
TYPED:: invariant-xor-loop ( x: fixnum y: fixnum n: fixnum -- result: fixnum )
    0 :> sum!
    n [ x y bitxor sum bitxor sum! ] times
    sum ; inline
f global-value-numbering? set-global
f rematerialize-constants? set-global
t check-ssa? set-global t check-allocation? set-global
t loop-optimization? set-global
value-flow-verifier-enabled? t assert=
f restartable-tests? set-global
source-hoists get delete-all
\ invariant-xor-loop "typed-word" word-prop 1array compile
{ 0 4 0 4 } [
    7 3 0 [ invariant-xor-loop ] compile-call
    7 3 1 [ invariant-xor-loop ] compile-call
    7 3 4 [ invariant-xor-loop ] compile-call
    7 3 19 [ invariant-xor-loop ] compile-call
] unit-test
source-hoists get .
source-hoists get sum 0 > t assert=
test-failures get empty? t assert=
"LICM SOURCE PASS" print
0 exit
