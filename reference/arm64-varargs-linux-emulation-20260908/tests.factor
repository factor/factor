USING: accessors alien.c-types math.vectors.simd assocs compiler.errors debugger io kernel namespaces sequences
parser system tools.test vocabs.loader ;
! Apply final source align-first metadata to the already loaded SIMD types.
{ char-16 uchar-16 short-8 ushort-8 int-4 uint-4 longlong-2 ulonglong-2
  float-4 double-2 half-8 bfloat-8 } [ lookup-c-type 16 >>align-first drop ] each
f restartable-tests? set-global
"/tmp/factor-varargs-entry-linux.eAGr27/coverage.factor" run-file
"alien.varargs" test
"alien.parser" test
"stack-checker.alien" test
"compiler.cfg.builder.alien" test
"resource:basis/compiler/tests/alien-varargs.factor" run-test-file
"resource:basis/compiler/tests/alien-varargs-outgoing.factor" run-test-file
"resource:basis/compiler/tests/alien-varargs-promotions.factor" run-test-file
"resource:basis/compiler/tests/alien-arm64-unions.factor" run-test-file
test-failures get empty? compiler-errors get assoc-empty? and
[ "Linux ARM64 emulated varargs tests passed" print 0 ]
[ :test-failures compiler-errors get values [ print-error ] each 1 ] if flush exit
