USING: vocabs.loader vocabs.refresh ;
<< "compiler.cfg.register-allocation" reload
   "compiler.cfg.register-allocation.chordal" reload >>
USING: compiler.cfg.register-allocation.verifier ;
USING: compiler.cfg.register-allocation compiler.cfg.register-allocation.chordal compiler.cfg.linear-scan.allocation.state compiler.cfg.linear-scan.numbering compiler.cfg.value-numbering namespaces prettyprint sequences tools.test ;
chordal-allocator register-allocator set
t check-allocation? set
value-flow-verifier-enabled? [ ] [ "verifier-disabled" throw ] if
t check-numbering? set
f global-value-numbering? set
"compiler.cfg.register-allocation.chordal" test
{
"resource:basis/compiler/tests/codegen.factor"
"resource:basis/compiler/tests/float.factor"
"resource:basis/compiler/tests/spilling.factor"
"resource:basis/compiler/tests/alien.factor"
"resource:basis/compiler/tests/alien-arm64-abi.factor"
"resource:basis/compiler/tests/alien-large-return.factor"
} [ run-test-file ] each
test-failures get .
