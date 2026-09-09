USING: vocabs.refresh ;
<< refresh-all >>
USING: accessors alien alien.data arrays compiler.cfg.checker compiler.cfg.instructions
compiler.cfg.linear-scan.allocation.state compiler.cfg.slp
compiler.cfg.register-allocation.verifier compiler.test
compiler.units stack-checker io io.encodings.binary io.files kernel kernel.private layouts locals
math math.bitwise namespaces parser prettyprint sequences system words ;
<< "reference/compiler-next3-vectorization-20260909/kernels.factor" run-file >>
USE: benchmark.scalar-mixing
IN: compiler-next3.slp.check

t check-allocation? set
t check-ssa? set
value-flow-verifier-enabled? t assert=
slp-supported? t assert=

SYMBOLS: scalar-word packed-word ;
f automatic-slp? [
    [ \ mixing-pair def>> dup infer define-temp scalar-word set-global ] with-compilation-unit
] with-variable
t automatic-slp? [
    [ \ mixing-pair def>> dup infer define-temp packed-word set-global ] with-compilation-unit
] with-variable

:: packed-answer ( x y a b -- values )
    x y a b packed-word get execute( x y a b -- p q ) 2array ;
:: scalar-answer ( x y a b -- values )
    x y a b scalar-word get execute( x y a b -- p q ) 2array ;
: wrap-fixnum ( n -- n' )
    most-positive-fixnum 2 * 1 + bitand
    dup most-positive-fixnum > [ most-positive-fixnum 1 + 2 * - ] when ;

:: compare-pairs ( -- )
    { 0 1 -1 31 -256 1000000 }
    most-positive-fixnum suffix most-negative-fixnum suffix :> inputs
    inputs [| x |
        inputs [| y |
            inputs [| key |
                inputs [| increment |
                    x y key increment scalar-answer :> ordinary
                    x y key increment packed-answer dup ordinary = [ drop ] [ x y key increment 4array . dup . ordinary . "PACKED-MISMATCH" throw ] if
                    x key increment scalar-oracle wrap-fixnum
                    y key increment scalar-oracle wrap-fixnum 2array dup ordinary = [ drop ] [ x y key increment 4array . dup . ordinary . "ORACLE-MISMATCH" throw ] if
                ] each
            ] each
        ] each
    ] each ;
compare-pairs
"NATIVE-SCALAR-PACKED-INTEGER PASS 4096" print

t automatic-slp? [
    \ mixing-pair [ ##xor-vector? ] count-insns dup 0 > t assert= .
] with-variable
"SLP-EMISSION PASS" print
scalar-word get word-code over - swap <alien> swap memory>byte-array
[ length "SCALAR-CODE-BYTES " write . ] keep
"reference/compiler-next3-vectorization-20260909/scalar-code.bin" binary set-file-contents
packed-word get word-code over - swap <alien> swap memory>byte-array
[ length "PACKED-CODE-BYTES " write . ] keep
"reference/compiler-next3-vectorization-20260909/packed-code.bin" binary set-file-contents
"reference/compiler-next3-vectorization-20260909/edge-check.factor" run-file
"ARRAY-EDGE-CASES PASS 48" print
0 exit
